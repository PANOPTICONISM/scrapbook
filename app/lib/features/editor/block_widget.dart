import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'block_types.dart';

/// An editable block. Renders content in its formatted style while editing.
class BlockWidget extends StatefulWidget {
  final BlockType type;
  final String content;
  final bool todoChecked;
  final bool autofocus;
  final FocusNode? focusNode;
  final void Function(String) onContentChanged;
  final void Function(BlockType) onTypeChanged;
  final void Function(bool) onTodoCheckedChanged;
  final VoidCallback onEnterPressed;
  final VoidCallback onBackspaceEmpty;
  /// Called once when `/` is typed. The [link] tracks the TextField's screen
  /// position; the [localCaretOffset] is the position of the caret inside the
  /// TextField (TextField-local coordinates).
  final void Function(String text, LayerLink link, Offset localCaretOffset)
      onSlashTyped;
  final void Function(String text) onSlashQueryChanged;
  final VoidCallback onSlashDismissed;

  const BlockWidget({
    super.key,
    required this.type,
    required this.content,
    required this.todoChecked,
    required this.autofocus,
    required this.focusNode,
    required this.onContentChanged,
    required this.onTypeChanged,
    required this.onTodoCheckedChanged,
    required this.onEnterPressed,
    required this.onBackspaceEmpty,
    required this.onSlashTyped,
    required this.onSlashQueryChanged,
    required this.onSlashDismissed,
  });

  @override
  State<BlockWidget> createState() => BlockWidgetState();
}

class BlockWidgetState extends State<BlockWidget> {
  late TextEditingController _controller;
  final GlobalKey _fieldKey = GlobalKey();
  final LayerLink _fieldLink = LayerLink();
  bool _slashActive = false;
  int _slashStart = -1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
    _controller.addListener(_onTextChanged);
    widget.focusNode?.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(BlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      widget.focusNode?.addListener(_onFocusChanged);
    }
    // Sync external content changes (e.g., type changed externally)
    if (widget.content != _controller.text && !_isFocused()) {
      _controller.text = widget.content;
    }
  }

  bool _isFocused() => widget.focusNode?.hasFocus ?? false;

  /// Compute the caret's offset *inside* the TextField (local coordinates).
  /// Used together with a LayerLink so the slash menu can anchor to the caret
  /// regardless of where the TextField sits on screen.
  Offset _caretLocalOffset(String text, int slashIndex) {
    final ctx = _fieldKey.currentContext;
    if (ctx == null) return Offset.zero;
    final renderBox = ctx.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return Offset.zero;

    final style = _textStyle(context);
    final tp = TextPainter(
      text: TextSpan(text: text.substring(0, slashIndex + 1), style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: renderBox.size.width);

    final caretLocal = tp.getOffsetForCaret(
      TextPosition(offset: slashIndex + 1),
      Rect.zero,
    );

    // Position the menu just below the line the caret is on.
    final lineHeight = (style.fontSize ?? 16) * (style.height ?? 1.4);
    return Offset(caretLocal.dx, caretLocal.dy + lineHeight);
  }

  void _onTextChanged() {
    final text = _controller.text;
    final caret = _controller.selection.baseOffset;

    // Slash menu detection
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

    // Markdown shortcuts at start of empty/short block
    _checkMarkdownShortcuts(text);

    widget.onContentChanged(text);
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

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      // For paragraph in code/quote blocks, allow shift+enter for newline inside
      if (widget.type != BlockType.code) {
        widget.onEnterPressed();
        return KeyEventResult.handled;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _controller.text.isEmpty) {
      widget.onBackspaceEmpty();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
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
    final padding = const EdgeInsets.symmetric(vertical: 3);

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
                child: Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black87)),
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
              const Padding(
                padding: EdgeInsets.only(top: 0, right: 8, left: 0),
                child: Text('1.', style: TextStyle(fontSize: 16, height: 1.6)),
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
    };
  }

  TextStyle _textStyle(BuildContext context) {
    final base = const TextStyle(fontSize: 16, height: 1.6);
    return switch (widget.type) {
      BlockType.heading1 => base.copyWith(fontSize: 30, fontWeight: FontWeight.bold, height: 1.3),
      BlockType.heading2 => base.copyWith(fontSize: 24, fontWeight: FontWeight.w600, height: 1.35),
      BlockType.heading3 => base.copyWith(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
      BlockType.quote => base.copyWith(fontStyle: FontStyle.italic, color: Colors.grey.shade700),
      BlockType.code => base.copyWith(fontFamily: 'Menlo', fontSize: 14),
      BlockType.todo => widget.todoChecked
          ? base.copyWith(decoration: TextDecoration.lineThrough, color: Colors.grey)
          : base,
      _ => base,
    };
  }
}
