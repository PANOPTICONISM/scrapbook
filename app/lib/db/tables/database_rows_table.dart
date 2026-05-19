import 'package:drift/drift.dart';

import 'pages_table.dart';

class DatabaseRowsTable extends Table {
  TextColumn get id => text()();
  TextColumn get databaseId => text().references(PagesTable, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('rowPage')
  TextColumn get pageId => text().references(PagesTable, #id)();
  RealColumn get position => real().withDefault(const Constant(0.0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
