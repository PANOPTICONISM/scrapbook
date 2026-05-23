import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'inline_style.dart';
import 'markdown_codec.dart';

/// A TextEditingController that keeps a parallel per-character style array in
/// sync with its text. Styles are applied by toggling flags on the array;
/// markdown markers never appear in the visible text.
class RichTextController extends TextEditingController {
  List<InlineStyle> _styles;
  // Pool of recognizers keyed by URL — reused across rebuilds so a tap that
  // arrives in the same frame as a rebuild lands on a live recognizer.
  final Map<String, TapGestureRecognizer> _recognizers = {};

  /// Called when the user taps a link span (gets the URL).
  void Function(String url)? onLinkTap;

  /// Called when the user hovers over a link span (URL + global pointer pos).
  void Function(String url, Offset globalPos)? onLinkHover;

  /// Called when the pointer leaves a link span.
  VoidCallback? onLinkHoverEnd;

  RichTextController._(String text, this._styles) : super(text: text);

  @override
  void dispose() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  TapGestureRecognizer _recognizerFor(String url) {
    return _recognizers.putIfAbsent(
      url,
      () => TapGestureRecognizer()..onTap = () => onLinkTap?.call(url),
    );
  }

  factory RichTextController.fromMarkdown(String markdown) {
    final styled = MarkdownCodec.decode(markdown);
    assert(styled.text.length == styled.styles.length);
    return RichTextController._(styled.text, styled.styles);
  }

  String toMarkdown() => MarkdownCodec.encode(StyledText(text, _styles));

  /// Replace the controller's text and styles atomically (e.g. after a
  /// programmatic transform such as a slash-menu type change).
  void setStyledText(String newText, List<InlineStyle> newStyles, {TextSelection? selection}) {
    assert(newText.length == newStyles.length);
    _styles = List.of(newStyles);
    // Bypass the diffing in our [value] setter — we've already supplied a
    // matching styles array, and diffing against the *old* text with the new
    // styles array would corrupt the length invariant.
    super.value = TextEditingValue(
      text: newText,
      selection: selection ?? TextSelection.collapsed(offset: newText.length),
    );
  }

  /// Apply [transform] to the styles inside [selection].
  void mapStyles(
    TextSelection selection,
    InlineStyle Function(InlineStyle) transform,
  ) {
    if (!selection.isValid || selection.isCollapsed) return;
    final start = selection.start.clamp(0, _styles.length);
    final end = selection.end.clamp(0, _styles.length);
    for (int i = start; i < end; i++) {
      _styles[i] = transform(_styles[i]);
    }
    notifyListeners();
  }

  /// Read the style at the given index (clamped).
  InlineStyle styleAt(int index) {
    if (_styles.isEmpty) return InlineStyle.plain;
    final i = index.clamp(0, _styles.length - 1);
    return _styles[i];
  }

  /// True if every character in [selection] has [check] returning true.
  bool selectionHasStyle(
    TextSelection selection,
    bool Function(InlineStyle) check,
  ) {
    if (!selection.isValid || selection.isCollapsed) return false;
    final start = selection.start.clamp(0, _styles.length);
    final end = selection.end.clamp(0, _styles.length);
    if (start >= end) return false;
    for (int i = start; i < end; i++) {
      if (!check(_styles[i])) return false;
    }
    return true;
  }

  @override
  set value(TextEditingValue newValue) {
    final oldText = text;
    final newText = newValue.text;
    if (newText != oldText) {
      if (_styles.length != oldText.length) {
        // The styles array got out of sync somehow — rebuild as plain text.
        _styles = List.filled(newText.length, InlineStyle.plain);
      } else {
        _styles = _splice(oldText, newText, _styles);
      }
      assert(_styles.length == newText.length,
          '_styles=${_styles.length} text=${newText.length}');
    }
    super.value = newValue;
  }

  /// Compute the new style array by diffing the old and new text via longest
  /// common prefix + suffix. New characters inherit the style of their left
  /// neighbour; if there isn't one, they're plain.
  static List<InlineStyle> _splice(
    String oldText,
    String newText,
    List<InlineStyle> oldStyles,
  ) {
    final maxPrefix =
        oldText.length < newText.length ? oldText.length : newText.length;
    int prefix = 0;
    while (prefix < maxPrefix && oldText[prefix] == newText[prefix]) {
      prefix++;
    }
    final maxSuffix = (oldText.length - prefix) < (newText.length - prefix)
        ? (oldText.length - prefix)
        : (newText.length - prefix);
    int suffix = 0;
    while (suffix < maxSuffix &&
        oldText[oldText.length - 1 - suffix] ==
            newText[newText.length - 1 - suffix]) {
      suffix++;
    }

    final insertedLen = newText.length - prefix - suffix;
    final inheritStyle =
        prefix > 0 ? oldStyles[prefix - 1] : InlineStyle.plain;

    return [
      ...oldStyles.sublist(0, prefix),
      ...List.filled(insertedLen, inheritStyle),
      ...oldStyles.sublist(oldText.length - suffix),
    ];
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final base = style ?? const TextStyle();
    if (_styles.isEmpty || _styles.length != text.length) {
      return TextSpan(text: text, style: base);
    }

    final urlsInUse = <String>{};
    final spans = <InlineSpan>[];
    int i = 0;
    while (i < text.length) {
      final s = _styles[i];
      int j = i + 1;
      while (j < text.length && _styles[j] == s) {
        j++;
      }
      if (s.linkUrl != null) urlsInUse.add(s.linkUrl!);
      spans.add(_makeSpan(text.substring(i, j), base, s, context));
      i = j;
    }

    // Retire recognizers whose URL is no longer present.
    final stale = _recognizers.keys.where((u) => !urlsInUse.contains(u)).toList();
    for (final u in stale) {
      _recognizers.remove(u)?.dispose();
    }

    return TextSpan(style: base, children: spans);
  }

  TextSpan _makeSpan(
    String content,
    TextStyle base,
    InlineStyle s,
    BuildContext context,
  ) {
    final resolved = _resolve(base, s, context);
    if (s.linkUrl == null) {
      return TextSpan(text: content, style: resolved);
    }
    final url = s.linkUrl!;
    return TextSpan(
      text: content,
      style: resolved,
      recognizer: _recognizerFor(url),
      mouseCursor: SystemMouseCursors.click,
      onEnter: (event) => onLinkHover?.call(url, event.position),
      onExit: (_) => onLinkHoverEnd?.call(),
    );
  }

  TextStyle _resolve(TextStyle base, InlineStyle s, BuildContext context) {
    var out = base;
    if (s.bold) out = out.copyWith(fontWeight: FontWeight.bold);
    if (s.italic) out = out.copyWith(fontStyle: FontStyle.italic);
    if (s.code) {
      out = out.copyWith(
        fontFamily: 'Menlo',
        backgroundColor:
            Theme.of(context).colorScheme.surfaceContainerHighest,
      );
    }
    if (s.strikethrough) {
      out = out.copyWith(decoration: TextDecoration.lineThrough);
    }
    if (s.linkUrl != null) {
      out = out.copyWith(
        color: Theme.of(context).colorScheme.primary,
        decoration: out.decoration == TextDecoration.lineThrough
            ? TextDecoration.combine([
                TextDecoration.lineThrough,
                TextDecoration.underline,
              ])
            : TextDecoration.underline,
      );
    }
    return out;
  }
}
