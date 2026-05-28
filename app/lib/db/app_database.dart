import 'package:drift/drift.dart';

import 'connection/connection.dart';
import 'tables/blocks_table.dart';
import 'tables/database_properties_table.dart';
import 'tables/database_property_values_table.dart';
import 'tables/database_rows_table.dart';
import 'tables/pages_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  PagesTable,
  BlocksTable,
  DatabasePropertiesTable,
  DatabaseRowsTable,
  DatabasePropertyValuesTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(pagesTable, pagesTable.cover);
          }
        },
      );
}
