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

/// Cached so the underlying stream stays stable across widget rebuilds
/// (recreating the stream each build makes dependent StreamBuilders flash).
final rowByPageIdProvider =
    StreamProvider.family<DatabaseRowModel?, String>((ref, pageId) {
  return ref.watch(databaseRepositoryProvider).watchRowByPageId(pageId);
});

final databasePropertiesProvider =
    StreamProvider.family<List<DatabaseProperty>, String>((ref, databaseId) {
  return ref.watch(databaseRepositoryProvider).watchProperties(databaseId);
});

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

  Future<void> reorderProperties(List<String> orderedIds) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.databasePropertiesTable)
              ..where((p) => p.id.equals(orderedIds[i])))
            .write(DatabasePropertiesTableCompanion(
          position: Value(i.toDouble()),
          updatedAt: Value(now),
          isDirty: const Value(true),
        ));
      }
    });
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

  Future<Map<String, PropertyType>> _propertyTypes(String databaseId) async {
    final props = await (_db.select(_db.databasePropertiesTable)
          ..where((p) => p.databaseId.equals(databaseId)))
        .get();
    return {for (final p in props) p.id: PropertyType.fromString(p.type)};
  }

  PropertyValue? _decodeValue(
      DatabasePropertyValuesTableData v, PropertyType? type) {
    if (v.valueText != null) return TextValue(v.valueText!);
    if (v.valueNumber != null) return NumberValue(v.valueNumber!);
    if (v.valueDate != null) {
      return DateValue(DateTime.fromMillisecondsSinceEpoch(v.valueDate!));
    }
    if (v.valueBool != null) return CheckboxValue(v.valueBool!);
    if (v.valueSelect != null) {
      if (type == PropertyType.multiSelect) {
        try {
          final ids = (jsonDecode(v.valueSelect!) as List).cast<String>();
          return ids.isEmpty ? null : MultiSelectValue(ids);
        } catch (_) {
          return SelectValue(v.valueSelect!);
        }
      }
      return SelectValue(v.valueSelect!);
    }
    return null;
  }

  Future<DatabaseRowModel?> _loadRowByPageId(String pageId) async {
    final row = await (_db.select(_db.databaseRowsTable)
          ..where((r) => r.pageId.equals(pageId))
          ..where((r) => r.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;

    final typeById = await _propertyTypes(row.databaseId);
    final values = await (_db.select(_db.databasePropertyValuesTable)
          ..where((v) => v.rowId.equals(row.id))
          ..orderBy([(v) => OrderingTerm.asc(v.updatedAt)]))
        .get();

    final valueMap = <String, PropertyValue>{};
    for (final v in values) {
      final decoded = _decodeValue(v, typeById[v.propertyId]);
      if (decoded != null) valueMap[v.propertyId] = decoded;
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
    final typeById = await _propertyTypes(databaseId);
    // Order oldest-first so that if duplicate rows exist for a (row, property),
    // the most recently updated one is assigned last and wins.
    final allValues = await (_db.select(_db.databasePropertyValuesTable)
          ..where((v) => v.rowId.isIn(rowIds))
          ..orderBy([(v) => OrderingTerm.asc(v.updatedAt)]))
        .get();

    final valuesByRow = <String, Map<String, PropertyValue>>{};
    for (final v in allValues) {
      final decoded = _decodeValue(v, typeById[v.propertyId]);
      if (decoded == null) continue;
      final m = valuesByRow.putIfAbsent(v.rowId, () => <String, PropertyValue>{});
      m[v.propertyId] = decoded;
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
      case PropertyType.multiSelect:
        final ids = (value as List?)?.cast<String>() ?? const [];
        valueSelect = ids.isEmpty ? null : jsonEncode(ids);
    }

    // There's no unique index on (rowId, propertyId), so upsert by hand:
    // reuse the existing value row if there is one, otherwise insert a new one.
    final existing = await (_db.select(_db.databasePropertyValuesTable)
          ..where((v) => v.rowId.equals(rowId))
          ..where((v) => v.propertyId.equals(propertyId))
          ..orderBy([(v) => OrderingTerm.desc(v.updatedAt)])
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.databasePropertyValuesTable)
            ..where((v) => v.id.equals(existing.id)))
          .write(DatabasePropertyValuesTableCompanion(
        valueText: Value(valueText),
        valueNumber: Value(valueNumber),
        valueDate: Value(valueDate),
        valueBool: Value(valueBool),
        valueSelect: Value(valueSelect),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ));
    } else {
      await _db.into(_db.databasePropertyValuesTable).insert(
            DatabasePropertyValuesTableCompanion.insert(
              id: _uuid.v4(),
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
    }

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
