import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../db/app_database.dart';
import '../../../features/sync/sync_provider.dart';
import '../domain/database_model.dart';
import '../domain/database_row_model.dart';

final databaseRepositoryProvider = Provider<DatabaseRepository>(
  (ref) => DatabaseRepository(ref.watch(appDatabaseProvider)),
);

class DatabaseRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  DatabaseRepository(this._db);

  Stream<List<DatabaseProperty>> watchProperties(String databaseId) {
    return (_db.select(_db.databasePropertiesTable)
          ..where((p) => p.databaseId.equals(databaseId))
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.position)]))
        .watch()
        .map((rows) => rows.map(DatabaseProperty.fromRow).toList());
  }

  Future<DatabaseProperty> createProperty({
    required String databaseId,
    required String name,
    required PropertyType type,
    double? position,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _uuid.v4();
    final pos = position ?? await _nextPropertyPosition(databaseId);

    await _db.into(_db.databasePropertiesTable).insert(
          DatabasePropertiesTableCompanion.insert(
            id: id,
            databaseId: databaseId,
            name: name,
            type: type.name,
            position: Value(pos),
            createdAt: now,
            updatedAt: now,
            isDirty: const Value(true),
          ),
        );

    return DatabaseProperty.fromRow(
      await (_db.select(_db.databasePropertiesTable)
            ..where((p) => p.id.equals(id)))
          .getSingle(),
    );
  }

  Future<void> updateProperty(
    String id, {
    String? name,
    List<SelectOption>? options,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.databasePropertiesTable)..where((p) => p.id.equals(id)))
        .write(DatabasePropertiesTableCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      options: options != null
          ? Value(jsonEncode(options.map((o) => o.toJson()).toList()))
          : const Value.absent(),
      updatedAt: Value(now),
      isDirty: const Value(true),
    ));
  }

  Future<void> deleteProperty(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.databasePropertiesTable)..where((p) => p.id.equals(id)))
        .write(DatabasePropertiesTableCompanion(
      deletedAt: Value(now),
      updatedAt: Value(now),
      isDirty: const Value(true),
    ));
  }

  Stream<DatabaseRowModel?> watchRowByPageId(String pageId) {
    return _db.customSelect(
      'SELECT 1',
      readsFrom: {_db.databaseRowsTable, _db.databasePropertyValuesTable},
    ).watch().asyncMap((_) => _loadRowByPageId(pageId));
  }

  Future<DatabaseRowModel?> _loadRowByPageId(String pageId) async {
    final row = await (_db.select(_db.databaseRowsTable)
          ..where((r) => r.pageId.equals(pageId))
          ..where((r) => r.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;

    final values = await (_db.select(_db.databasePropertyValuesTable)
          ..where((v) => v.rowId.equals(row.id)))
        .get();

    final valueMap = <String, PropertyValue>{};
    for (final v in values) {
      if (v.valueText != null) {
        valueMap[v.propertyId] = TextValue(v.valueText!);
      } else if (v.valueNumber != null) {
        valueMap[v.propertyId] = NumberValue(v.valueNumber!);
      } else if (v.valueDate != null) {
        valueMap[v.propertyId] =
            DateValue(DateTime.fromMillisecondsSinceEpoch(v.valueDate!));
      } else if (v.valueBool != null) {
        valueMap[v.propertyId] = CheckboxValue(v.valueBool!);
      } else if (v.valueSelect != null) {
        valueMap[v.propertyId] = SelectValue(v.valueSelect!);
      }
    }

    return DatabaseRowModel(
      id: row.id,
      databaseId: row.databaseId,
      pageId: row.pageId,
      position: row.position,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      values: valueMap,
    );
  }

  Stream<List<DatabaseRowModel>> watchRows(String databaseId) {
    // Watch both tables so changes to a value (e.g. from sync) re-fire even
    // when the row's updated_at didn't change.
    return _db.customSelect(
      'SELECT 1',
      readsFrom: {_db.databaseRowsTable, _db.databasePropertyValuesTable},
    ).watch().asyncMap((_) => _loadRows(databaseId));
  }

  Future<List<DatabaseRowModel>> _loadRows(String databaseId) async {
    final rows = await (_db.select(_db.databaseRowsTable)
          ..where((r) => r.databaseId.equals(databaseId))
          ..where((r) => r.deletedAt.isNull())
          ..orderBy([(r) => OrderingTerm.asc(r.position)]))
        .get();
    if (rows.isEmpty) return const <DatabaseRowModel>[];

    final rowIds = rows.map((r) => r.id).toList();
    final allValues = await (_db.select(_db.databasePropertyValuesTable)
          ..where((v) => v.rowId.isIn(rowIds)))
        .get();

    final valuesByRow = <String, Map<String, PropertyValue>>{};
    for (final v in allValues) {
      final m = valuesByRow.putIfAbsent(v.rowId, () => <String, PropertyValue>{});
      if (v.valueText != null) {
        m[v.propertyId] = TextValue(v.valueText!);
      } else if (v.valueNumber != null) {
        m[v.propertyId] = NumberValue(v.valueNumber!);
      } else if (v.valueDate != null) {
        m[v.propertyId] =
            DateValue(DateTime.fromMillisecondsSinceEpoch(v.valueDate!));
      } else if (v.valueBool != null) {
        m[v.propertyId] = CheckboxValue(v.valueBool!);
      } else if (v.valueSelect != null) {
        m[v.propertyId] = SelectValue(v.valueSelect!);
      }
    }

    return rows
        .map((row) => DatabaseRowModel(
              id: row.id,
              databaseId: row.databaseId,
              pageId: row.pageId,
              position: row.position,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
              values: valuesByRow[row.id] ?? const <String, PropertyValue>{},
            ))
        .toList();
  }

  Future<DatabaseRowModel> createRow(String databaseId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rowId = _uuid.v4();
    final pageId = _uuid.v4();
    final pos = await _nextRowPosition(databaseId);

    await _db.into(_db.pagesTable).insert(PagesTableCompanion.insert(
          id: pageId,
          parentId: Value(databaseId),
          title: const Value(''),
          position: const Value(1.0),
          createdAt: now,
          updatedAt: now,
          isDirty: const Value(true),
          isNew: const Value(true),
        ));

    await _db.into(_db.databaseRowsTable).insert(
          DatabaseRowsTableCompanion.insert(
            id: rowId,
            databaseId: databaseId,
            pageId: pageId,
            position: Value(pos),
            createdAt: now,
            updatedAt: now,
            isDirty: const Value(true),
          ),
        );

    return DatabaseRowModel(
      id: rowId,
      databaseId: databaseId,
      pageId: pageId,
      position: pos,
      createdAt: now,
      updatedAt: now,
      values: {},
    );
  }

  Future<void> deleteRow(String rowId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.databaseRowsTable)..where((r) => r.id.equals(rowId)))
        .write(DatabaseRowsTableCompanion(
      deletedAt: Value(now),
      updatedAt: Value(now),
      isDirty: const Value(true),
    ));
  }

  Future<void> setValue({
    required String rowId,
    required String propertyId,
    required PropertyType type,
    required dynamic value,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _uuid.v4();

    String? valueText;
    double? valueNumber;
    int? valueDate;
    bool? valueBool;
    String? valueSelect;

    switch (type) {
      case PropertyType.text:
        valueText = value as String?;
      case PropertyType.number:
        valueNumber = (value as num?)?.toDouble();
      case PropertyType.date:
        valueDate = (value as DateTime?)?.millisecondsSinceEpoch;
      case PropertyType.checkbox:
        valueBool = value as bool?;
      case PropertyType.select:
        valueSelect = value as String?;
    }

    await _db.into(_db.databasePropertyValuesTable).insertOnConflictUpdate(
          DatabasePropertyValuesTableCompanion.insert(
            id: id,
            rowId: rowId,
            propertyId: propertyId,
            valueText: Value(valueText),
            valueNumber: Value(valueNumber),
            valueDate: Value(valueDate),
            valueBool: Value(valueBool),
            valueSelect: Value(valueSelect),
            createdAt: now,
            updatedAt: now,
            isDirty: const Value(true),
          ),
        );

    await (_db.update(_db.databaseRowsTable)..where((r) => r.id.equals(rowId)))
        .write(DatabaseRowsTableCompanion(
      updatedAt: Value(now),
      isDirty: const Value(true),
    ));
  }

  Future<double> _nextPropertyPosition(String databaseId) async {
    final last = await (_db.select(_db.databasePropertiesTable)
          ..where((p) => p.databaseId.equals(databaseId))
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.desc(p.position)])
          ..limit(1))
        .getSingleOrNull();
    return (last?.position ?? 0.0) + 1.0;
  }

  Future<double> _nextRowPosition(String databaseId) async {
    final last = await (_db.select(_db.databaseRowsTable)
          ..where((r) => r.databaseId.equals(databaseId))
          ..where((r) => r.deletedAt.isNull())
          ..orderBy([(r) => OrderingTerm.desc(r.position)])
          ..limit(1))
        .getSingleOrNull();
    return (last?.position ?? 0.0) + 1.0;
  }
}
