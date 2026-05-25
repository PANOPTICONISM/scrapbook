import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'block_types.dart';
import 'inline_style.dart';
import 'link_editor_popover.dart';
import 'link_hover_preview.dart';
import 'markdown_codec.dart';
import 'rich_text_controller.dart';
import 'selection_format_bar.dart';

/// An editable block. Renders content in its formatted style while editing.
class BlockWidget extends StatefulWidget {
  final BlockType type;
  final String content;
  final bool todoChecked;
  /// 1-based position within a run of consecutive numbered-list blocks.
  final int listNumber;
  final bool autofocus;
  final FocusNode? focusNode;
  final void Function(String) onContentChanged;
  final void Function(BlockType) onTypeChanged;
  final void Function(bool) onTodoCheckedChanged;
  final VoidCallback onEnterPressed;
  /// Fires when backspace is pressed with the caret collapsed at offset 0,
  /// carrying this block's current markdown so the parent can merge it into the
  /// previous block (or strip the block style).
  final void Function(String currentMarkdown) onBackspaceAtStart;
  /// Editor-level undo/redo (Cmd/Ctrl+Z and Cmd/Ctrl+Shift+Z).
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  /// Fires when ↑ is pressed and there's no line above inside this block.
  /// The [caretX] is the caret's x position in the field's local coords so
  /// the receiving block can land the cursor under the same column.
  final void Function(double caretX) onArrowUpAtStart;
  final void Function(double caretX) onArrowDownAtEnd;
  /// Called once when `/` is typed. The [link] tracks the TextField's screen
  /// position; the [localCaretOffset] is the position of the caret inside the
  /// TextField (TextField-local coordinates).
  final void Function(String text, LayerLink link, Offset localCaretOffset)
      onSlashTyped;
  final void Function(String text) onSlashQueryChanged;
  final VoidCallback onSlashDismissed;
  final VoidCallback onSlashMoveUp;
  final VoidCallback onSlashMoveDown;
  final VoidCallback onSlashConfirm;

  const BlockWidget({
    super.key,
    required this.type,
    required this.content,
    required this.todoChecked,
    this.listNumber = 1,
    required this.autofocus,
    required this.focusNode,
    required this.onContentChanged,
    required this.onTypeChanged,
    required this.onTodoCheckedChanged,
    required this.onEnterPressed,
    required this.onBackspaceAtStart,
    required this.onUndo,
    required this.onRedo,
    required this.onArrowUpAtStart,
    required this.onArrowDownAtEnd,
    required this.onSlashTyped,
    required this.onSlashQueryChanged,
    required this.onSlashDismissed,
    required this.onSlashMoveUp,
    required this.onSlashMoveDown,
    required this.onSlashConfirm,
  });

  @override
  State<BlockWidget> createState() => BlockWidgetState();
}

class BlockWidgetState extends State<BlockWidget> {
  // Must match the `base` TextStyle in _textStyle().
  static const _kBaseFontSize = 16.0;
  static const _kBaseLineHeight = 1.6;

  late RichTextController _controller;
  final GlobalKey _fieldKey = GlobalKey();
  // Guards the backspace-at-start merge so rapid key repeats don't fire it more
  // than once before the block is removed. Reset on key-up.
  bool _backspaceLatched = false;
  final LayerLink _fieldLink = LayerLink();
  bool _slashActive = false;
  int _slashStart = -1;

  OverlayEntry? _formatBar;
  TextSelection? _formatBarSelection;
  TextSelection? _consumedSelection;
  OverlayEntry? _linkPopover;
  OverlayEntry? _linkHover;

  /// Called by the parent after a slash selection is applied. Clears the slash
  /// query text from the field and resets the internal slash-tracking state.
  void onSlashConfirmed() {
    _slashActive = false;
    _slashStart = -1;
    _controller.setStyledText('', const <InlineStyle>[]);
  }

  @override
  void initState() {
    super.initState();
    _controller = RichTextController.fromMarkdown(widget.content);
    _controller.onLinkTap = _openLink;
    _controller.onLinkHover = _showLinkHover;
    _controller.onLinkHoverEnd = _hideLinkHover;
    _controller.addListener(_onTextChanged);
    widget.focusNode?.addListener(_onFocusChanged);
  }

