import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'scrapbook.db'));
    return NativeDatabase.createInBackground(file);
  });
}
