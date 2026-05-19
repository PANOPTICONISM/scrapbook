import 'package:drift/drift.dart';

import 'pages_table.dart';

class BlocksTable extends Table {
  TextColumn get id => text()();
  TextColumn get pageId => text().references(PagesTable, #id)();
  TextColumn get type => text().withDefault(const Constant('markdown'))();
  TextColumn get content => text().withDefault(const Constant(''))();
  RealColumn get position => real().withDefault(const Constant(0.0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isNew => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
