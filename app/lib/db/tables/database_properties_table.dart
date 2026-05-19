import 'package:drift/drift.dart';

import 'pages_table.dart';

class DatabasePropertiesTable extends Table {
  TextColumn get id => text()();
  TextColumn get databaseId => text().references(PagesTable, #id)();
  TextColumn get name => text()();
  TextColumn get type => text()(); // text | number | date | checkbox | select
  TextColumn get options => text().nullable()(); // JSON string
  RealColumn get position => real().withDefault(const Constant(0.0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