  static const _allowedSchemes = {'http', 'https', 'mailto'};

  Future<void> _openLink(String url) async {
    var normalized = url.trim();
    if (normalized.isEmpty) return;
    final schemeMatch =
        RegExp(r'^([a-zA-Z][a-zA-Z0-9+.\-]*):').firstMatch(normalized);
    if (schemeMatch == null) {
      normalized = 'https://$normalized';
    } else if (!_allowedSchemes.contains(schemeMatch.group(1)!.toLowerCase())) {
      // Refuse schemes that could execute code or read local files.
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('Blocked link scheme: ${schemeMatch.group(1)}')),
      );
      return;
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null) return;

    final messenger = mounted ? ScaffoldMessenger.maybeOf(context) : null;
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        messenger?.showSnackBar(
          SnackBar(content: Text("Couldn't open $normalized")),
        );
      }
    } catch (_) {
      messenger?.showSnackBar(
        SnackBar(content: Text("Couldn't open $normalized")),
      );
    }
  }

  void _showLinkHover(String url, Offset globalPos) {
    _linkHover?.remove();
    _linkHover = _addOverlay(
      left: globalPos.dx + 12,
      top: globalPos.dy + 16,
      child: LinkHoverPreview(url: url),
    );
  }

  void _hideLinkHover() {
    _linkHover?.remove();
    _linkHover = null;
  }

  void _onFocusChanged() {
    if (!mounted) return;
    if (!_isFocused()) {
      _hideFormatBar();
      if (_slashActive) {
        _slashActive = false;
        _slashStart = -1;
        widget.onSlashDismissed();
      }
    }
    // A focus change is a strong signal that the previous "I just acted on
    // this selection" gesture is over; clear the guard so a re-selection of
    // the same range will surface the bar again.
    _consumedSelection = null;
    setState(() {});
  }

  @override
  void didUpdateWidget(BlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      widget.focusNode?.addListener(_onFocusChanged);
    }
    // Sync external content changes (e.g. from sync) when the user isn't
    // mid-edit. Compare against the controller's markdown form, not its plain
    // text, otherwise visible-text-equals-markdown blocks would silently lose
    // their styles on every rebuild.
    if (widget.content != _controller.toMarkdown() && !_isFocused()) {
      final styled = MarkdownCodec.decode(widget.content);
      _controller.setStyledText(styled.text, styled.styles);
    }
  }

  bool _isFocused() => widget.focusNode?.hasFocus ?? false;

  /// Lays out the field's current text in its actual rendered width. Returns
  /// the field's [RenderBox] together with a configured [TextPainter], or null
  /// when the field hasn't laid out yet.
  ({RenderBox box, TextPainter painter})? _layoutPainter({String? overrideText}) {
    final ctx = _fieldKey.currentContext;
    final box = ctx?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final painter = TextPainter(
      text: TextSpan(text: overrideText ?? _controller.text, style: _textStyle(context)),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: box.size.width);
    return (box: box, painter: painter);
  }

  /// Insert [child] into the root overlay, positioned with absolute screen
  /// coordinates. Returns the entry so the caller can store and remove it.
  OverlayEntry _addOverlay({required double left, required double top, required Widget child}) {
    final entry = OverlayEntry(
      builder: (_) => Positioned(left: left, top: top, child: child),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
    return entry;
  }

  /// Insert [child] anchored above the start of [sel], with [child]'s bottom
  /// sitting [height] + [gap] above the selection's top. Returns null if the
  /// selection can't be laid out (e.g. collapsed or before first frame).
  OverlayEntry? _anchorAboveSelection({
    required TextSelection sel,
    required Widget child,
    required double height,
    double gap = 6,
  }) {
    final layout = _layoutPainter();
    if (layout == null) return null;
    final boxes = layout.painter.getBoxesForSelection(sel);
    if (boxes.isEmpty) return null;
    final topLeft = layout.box.localToGlobal(
      Offset(boxes.first.left, boxes.first.top),
    );
    return _addOverlay(
      left: topLeft.dx,
      top: topLeft.dy - height - gap,
      child: child,
    );
  }

  /// Position just below the caret line, in TextField-local coordinates.
  /// Anchors the slash menu to the caret regardless of where the field sits.
  Offset _caretLocalOffset(String text, int slashIndex) {
    final layout = _layoutPainter(overrideText: text.substring(0, slashIndex + 1));
    if (layout == null) return Offset.zero;
    final caretLocal = layout.painter.getOffsetForCaret(
      TextPosition(offset: slashIndex + 1),
      Rect.zero,
    );
    final style = _textStyle(context);
    final lineHeight = (style.fontSize ?? _kBaseFontSize) * (style.height ?? _kBaseLineHeight);
    return Offset(caretLocal.dx, caretLocal.dy + lineHeight);
  }

  void _onTextChanged() {
    final text = _controller.text;
    final caret = _controller.selection.baseOffset;

    if (!_slashActive && caret > 0 && text[caret - 1] == '/') {
      _slashStart = caret - 1;
      _slashActive = true;
      widget.onSlashTyped(text, _fieldLink, _caretLocalOffset(text, _slashStart));
    } else if (_slashActive) {
      if (caret <= _slashStart) {
        _slashActive = false;
        _slashStart = -1;
        widget.onSlashDismissed();
      } else {
        final query = text.substring(_slashStart + 1, caret);
        if (query.contains(' ') || query.contains('\n')) {
          _slashActive = false;
          _slashStart = -1;
          widget.onSlashDismissed();
        } else {
          widget.onSlashQueryChanged(query);
        }
      }
    }

    _checkMarkdownShortcuts(text);
    _updateFormatBar();

    widget.onContentChanged(_controller.toMarkdown());
  }

  void _updateFormatBar() {
    if (_slashActive) {
      if (_formatBar != null) _hideFormatBar();
      return;
    }
    final sel = _controller.selection;
    // The "consumed" guard only suppresses the bar for the exact selection the
    // user just acted on; any new selection (even a tiny adjustment) clears it.
    if (_consumedSelection != null && _consumedSelection != sel) {
      _consumedSelection = null;
    }
    if (sel.isValid && !sel.isCollapsed) {
      if (_consumedSelection == sel) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final current = _controller.selection;
        if (current.isValid &&
            !current.isCollapsed &&
            _consumedSelection != current &&
            !_slashActive) {
          _showFormatBar();
        }
      });
    } else if (_formatBar != null) {
      _hideFormatBar();
    }
  }

  void _showFormatBar() {
    _formatBar?.remove();
    _formatBar = null;
    _linkPopover?.remove();
    _linkPopover = null;

    final sel = _controller.selection;
    // Snapshot the selection now — pointer-down on a toolbar button can race
    // with focus changes and momentarily collapse the live selection.
    _formatBarSelection = sel;
    _formatBar = _anchorAboveSelection(
      sel: sel,
      height: 32,
      child: SelectionFormatBar(onAction: _applyFormat),
    );
  }

  void _hideFormatBar() {
    _formatBar?.remove();
    _formatBar = null;
    _formatBarSelection = null;
  }

  void _applyFormat(FormatAction action) {
    final captured = _formatBarSelection;
    if (captured == null || !captured.isValid || captured.isCollapsed) {
      return;
    }

    if (action == FormatAction.link) {
      _hideFormatBar();
      _consumedSelection = captured;
      _applyLink(captured);
      return;
    }

    switch (action) {
      case FormatAction.bold:
        _toggleStyle(captured, (s) => s.bold, (s, v) => s.copyWith(bold: v));
      case FormatAction.italic:
        _toggleStyle(
            captured, (s) => s.italic, (s, v) => s.copyWith(italic: v));
      case FormatAction.code:
        _toggleStyle(captured, (s) => s.code, (s, v) => s.copyWith(code: v));
      case FormatAction.strikethrough:
        _toggleStyle(
          captured,
          (s) => s.strikethrough,
          (s, v) => s.copyWith(strikethrough: v),
        );
      case FormatAction.link:
        break;
    }
    _controller.selection = captured;
    _consumedSelection = captured;
    _hideFormatBar();
    widget.focusNode?.requestFocus();
  }

  /// Toggle one style flag across [sel]. If every char already has it, turn it
  /// off; otherwise turn it on for all chars.
  void _toggleStyle(
    TextSelection sel,
    bool Function(InlineStyle) read,
    InlineStyle Function(InlineStyle, bool) write,
  ) {
    final allOn = _controller.selectionHasStyle(sel, read);
    _controller.mapStyles(sel, (s) => write(s, !allOn));
  }

  void _applyLink(TextSelection sel) {
    final existing = _controller.styleAt(sel.start).linkUrl;
    _showLinkPopover(sel, existing);
  }

  void _showLinkPopover(TextSelection sel, String? initialUrl) {
    _linkPopover?.remove();
    _linkPopover = null;
    _formatBar?.remove();
    _formatBar = null;

    void close() {
      _linkPopover?.remove();
      _linkPopover = null;
      _controller.selection = sel;
      widget.focusNode?.requestFocus();
    }

    void apply(String url) {
      if (url.isEmpty) {
        _controller.mapStyles(sel, (s) => s.copyWith(clearLinkUrl: true));
      } else {
        _controller.mapStyles(sel, (s) => s.copyWith(linkUrl: url));
      }
      close();
    }

    _linkPopover = _anchorAboveSelection(
      sel: sel,
      height: 52,
      child: LinkEditorPopover(
        initialUrl: initialUrl,
        onApply: apply,
        onCancel: close,
      ),
    );
  }

  void _checkMarkdownShortcuts(String text) {
    if (widget.type != BlockType.paragraph) return;

    BlockType? newType;
    String newText = text;

    if (text == '# ') {
      newType = BlockType.heading1;
      newText = '';
    } else if (text == '## ') {
      newType = BlockType.heading2;
      newText = '';
    } else if (text == '### ') {
      newType = BlockType.heading3;
      newText = '';
    } else if (text == '- ' || text == '* ') {
      newType = BlockType.bulletedList;
      newText = '';
    } else if (text == '1. ') {
      newType = BlockType.numberedList;
      newText = '';
    } else if (text == '> ') {
      newType = BlockType.quote;
      newText = '';
    } else if (text == '[] ' || text == '[ ] ') {
      newType = BlockType.todo;
      newText = '';
    } else if (text == '```') {
      newType = BlockType.code;
      newText = '';
    } else if (text == '---') {
      newType = BlockType.divider;
      newText = '';
    }

    if (newType != null) {
      _controller.text = newText;
      widget.onTypeChanged(newType);
    }
  }

  /// Apply a format action using the controller's *current* selection
  /// (used by the keyboard shortcuts; the format bar uses its captured one).
  void _applyFormatToCurrent(FormatAction action) {
    final sel = _controller.selection;
    if (!sel.isValid || sel.isCollapsed) return;
    _formatBarSelection = sel;
    _applyFormat(action);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    // Backspace at the start of a block merges it into the previous one. This
    // must run on key *repeat* too, so holding backspace deletes across blocks.
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (event is KeyUpEvent) {
        _backspaceLatched = false;
        return KeyEventResult.ignored;
      }
      final sel = _controller.selection;
      if (sel.isCollapsed && sel.baseOffset == 0) {
        if (!_backspaceLatched) {
          _backspaceLatched = true;
          widget.onBackspaceAtStart(_controller.toMarkdown());
        }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final hk = HardwareKeyboard.instance;
    final isMod = hk.isMetaPressed || hk.isControlPressed;
    // Undo/redo are owned by the editor (single timeline), so always consume
    // them here — otherwise the TextField's own undo competes and the order
    // becomes unpredictable.
    if (isMod && !hk.isAltPressed && event.logicalKey == LogicalKeyboardKey.keyZ) {
      if (hk.isShiftPressed) {
        widget.onRedo();
      } else {
        widget.onUndo();
      }
      return KeyEventResult.handled;
    }
    if (isMod && !hk.isShiftPressed && !hk.isAltPressed) {
      if (event.logicalKey == LogicalKeyboardKey.keyB) {
        _applyFormatToCurrent(FormatAction.bold);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyI) {
        _applyFormatToCurrent(FormatAction.italic);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyE) {
        _applyFormatToCurrent(FormatAction.code);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyK) {
        _applyFormatToCurrent(FormatAction.link);
        return KeyEventResult.handled;
      }
    }

    // While the slash menu is open, arrow keys and Enter drive the menu.
    if (_slashActive) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        widget.onSlashMoveUp();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        widget.onSlashMoveDown();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        widget.onSlashConfirm();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _slashActive = false;
        _slashStart = -1;
        widget.onSlashDismissed();
        return KeyEventResult.handled;
      }
    }

    // Enter creates a new block, except in code blocks where it inserts a newline.
    if (event.logicalKey == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      if (widget.type != BlockType.code) {
        widget.onEnterPressed();
        return KeyEventResult.handled;
      }
    }

    // Arrow keys hop to the prev/next block only when the caret has nowhere
    // else to go inside this field — wrapped paragraphs still navigate within.
    if (_controller.selection.isCollapsed) {
      final isUp = event.logicalKey == LogicalKeyboardKey.arrowUp;
      final isDown = event.logicalKey == LogicalKeyboardKey.arrowDown;
      if (isUp || isDown) {
        final m = _measureCaretMovement();
        final caretX = m?.caretX ?? 0;
        if (isUp && (m == null || !m.canGoUp)) {
          widget.onArrowUpAtStart(caretX);
          return KeyEventResult.handled;
        }
        if (isDown && (m == null || !m.canGoDown)) {
          widget.onArrowDownAtEnd(caretX);
          return KeyEventResult.handled;
        }
      }
    }

    return KeyEventResult.ignored;
  }

  ({bool canGoUp, bool canGoDown, double caretX})? _measureCaretMovement() {
    final text = _controller.text;
    if (text.isEmpty) {
      return (canGoUp: false, canGoDown: false, caretX: 0);
    }
    final layout = _layoutPainter();
    if (layout == null) return null;

    final style = _textStyle(context);
    final lineHeight =
        (style.fontSize ?? _kBaseFontSize) * (style.height ?? _kBaseLineHeight);
    final caretRect = Rect.fromLTWH(0, 0, 2, lineHeight);
    final tp = layout.painter;

    final caretIndex = _controller.selection.baseOffset.clamp(0, text.length);
    final caretOffset = tp.getOffsetForCaret(TextPosition(offset: caretIndex), caretRect);
    Offset offsetForPos(TextPosition p) => tp.getOffsetForCaret(p, caretRect);

    final aboveProbe = Offset(caretOffset.dx, caretOffset.dy - lineHeight * 0.5);
    final above = offsetForPos(tp.getPositionForOffset(aboveProbe));
    final canGoUp = above.dy < caretOffset.dy - 0.5;

    final belowProbe = Offset(caretOffset.dx, caretOffset.dy + lineHeight * 1.5);
    final below = offsetForPos(tp.getPositionForOffset(belowProbe));
    final canGoDown = below.dy > caretOffset.dy + 0.5;

    return (canGoUp: canGoUp, canGoDown: canGoDown, caretX: caretOffset.dx);
  }

  /// Replace this block's content (markdown) and drop the caret at [offset]
  /// in the plain text, then focus. Used when a following block merges into
  /// this one on backspace.
  void setContentAndCaret(String markdown, int offset) {
    // Don't let this programmatic change fire onContentChanged (it would
    // schedule a save and pollute the undo history).
    _controller.removeListener(_onTextChanged);
    final styled = MarkdownCodec.decode(markdown);
    _controller.setStyledText(styled.text, styled.styles);
    final len = _controller.text.length;
    _controller.selection =
        TextSelection.collapsed(offset: offset.clamp(0, len));
    _controller.addListener(_onTextChanged);
    widget.focusNode?.requestFocus();
  }

  /// Place the caret near the given x on this block's last visual line.
  /// Called by the parent when arrow-up navigates *into* this block from below.
  void placeCaretAtBottomNear(double x) {
    _placeCaretByXAndYRatio(x, 1.0);
  }

  /// Place the caret near the given x on this block's first visual line.
  void placeCaretAtTopNear(double x) {
    _placeCaretByXAndYRatio(x, 0.0);
  }

  void _placeCaretByXAndYRatio(double x, double yRatio) {
    final text = _controller.text;
    if (text.isEmpty) {
      _controller.selection = const TextSelection.collapsed(offset: 0);
      return;
    }
    final layout = _layoutPainter();
    if (layout == null) {
      _controller.selection = TextSelection.collapsed(
        offset: yRatio < 0.5 ? 0 : text.length,
      );
      return;
    }
    final tp = layout.painter;
    final targetY = yRatio < 0.5 ? 1.0 : tp.height - 1.0;
    final position = tp.getPositionForOffset(Offset(x, targetY));
    _controller.selection = TextSelection.collapsed(offset: position.offset);
  }

  @override
  void dispose() {
    _formatBar?.remove();
    _linkPopover?.remove();
    _linkHover?.remove();
    widget.focusNode?.removeListener(_onFocusChanged);
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == BlockType.divider) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(thickness: 1, color: Theme.of(context).dividerColor),
      );
    }

    final field = CompositedTransformTarget(
      link: _fieldLink,
      child: TextField(
        key: _fieldKey,
        controller: _controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        maxLines: null,
        minLines: 1,
        style: _textStyle(context),
        decoration: InputDecoration(
          // Only show the hint on the focused line — otherwise every empty
          // block would advertise "Type '/' for commands".
          hintText: _isFocused() ? widget.type.hint : null,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );

    final keyed = Focus(onKeyEvent: _handleKey, child: field);

    return _wrapBlock(context, keyed);
  }

  Widget _wrapBlock(BuildContext context, Widget child) {
    const padding = EdgeInsets.symmetric(vertical: 3);
    final markerColor = Theme.of(context).colorScheme.onSurface;

    return switch (widget.type) {
      BlockType.heading1 ||
      BlockType.heading2 ||
      BlockType.heading3 ||
      BlockType.paragraph =>
        Padding(padding: padding, child: child),
      BlockType.bulletedList => Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 10, left: 4),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: markerColor),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      BlockType.numberedList => Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0, right: 8, left: 0),
                child: Text('${widget.listNumber}.', style: TextStyle(fontSize: 16, height: 1.6, color: markerColor)),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      BlockType.todo => Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 6),
                child: SizedBox(
                  width: 18, height: 18,
                  child: Checkbox(
                    value: widget.todoChecked,
                    onChanged: (v) => widget.onTodoCheckedChanged(v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      BlockType.quote => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(width: 3, color: Colors.grey)),
          ),
          child: child,
        ),
      BlockType.code => Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: child,
        ),
      BlockType.divider => const SizedBox.shrink(),
      // Database blocks are rendered by the BlockEditor directly, never by
      // BlockWidget; databaseTable/databaseGallery are slash-menu-only and are
      // never stored. These arms only keep the switch exhaustive.
      BlockType.database ||
      BlockType.databaseTable ||
      BlockType.databaseGallery =>
        const SizedBox.shrink(),
    };
  }

  TextStyle _textStyle(BuildContext context) {
    const base = TextStyle(fontSize: 16, height: 1.6);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return switch (widget.type) {
      BlockType.heading1 => base.copyWith(fontSize: 30, fontWeight: FontWeight.bold, height: 1.3),
      BlockType.heading2 => base.copyWith(fontSize: 24, fontWeight: FontWeight.w600, height: 1.35),
      BlockType.heading3 => base.copyWith(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
      BlockType.quote => base.copyWith(fontStyle: FontStyle.italic, color: muted),
      BlockType.code => base.copyWith(fontFamily: 'Menlo', fontSize: 14),
      BlockType.todo => widget.todoChecked
          ? base.copyWith(decoration: TextDecoration.lineThrough, color: muted)
          : base,
      _ => base,
    };
  }
}
