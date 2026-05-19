import 'package:drift/drift.dart';

class PagesTable extends Table {
  TextColumn get id => text()();
  TextColumn get parentId => text().nullable()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get icon => text().nullable()();
  BoolColumn get isDatabase => boolean().withDefault(const Constant(false))();
  RealColumn get position => real().withDefault(const Constant(0.0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isNew => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
