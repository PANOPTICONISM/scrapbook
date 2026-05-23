class InlineStyle {
  final bool bold;
  final bool italic;
  final bool code;
  final bool strikethrough;
  final String? linkUrl;

  static const plain = InlineStyle();

  const InlineStyle({
    this.bold = false,
    this.italic = false,
    this.code = false,
    this.strikethrough = false,
    this.linkUrl,
  });

  bool get isPlain =>
      !bold && !italic && !code && !strikethrough && linkUrl == null;

  InlineStyle copyWith({
    bool? bold,
    bool? italic,
    bool? code,
    bool? strikethrough,
    String? linkUrl,
    bool clearLinkUrl = false,
  }) {
    return InlineStyle(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      code: code ?? this.code,
      strikethrough: strikethrough ?? this.strikethrough,
      linkUrl: clearLinkUrl ? null : (linkUrl ?? this.linkUrl),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InlineStyle &&
          other.bold == bold &&
          other.italic == italic &&
          other.code == code &&
          other.strikethrough == strikethrough &&
          other.linkUrl == linkUrl;

  @override
  int get hashCode => Object.hash(bold, italic, code, strikethrough, linkUrl);
}
