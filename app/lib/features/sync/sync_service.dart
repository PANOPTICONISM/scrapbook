import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../db/app_database.dart';

class SyncService {
  final AppDatabase _db;
  final Dio _http;

  SyncService({required this._db, required this._http});

  Future<int> _getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.lastSyncTimeKey) ?? 0;
  }

  Future<void> _setLastSyncTime(int time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.lastSyncTimeKey, time);
  }

  Future<void> sync() async {
    await pushToServer();
    await pullFromServer();
  }

  Future<void> pushToServer() async {
    final dirtyPages = await (_db.select(_db.pagesTable)
          ..where((p) => p.isDirty.equals(true)))
        .get();
    final dirtyBlocks = await (_db.select(_db.blocksTable)
          ..where((b) => b.isDirty.equals(true)))
        .get();
    final dirtyProps = await (_db.select(_db.databasePropertiesTable)
          ..where((p) => p.isDirty.equals(true)))
        .get();
    final dirtyRows = await (_db.select(_db.databaseRowsTable)
          ..where((r) => r.isDirty.equals(true)))
        .get();
    final dirtyVals = await (_db.select(_db.databasePropertyValuesTable)
          ..where((v) => v.isDirty.equals(true)))
        .get();

    if (dirtyPages.isEmpty &&
        dirtyBlocks.isEmpty &&
        dirtyProps.isEmpty &&
        dirtyRows.isEmpty &&
        dirtyVals.isEmpty) {
      return;
    }

    final response = await _http.post('/api/sync', data: {
      'pages': dirtyPages.map(_pageToJson).toList(),
      'blocks': dirtyBlocks.map(_blockToJson).toList(),
      'database_properties': dirtyProps.map(_propToJson).toList(),
      'database_rows': dirtyRows.map(_rowToJson).toList(),
      'database_property_values': dirtyVals.map(_valToJson).toList(),
    });

    final accepted = response.data['accepted'] as Map<String, dynamic>;

    // Clear dirty flag on accepted records
    for (final id in (accepted['pages'] as List? ?? []).cast<String>()) {
      await (_db.update(_db.pagesTable)..where((p) => p.id.equals(id)))
          .write(const PagesTableCompanion(isDirty: Value(false), isNew: Value(false)));
    }
    for (final id in (accepted['blocks'] as List? ?? []).cast<String>()) {
      await (_db.update(_db.blocksTable)..where((b) => b.id.equals(id)))
          .write(const BlocksTableCompanion(isDirty: Value(false), isNew: Value(false)));
    }
    for (final id in (accepted['database_properties'] as List? ?? []).cast<String>()) {
      await (_db.update(_db.databasePropertiesTable)..where((p) => p.id.equals(id)))
          .write(const DatabasePropertiesTableCompanion(isDirty: Value(false)));
    }
    for (final id in (accepted['database_rows'] as List? ?? []).cast<String>()) {
      await (_db.update(_db.databaseRowsTable)..where((r) => r.id.equals(id)))
          .write(const DatabaseRowsTableCompanion(isDirty: Value(false)));
    }
    for (final id in (accepted['database_property_values'] as List? ?? []).cast<String>()) {
      await (_db.update(_db.databasePropertyValuesTable)..where((v) => v.id.equals(id)))
          .write(const DatabasePropertyValuesTableCompanion(isDirty: Value(false)));
    }
  }

  Future<void> pullFromServer() async {
    final since = await _getLastSyncTime();
    final response = await _http.get('/api/sync', queryParameters: {'since': since});
    final data = response.data as Map<String, dynamic>;
    final serverTime = data['server_time'] as int;

    await _db.transaction(() async {
      for (final p in (data['pages'] as List)) {
        await _applyPage(p as Map<String, dynamic>);
      }
      for (final b in (data['blocks'] as List)) {
        await _applyBlock(b as Map<String, dynamic>);
      }
      for (final p in (data['database_properties'] as List? ?? [])) {
        await _applyDatabaseProperty(p as Map<String, dynamic>);
      }
      for (final r in (data['database_rows'] as List? ?? [])) {
        await _applyDatabaseRow(r as Map<String, dynamic>);
      }
      for (final v in (data['database_property_values'] as List? ?? [])) {
        await _applyPropertyValue(v as Map<String, dynamic>);
      }
    });

    await _setLastSyncTime(serverTime);
  }

  Future<void> _applyPage(Map<String, dynamic> data) async {
    final local = await (_db.select(_db.pagesTable)
          ..where((p) => p.id.equals(data['id'] as String)))
        .getSingleOrNull();

    final serverUpdatedAt = data['updated_at'] as int;

    if (local == null) {
      await _db.into(_db.pagesTable).insert(PagesTableCompanion.insert(
            id: data['id'] as String,
            parentId: Value(data['parent_id'] as String?),
            title: Value(data['title'] as String? ?? ''),
            icon: Value(data['icon'] as String?),
            isDatabase: Value((data['is_database'] as bool?) ?? false),
            position: Value((data['position'] as num).toDouble()),
            createdAt: data['created_at'] as int,
            updatedAt: serverUpdatedAt,
            deletedAt: Value(data['deleted_at'] as int?),
            isDirty: const Value(false),
            isNew: const Value(false),
          ));
    } else if (serverUpdatedAt >= local.updatedAt) {
      await (_db.update(_db.pagesTable)
            ..where((p) => p.id.equals(data['id'] as String)))
          .write(PagesTableCompanion(
        parentId: Value(data['parent_id'] as String?),
        title: Value(data['title'] as String? ?? ''),
        icon: Value(data['icon'] as String?),
        position: Value((data['position'] as num).toDouble()),
        updatedAt: Value(serverUpdatedAt),
        deletedAt: Value(data['deleted_at'] as int?),
        isDirty: const Value(false),
      ));
    }
  }

  Future<void> _applyBlock(Map<String, dynamic> data) async {
    final local = await (_db.select(_db.blocksTable)
          ..where((b) => b.id.equals(data['id'] as String)))
        .getSingleOrNull();

    final serverUpdatedAt = data['updated_at'] as int;

    if (local == null) {
      await _db.into(_db.blocksTable).insert(BlocksTableCompanion.insert(
            id: data['id'] as String,
            pageId: data['page_id'] as String,
            type: Value(data['type'] as String? ?? 'markdown'),
            content: Value(data['content'] as String? ?? ''),
            position: Value((data['position'] as num).toDouble()),
            createdAt: data['created_at'] as int,
            updatedAt: serverUpdatedAt,
            deletedAt: Value(data['deleted_at'] as int?),
            isDirty: const Value(false),
            isNew: const Value(false),
          ));
    } else if (serverUpdatedAt >= local.updatedAt) {
      await (_db.update(_db.blocksTable)
            ..where((b) => b.id.equals(data['id'] as String)))
          .write(BlocksTableCompanion(
        content: Value(data['content'] as String? ?? ''),
        position: Value((data['position'] as num).toDouble()),
        updatedAt: Value(serverUpdatedAt),
        deletedAt: Value(data['deleted_at'] as int?),
        isDirty: const Value(false),
      ));
    }
  }

  Future<void> _applyDatabaseProperty(Map<String, dynamic> data) async {
    final id = data['id'] as String;
    final local = await (_db.select(_db.databasePropertiesTable)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    final serverUpdatedAt = data['updated_at'] as int;

    if (local == null) {
      await _db.into(_db.databasePropertiesTable).insert(DatabasePropertiesTableCompanion.insert(
            id: id,
            databaseId: data['database_id'] as String,
            name: data['name'] as String,
            type: data['type'] as String,
            options: Value(data['options'] as String?),
            position: Value((data['position'] as num).toDouble()),
            createdAt: data['created_at'] as int,
            updatedAt: serverUpdatedAt,
            deletedAt: Value(data['deleted_at'] as int?),
            isDirty: const Value(false),
          ));
    } else if (serverUpdatedAt >= local.updatedAt) {
      await (_db.update(_db.databasePropertiesTable)..where((p) => p.id.equals(id))).write(
        DatabasePropertiesTableCompanion(
          name: Value(data['name'] as String),
          options: Value(data['options'] as String?),
          position: Value((data['position'] as num).toDouble()),
          updatedAt: Value(serverUpdatedAt),
          deletedAt: Value(data['deleted_at'] as int?),
          isDirty: const Value(false),
        ),
      );
    }
  }

  Future<void> _applyDatabaseRow(Map<String, dynamic> data) async {
    final id = data['id'] as String;
    final local = await (_db.select(_db.databaseRowsTable)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    final serverUpdatedAt = data['updated_at'] as int;

    if (local == null) {
      await _db.into(_db.databaseRowsTable).insert(DatabaseRowsTableCompanion.insert(
            id: id,
            databaseId: data['database_id'] as String,
            pageId: data['page_id'] as String,
            position: Value((data['position'] as num).toDouble()),
            createdAt: data['created_at'] as int,
            updatedAt: serverUpdatedAt,
            deletedAt: Value(data['deleted_at'] as int?),
            isDirty: const Value(false),
          ));
    } else if (serverUpdatedAt >= local.updatedAt) {
      await (_db.update(_db.databaseRowsTable)..where((r) => r.id.equals(id))).write(
        DatabaseRowsTableCompanion(
          position: Value((data['position'] as num).toDouble()),
          updatedAt: Value(serverUpdatedAt),
          deletedAt: Value(data['deleted_at'] as int?),
          isDirty: const Value(false),
        ),
      );
    }
  }

  Future<void> _applyPropertyValue(Map<String, dynamic> data) async {
    final rowId = data['row_id'] as String;
    final propertyId = data['property_id'] as String;
    final local = await (_db.select(_db.databasePropertyValuesTable)
          ..where((v) => v.rowId.equals(rowId))
          ..where((v) => v.propertyId.equals(propertyId)))
        .getSingleOrNull();
    final serverUpdatedAt = data['updated_at'] as int;

    if (local == null) {
      await _db.into(_db.databasePropertyValuesTable).insert(
            DatabasePropertyValuesTableCompanion.insert(
              id: data['id'] as String,
              rowId: rowId,
              propertyId: propertyId,
              valueText: Value(data['value_text'] as String?),
              valueNumber: Value((data['value_number'] as num?)?.toDouble()),
              valueDate: Value(data['value_date'] as int?),
              valueBool: Value(data['value_bool'] as bool?),
              valueSelect: Value(data['value_select'] as String?),
              createdAt: data['created_at'] as int,
              updatedAt: serverUpdatedAt,
              isDirty: const Value(false),
            ),
          );
    } else if (serverUpdatedAt >= local.updatedAt) {
      await (_db.update(_db.databasePropertyValuesTable)
            ..where((v) => v.rowId.equals(rowId))
            ..where((v) => v.propertyId.equals(propertyId)))
          .write(DatabasePropertyValuesTableCompanion(
        valueText: Value(data['value_text'] as String?),
        valueNumber: Value((data['value_number'] as num?)?.toDouble()),
        valueDate: Value(data['value_date'] as int?),
        valueBool: Value(data['value_bool'] as bool?),
        valueSelect: Value(data['value_select'] as String?),
        updatedAt: Value(serverUpdatedAt),
        isDirty: const Value(false),
      ));
    }
  }

  Map<String, dynamic> _pageToJson(PagesTableData p) => {
        'id': p.id,
        'parent_id': p.parentId,
        'title': p.title,
        'icon': p.icon,
        'is_database': p.isDatabase,
        'position': p.position,
        'created_at': p.createdAt,
        'updated_at': p.updatedAt,
        'deleted_at': p.deletedAt,
      };

  Map<String, dynamic> _blockToJson(BlocksTableData b) => {
        'id': b.id,
        'page_id': b.pageId,
        'type': b.type,
        'content': b.content,
        'position': b.position,
        'created_at': b.createdAt,
        'updated_at': b.updatedAt,
        'deleted_at': b.deletedAt,
      };

  Map<String, dynamic> _propToJson(DatabasePropertiesTableData p) => {
        'id': p.id,
        'database_id': p.databaseId,
        'name': p.name,
        'type': p.type,
        'options': p.options,
        'position': p.position,
        'created_at': p.createdAt,
        'updated_at': p.updatedAt,
        'deleted_at': p.deletedAt,
      };

  Map<String, dynamic> _rowToJson(DatabaseRowsTableData r) => {
        'id': r.id,
        'database_id': r.databaseId,
        'page_id': r.pageId,
        'position': r.position,
        'created_at': r.createdAt,
        'updated_at': r.updatedAt,
        'deleted_at': r.deletedAt,
      };

  Map<String, dynamic> _valToJson(DatabasePropertyValuesTableData v) => {
        'id': v.id,
        'row_id': v.rowId,
        'property_id': v.propertyId,
        'value_text': v.valueText,
        'value_number': v.valueNumber,
        'value_date': v.valueDate,
        'value_bool': v.valueBool,
        'value_select': v.valueSelect,
        'created_at': v.createdAt,
        'updated_at': v.updatedAt,
      };
}
