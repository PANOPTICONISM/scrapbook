import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../db/app_database.dart';
import '../sync/sync_provider.dart';
import 'block_types.dart';

final blockRepositoryProvider = Provider<BlockRepository>(
  (ref) => BlockRepository(ref.watch(appDatabaseProvider)),
);

class BlockData {
  final String id;
  final String pageId;
  final BlockType type;
  final String content;
  final double position;
  final bool todoChecked;

  const BlockData({
    required this.id,
    required this.pageId,
    required this.type,
    required this.content,
    required this.position,
    this.todoChecked = false,
  });
}

class BlockRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  BlockRepository(this._db);

  Stream<List<BlockData>> watchBlocks(String pageId) {
    return (_db.select(_db.blocksTable)
          ..where((b) => b.pageId.equals(pageId))
          ..where((b) => b.deletedAt.isNull())
          ..orderBy([(b) => OrderingTerm.asc(b.position)]))
        .watch()
        .map((rows) => rows.map(_toData).toList());
  }

  Future<List<BlockData>> getBlocks(String pageId) async {
    final rows = await (_db.select(_db.blocksTable)
          ..where((b) => b.pageId.equals(pageId))
          ..where((b) => b.deletedAt.isNull())
          ..orderBy([(b) => OrderingTerm.asc(b.position)]))
        .get();
    return rows.map(_toData).toList();
  }

  /// Create a new block, optionally after a given block.
  /// Returns the new block's id.
  Future<String> insertBlock({
    required String pageId,
    BlockType type = BlockType.paragraph,
    String content = '',
    double? afterPosition,
    double? beforePosition,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _uuid.v4();

    double position;
    if (afterPosition != null && beforePosition != null) {
      position = (afterPosition + beforePosition) / 2;
    } else if (afterPosition != null) {
      position = afterPosition + 1.0;
    } else if (beforePosition != null) {
      position = beforePosition - 1.0;
    } else {
      final last = await (_db.select(_db.blocksTable)
            ..where((b) => b.pageId.equals(pageId))
            ..where((b) => b.deletedAt.isNull())
            ..orderBy([(b) => OrderingTerm.desc(b.position)])
            ..limit(1))
          .getSingleOrNull();
      position = (last?.position ?? 0.0) + 1.0;
    }

    await _db.into(_db.blocksTable).insert(BlocksTableCompanion.insert(
          id: id,
          pageId: pageId,
          type: Value(type.value),
          content: Value(content),
          position: Value(position),
          createdAt: now,
          updatedAt: now,
          isDirty: const Value(true),
          isNew: const Value(true),
        ));

    return id;
  }

  Future<void> updateBlock(
    String id, {
    BlockType? type,
    String? content,
    bool? todoChecked,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // For todos, store checked state in content prefix
    String? newContent = content;
    if (todoChecked != null && type != BlockType.divider) {
      final current = await (_db.select(_db.blocksTable)..where((b) => b.id.equals(id)))
          .getSingleOrNull();
      if (current != null) {
        final stripped = _stripTodoPrefix(current.content);
        newContent = '${todoChecked ? '[x] ' : '[ ] '}$stripped';
      }
    }

    await (_db.update(_db.blocksTable)..where((b) => b.id.equals(id))).write(
      BlocksTableCompanion(
        type: type != null ? Value(type.value) : const Value.absent(),
        content: newContent != null ? Value(newContent) : const Value.absent(),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  /// Reorder a block to a new index within its page.
  /// The provided list is the currently-ordered list of blocks in the same page.
  Future<void> moveBlock(
    String movingBlockId,
    int newIndex,
    List<BlockData> orderedBlocks,
  ) async {
    final others = orderedBlocks.where((b) => b.id != movingBlockId).toList();
    final clampedIndex = newIndex.clamp(0, others.length);

    double newPosition;
    if (others.isEmpty) {
      newPosition = 1.0;
    } else if (clampedIndex == 0) {
      newPosition = others.first.position - 1.0;
    } else if (clampedIndex >= others.length) {
      newPosition = others.last.position + 1.0;
    } else {
      newPosition = (others[clampedIndex - 1].position + others[clampedIndex].position) / 2;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.blocksTable)..where((b) => b.id.equals(movingBlockId))).write(
      BlocksTableCompanion(
        position: Value(newPosition),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  Future<void> deleteBlock(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.blocksTable)..where((b) => b.id.equals(id))).write(
      BlocksTableCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  /// Reverse a soft delete. Content/type/position are untouched by [deleteBlock],
  /// so clearing the tombstone restores the block exactly.
  Future<void> restoreBlock(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.blocksTable)..where((b) => b.id.equals(id))).write(
      BlocksTableCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  /// Ensures the page has at least one block (creates a blank paragraph if none).
  Future<BlockData> ensureFirstBlock(String pageId) async {
    final blocks = await getBlocks(pageId);
    if (blocks.isNotEmpty) return blocks.first;
    final id = await insertBlock(pageId: pageId);
    return (await _db.select(_db.blocksTable).get())
        .where((b) => b.id == id)
        .map(_toData)
        .first;
  }

  BlockData _toData(BlocksTableData row) {
    final type = BlockType.fromString(row.type);
    final content = row.content;
    bool checked = false;
    String cleanContent = content;

    if (type == BlockType.todo) {
      if (content.startsWith('[x] ')) {
        checked = true;
        cleanContent = content.substring(4);
      } else if (content.startsWith('[ ] ')) {
        checked = false;
        cleanContent = content.substring(4);
      }
    }

    return BlockData(
      id: row.id,
      pageId: row.pageId,
      type: type,
      content: cleanContent,
      position: row.position,
      todoChecked: checked,
    );
  }

  String _stripTodoPrefix(String content) {
    if (content.startsWith('[x] ')) return content.substring(4);
    if (content.startsWith('[ ] ')) return content.substring(4);
    return content;
  }
}
