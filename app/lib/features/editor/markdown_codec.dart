import 'inline_style.dart';

class StyledText {
  final String text;
  final List<InlineStyle> styles;
  const StyledText(this.text, this.styles);

  factory StyledText.plain(String text) =>
      StyledText(text, List.filled(text.length, InlineStyle.plain));
}

class MarkdownCodec {
  /// Characters that, if they appear in plain visible text, would be
  /// re-interpreted as markdown on decode. We escape them with a `\` on encode.
  static const _escapeChars = r'*_`[]\';

  static final RegExp _pattern = RegExp(
    // Negative lookbehind on `\` so escaped markers aren't matched.
    r'(?<!\\)\*\*([^*\n\\]*(?:\\.[^*\n\\]*)*?)\*\*'  // bold
    r'|(?<!\\)`([^`\n\\]*(?:\\.[^`\n\\]*)*?)`'      // code
    r'|(?<!\\)~~([^~\n\\]*(?:\\.[^~\n\\]*)*?)~~'    // strikethrough
    r'|(?<!\\)\*([^*\n\\]*(?:\\.[^*\n\\]*)*?)\*'    // italic
    r'|(?<!\\)\[([^\]\n\\]*(?:\\.[^\]\n\\]*)*?)\]\(([^)\n\\]*(?:\\.[^)\n\\]*)*?)\)',
  );

  /// Strip markdown markers from [markdown] and return the plain text plus a
  /// parallel array of per-character styles.
  static StyledText decode(String markdown) {
    final buf = StringBuffer();
    final styles = <InlineStyle>[];

    int cursor = 0;
    for (final m in _pattern.allMatches(markdown)) {
      if (m.start > cursor) {
        _appendUnescaped(markdown.substring(cursor, m.start), InlineStyle.plain, buf, styles);
      }
      final (rawInner, innerStyle) = _interpret(m);
      _appendUnescaped(rawInner, innerStyle, buf, styles);
      cursor = m.end;
    }
    if (cursor < markdown.length) {
      _appendUnescaped(markdown.substring(cursor), InlineStyle.plain, buf, styles);
    }
    return StyledText(buf.toString(), styles);
  }

  static void _appendUnescaped(
    String chunk,
    InlineStyle style,
    StringBuffer buf,
    List<InlineStyle> styles,
  ) {
    int i = 0;
    while (i < chunk.length) {
      final c = chunk[i];
      if (c == r'\' && i + 1 < chunk.length) {
        // \X → X (literal next char). Consume both.
        buf.write(chunk[i + 1]);
        styles.add(style);
        i += 2;
      } else {
        buf.write(c);
        styles.add(style);
        i++;
      }
    }
  }

  static (String, InlineStyle) _interpret(RegExpMatch m) {
    if (m.group(1) != null) return (m.group(1)!, const InlineStyle(bold: true));
    if (m.group(2) != null) return (m.group(2)!, const InlineStyle(code: true));
    if (m.group(3) != null) {
      return (m.group(3)!, const InlineStyle(strikethrough: true));
    }
    if (m.group(4) != null) {
      return (m.group(4)!, const InlineStyle(italic: true));
    }
    if (m.group(5) != null) {
      return (m.group(5)!, InlineStyle(linkUrl: _unescape(m.group(6)!)));
    }
    return (m.group(0)!, InlineStyle.plain);
  }

  static String _unescape(String s) {
    final out = StringBuffer();
    int i = 0;
    while (i < s.length) {
      if (s[i] == r'\' && i + 1 < s.length) {
        out.write(s[i + 1]);
        i += 2;
      } else {
        out.write(s[i]);
        i++;
      }
    }
    return out.toString();
  }

  /// Group consecutive same-style runs in [styled] and emit a markdown string.
  static String encode(StyledText styled) {
    final n = styled.text.length < styled.styles.length
        ? styled.text.length
        : styled.styles.length;
    final buf = StringBuffer();
    int i = 0;
    while (i < n) {
      final style = styled.styles[i];
      int j = i + 1;
      while (j < n && styled.styles[j] == style) {
        j++;
      }
      buf.write(_wrap(_escape(styled.text.substring(i, j)), style));
      i = j;
    }
    if (n < styled.text.length) {
      buf.write(_escape(styled.text.substring(n)));
    }
    return buf.toString();
  }

  /// Escape any characters in [text] that the decoder would interpret as
  /// markdown markers.
  static String _escape(String text) {
    final out = StringBuffer();
    for (final c in text.split('')) {
      if (_escapeChars.contains(c)) out.write(r'\');
      out.write(c);
    }
    return out.toString();
  }

  static String _wrap(String text, InlineStyle s) {
    if (s.isPlain) return text;
    var out = text;
    if (s.code) out = '`$out`';
    if (s.linkUrl != null) out = '[$out](${_escape(s.linkUrl!)})';
    if (s.strikethrough) out = '~~$out~~';
    if (s.bold) out = '**$out**';
    if (s.italic) out = '*$out*';
    return out;
  }
}
