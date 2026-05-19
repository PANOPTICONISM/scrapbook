import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../db/app_database.dart';
import '../../../features/sync/sync_provider.dart';
import '../domain/page_model.dart';

final pageRepositoryProvider = Provider<PageRepository>(
  (ref) => PageRepository(ref.watch(appDatabaseProvider)),
);

final allPagesProvider = StreamProvider<List<PageModel>>(
  (ref) => ref.watch(pageRepositoryProvider).watchAllPages(),
);

class PageRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  PageRepository(this._db);

  Stream<List<PageModel>> watchAllPages() {
    return (_db.select(_db.pagesTable)
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.position)]))
        .watch()
        .map((rows) => rows.map(_toModel).toList());
  }

  Future<PageModel?> getPage(String id) async {
    final row = await (_db.select(_db.pagesTable)
          ..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _toModel(row) : null;
  }

  Future<PageModel> createPage({
    String? parentId,
    bool isDatabase = false,
    double position = 1.0,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _uuid.v4();

    await _db.into(_db.pagesTable).insert(PagesTableCompanion.insert(
          id: id,
          parentId: Value(parentId),
          title: const Value(''),
          isDatabase: Value(isDatabase),
          position: Value(position),
          createdAt: now,
          updatedAt: now,
          isDirty: const Value(true),
          isNew: const Value(true),
        ));

    if (!isDatabase) {
      await _db.into(_db.blocksTable).insert(BlocksTableCompanion.insert(
            id: _uuid.v4(),
            pageId: id,
            type: const Value('markdown'),
            content: const Value(''),
            position: const Value(1.0),
            createdAt: now,
            updatedAt: now,
            isDirty: const Value(true),
            isNew: const Value(true),
          ));
    }

    return (await getPage(id))!;
  }

  Future<void> updateTitle(String id, String title) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.pagesTable)..where((p) => p.id.equals(id))).write(
      PagesTableCompanion(
        title: Value(title),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  /// Move a page to a new position among siblings under [newParentId] (null = root).
  /// [siblings] is the ordered list of pages that will share the same parent
  /// AFTER the move, excluding the moving page itself.
  Future<void> movePage({
    required String pageId,
    required String? newParentId,
    required int newIndex,
    required List<PageModel> siblings,
  }) async {
    final clamped = newIndex.clamp(0, siblings.length);

    double newPosition;
    if (siblings.isEmpty) {
      newPosition = 1.0;
    } else if (clamped == 0) {
      newPosition = siblings.first.position - 1.0;
    } else if (clamped >= siblings.length) {
      newPosition = siblings.last.position + 1.0;
    } else {
      newPosition = (siblings[clamped - 1].position + siblings[clamped].position) / 2;
    }

    if (newParentId != null && await _isDescendant(newParentId, pageId)) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.pagesTable)..where((p) => p.id.equals(pageId))).write(
      PagesTableCompanion(
        parentId: Value(newParentId),
        position: Value(newPosition),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  /// Returns true if [maybeDescendantId] is the same as [ancestorId] or one of its descendants.
  Future<bool> _isDescendant(String maybeDescendantId, String ancestorId) async {
    if (maybeDescendantId == ancestorId) return true;
    final row = await (_db.select(_db.pagesTable)..where((p) => p.id.equals(maybeDescendantId)))
        .getSingleOrNull();
    if (row == null || row.parentId == null) return false;
    return _isDescendant(row.parentId!, ancestorId);
  }

  Future<void> deletePage(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.pagesTable)..where((p) => p.id.equals(id))).write(
      PagesTableCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  /// Streams soft-deleted pages, most recently deleted first.
  Stream<List<PageModel>> watchTrash() {
    return (_db.select(_db.pagesTable)
          ..where((p) => p.deletedAt.isNotNull())
          ..orderBy([(p) => OrderingTerm.desc(p.deletedAt)]))
        .watch()
        .map((rows) => rows.map(_toModel).toList());
  }

  /// Restore a soft-deleted page (clear deleted_at). If its original parent is
  /// also deleted or no longer exists, the page is restored to the root.
  Future<void> restorePage(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final page = await (_db.select(_db.pagesTable)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    if (page == null) return;

    String? parentId = page.parentId;
    if (parentId != null) {
      final parent = await (_db.select(_db.pagesTable)
            ..where((p) => p.id.equals(parentId!)))
          .getSingleOrNull();
      if (parent == null || parent.deletedAt != null) {
        // Parent gone or also deleted — surface page at root
        parentId = null;
      }
    }

    await (_db.update(_db.pagesTable)..where((p) => p.id.equals(id))).write(
      PagesTableCompanion(
        parentId: Value(parentId),
        deletedAt: const Value(null),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }


  PageModel _toModel(PagesTableData row) => PageModel(
        id: row.id,
        parentId: row.parentId,
        title: row.title,
        icon: row.icon,
        isDatabase: row.isDatabase,
        position: row.position,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );
}
