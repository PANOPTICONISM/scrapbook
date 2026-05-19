import 'dart:convert';

class DatabaseProperty {
  final String id;
  final String databaseId;
  final String name;
  final PropertyType type;
  final List<SelectOption> options;
  final double position;
  final int createdAt;
  final int updatedAt;

  const DatabaseProperty({
    required this.id,
    required this.databaseId,
    required this.name,
    required this.type,
    required this.options,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  static DatabaseProperty fromRow(dynamic row) => DatabaseProperty(
        id: row.id as String,
        databaseId: row.databaseId as String,
        name: row.name as String,
        type: PropertyType.fromString(row.type as String),
        options: row.options != null
            ? (jsonDecode(row.options as String) as List)
                .map((o) => SelectOption.fromJson(o as Map<String, dynamic>))
                .toList()
            : [],
        position: row.position as double,
        createdAt: row.createdAt as int,
        updatedAt: row.updatedAt as int,
      );
}

enum PropertyType {
  text,
  number,
  date,
  checkbox,
  select;

  static PropertyType fromString(String s) =>
      PropertyType.values.firstWhere((e) => e.name == s, orElse: () => PropertyType.text);
}

class SelectOption {
  final String id;
  final String name;
  final String color;

  const SelectOption({required this.id, required this.name, required this.color});

  factory SelectOption.fromJson(Map<String, dynamic> j) => SelectOption(
        id: j['id'] as String,
        name: j['name'] as String,
        color: j['color'] as String? ?? '#888888',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color};
}
