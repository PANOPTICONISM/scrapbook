import 'package:drift/drift.dart';

import 'database_rows_table.dart';
import 'database_properties_table.dart';

class DatabasePropertyValuesTable extends Table {
  TextColumn get id => text()();
  TextColumn get rowId => text().references(DatabaseRowsTable, #id)();
  TextColumn get propertyId => text().references(DatabasePropertiesTable, #id)();
  TextColumn get valueText => text().nullable()();
  RealColumn get valueNumber => real().nullable()();
  IntColumn get valueDate => integer().nullable()();
  BoolColumn get valueBool => boolean().nullable()();
  TextColumn get valueSelect => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
