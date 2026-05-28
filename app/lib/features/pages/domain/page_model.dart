class PageModel {
  final String id;
  final String? parentId;
  final String title;
  final String? icon;
  final String? cover;
  final bool isDatabase;
  final double position;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  const PageModel({
    required this.id,
    this.parentId,
    required this.title,
    this.icon,
    this.cover,
    required this.isDatabase,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  PageModel copyWith({
    String? title,
    String? icon,
    String? cover,
    String? parentId,
    double? position,
    int? updatedAt,
    int? deletedAt,
  }) =>
      PageModel(
        id: id,
        parentId: parentId ?? this.parentId,
        title: title ?? this.title,
        icon: icon ?? this.icon,
        cover: cover ?? this.cover,
        isDatabase: isDatabase,
        position: position ?? this.position,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
      );
}
