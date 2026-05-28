import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/drag_handle.dart';
import '../databases/presentation/database_view.dart';
import '../files/file_repository.dart';
import '../pages/data/page_repository.dart';
import '../sync/sync_provider.dart';
import 'block_repository.dart';
import 'block_types.dart';
import 'block_widget.dart';
import 'embedded_database.dart';
import 'image_block.dart';
import 'markdown_codec.dart';
import 'slash_menu.dart';

class BlockEditor extends ConsumerStatefulWidget {
  final String pageId;
  const BlockEditor({super.key, required this.pageId});

  @override
  ConsumerState<BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends ConsumerState<BlockEditor> {
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, Timer> _saveTimers = {};
  final Map<String, GlobalKey<BlockWidgetState>> _blockKeys = {};

  // Single editor-level undo timeline covering text edits (at debounce
  // granularity), type changes, merges, deletes and inserts. The TextField's
  // own undo is disabled (Cmd+Z is always consumed by the editor).
  final List<_UndoAction> _undoStack = [];
  final List<_UndoAction> _redoStack = [];
  bool _applyingHistory = false;
  Timer? _historyResetTimer;
  final Map<String, void Function()> _pendingSaves = {};

  String? _activeSlashBlockId;
  String _slashQuery = '';
  int _slashFocusedIndex = 0;
  LayerLink? _slashLink;
  Offset _slashLocalOffset = Offset.zero;
  bool _slashOpenAbove = false;
  OverlayEntry? _slashOverlay;

  /// Max height of the slash menu — must match SlashMenu's maxHeight.
  static const double _slashMenuMaxHeight = 320;

  FocusNode _focusFor(String id) {
    return _focusNodes.putIfAbsent(id, FocusNode.new);
  }

  @override
  void dispose() {
    _historyResetTimer?.cancel();
    for (final t in _saveTimers.values) {
      t.cancel();
    }
    for (final n in _focusNodes.values) {
      n.dispose();
    }
    _slashOverlay?.remove();
    super.dispose();
  }

  /// Walks the blocks list from [start] in [step] direction (±1), skipping
  /// past any database (or other non-textual) blocks. Returns null if none.
  BlockData? _findTextBlockAt(List<BlockData> blocks, int start, {required int step}) {
    int i = start;
    while (i >= 0 && i < blocks.length) {
      if (blocks[i].type != BlockType.database &&
          blocks[i].type != BlockType.divider &&
          blocks[i].type != BlockType.image) {
        return blocks[i];
      }
      i += step;
    }
    return null;
  }

  void _debouncedSave(String blockId, void Function() save) {
    _saveTimers[blockId]?.cancel();
    _pendingSaves[blockId] = save;
    _saveTimers[blockId] = Timer(const Duration(milliseconds: 400), () {
      _pendingSaves.remove(blockId);
      save();
      ref.read(syncProvider.notifier).triggerDirtySync();
    });
  }

  void _cancelPendingSave(String blockId) {
    _saveTimers.remove(blockId)?.cancel();
    _pendingSaves.remove(blockId);
  }

  /// Run any pending debounced saves immediately so the latest typing burst is
  /// recorded in the undo timeline before a structural op or an undo.
  void _flushPendingSaves() {
    if (_pendingSaves.isEmpty) return;
    final pending = Map.of(_pendingSaves);
    _pendingSaves.clear();
    for (final t in _saveTimers.values) {
      t.cancel();
    }
    _saveTimers.clear();
    for (final save in pending.values) {
      save();
    }
    ref.read(syncProvider.notifier).triggerDirtySync();
  }

  /// Drop FocusNodes, pending timers, and block keys for blocks that no longer
  /// exist — otherwise they'd accumulate for the lifetime of the page.
  void _pruneState(List<BlockData> currentBlocks) {
    final liveIds = currentBlocks.map((b) => b.id).toSet();
    final stale = _focusNodes.keys.where((id) => !liveIds.contains(id)).toList();
    for (final id in stale) {
      _focusNodes.remove(id)?.dispose();
      _saveTimers.remove(id)?.cancel();
      _blockKeys.remove(id);
    }
  }

  void _focusBlockAfterLayout(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusFor(id).requestFocus();
    });
  }

  void _record({
    required Future<void> Function() undo,
    required Future<void> Function() redo,
  }) {
    if (_applyingHistory) return;
    _undoStack.add(_UndoAction(undo: undo, redo: redo));
    if (_undoStack.length > 200) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  Future<void> _runHistory(Future<void> Function() fn) async {
    _applyingHistory = true;
    _historyResetTimer?.cancel();
    await fn();
    // Keep the guard up long enough to cover the stream-driven rebuild and the
    // content-restore postFrames, so none of them record a spurious entry.
    _historyResetTimer = Timer(const Duration(milliseconds: 150), () {
      _applyingHistory = false;
    });
  }

  void _undo() {
    _flushPendingSaves();
    if (_undoStack.isEmpty) return;
    final action = _undoStack.removeLast();
    _redoStack.add(action);
    _runHistory(action.undo);
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    final action = _redoStack.removeLast();
    _undoStack.add(action);
    _runHistory(action.redo);
  }

  /// Writes [content] to the block and pushes it into the (focused) field,
  /// used when undo/redo restores a block's text.
  Future<void> _restoreContent(String id, String content) async {
    await ref.read(blockRepositoryProvider).updateBlock(id, content: content);
    ref.read(syncProvider.notifier).triggerDirtySync();
    _pushContentToField(id, content);
  }

  Future<void> _restoreTypeAndContent(
      String id, BlockType type, String content) async {
    await ref
        .read(blockRepositoryProvider)
        .updateBlock(id, type: type, content: content);
    ref.read(syncProvider.notifier).triggerDirtySync();
    _pushContentToField(id, content);
  }

  void _pushContentToField(String id, String content) {
    final offset = MarkdownCodec.decode(content).text.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _blockKeys[id]?.currentState?.setContentAndCaret(content, offset);
      }
    });
  }

  void _recordInsert(String id) {
    final repo = ref.read(blockRepositoryProvider);
    _record(
      undo: () async {
        await repo.deleteBlock(id);
        ref.read(syncProvider.notifier).triggerDirtySync();
      },
      redo: () async {
        await repo.restoreBlock(id);
        ref.read(syncProvider.notifier).triggerDirtySync();
        _focusBlockAfterLayout(id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(blockRepositoryProvider);

    return StreamBuilder<List<BlockData>>(
      stream: repo.watchBlocks(widget.pageId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final blocks = snapshot.data ?? const <BlockData>[];
        _pruneState(blocks);
        if (blocks.isEmpty) {
          if (snapshot.connectionState == ConnectionState.active) {
            Future.microtask(() async {
              final current = await repo.getBlocks(widget.pageId);
              if (current.isEmpty) {
                await repo.insertBlock(pageId: widget.pageId);
                ref.read(syncProvider.notifier).triggerDirtySync();
              }
            });
          }
          return const SizedBox.shrink();
        }
        return ReorderableListView.builder(
          padding: const EdgeInsets.only(top: 8),
          buildDefaultDragHandles: false,
          itemCount: blocks.length,
          itemBuilder: (context, i) => _buildBlock(blocks, i),
          onReorder: (oldIndex, newIndex) async {
            final movingBlock = blocks[oldIndex];
            final adjustedIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
            await repo.moveBlock(movingBlock.id, adjustedIndex, blocks);
            ref.read(syncProvider.notifier).triggerDirtySync();
          },
          // Clickable empty space below the last block: tapping it appends a
          // new paragraph, so a trailing database/divider is never a dead end.
          footer: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              final newId = await repo.insertBlock(pageId: widget.pageId);
              ref.read(syncProvider.notifier).triggerDirtySync();
              _focusBlockAfterLayout(newId);
              _recordInsert(newId);
            },
            child: const SizedBox(height: 180),
          ),
        );
      },
    );
  }

  Widget _buildBlock(List<BlockData> blocks, int i) {
    final block = blocks[i];
    final repo = ref.read(blockRepositoryProvider);

    Future<void> deleteBlock() async {
      final deletedId = block.id;
      _cancelPendingSave(deletedId);
      await repo.deleteBlock(deletedId);
      ref.read(syncProvider.notifier).triggerDirtySync();
      _record(
        undo: () async {
          await repo.restoreBlock(deletedId);
          ref.read(syncProvider.notifier).triggerDirtySync();
          _focusBlockAfterLayout(deletedId);
        },
        redo: () async {
          await repo.deleteBlock(deletedId);
          ref.read(syncProvider.notifier).triggerDirtySync();
        },
      );
    }

    if (block.type == BlockType.database) {
      return _DraggableBlock(
        key: ValueKey(block.id),
        index: i,
        onDelete: deleteBlock,
        child: EmbeddedDatabase(blockId: block.id, content: block.content),
      );
    }

    if (block.type == BlockType.image) {
      return _DraggableBlock(
        key: ValueKey(block.id),
        index: i,
        onDelete: deleteBlock,
        child: ImageBlock(blockId: block.id, content: block.content),
      );
    }

    final blockKey = _blockKeys.putIfAbsent(
      block.id,
      () => GlobalKey<BlockWidgetState>(),
    );

    // Number within a run of consecutive numbered-list blocks.
    var listNumber = 1;
    if (block.type == BlockType.numberedList) {
      for (var j = i - 1; j >= 0 && blocks[j].type == BlockType.numberedList; j--) {
        listNumber++;
      }
    }

    return _DraggableBlock(
      key: ValueKey(block.id),
      index: i,
      onDelete: deleteBlock,
      child: BlockWidget(
        key: blockKey,
        type: block.type,
        content: block.content,
        todoChecked: block.todoChecked,
        listNumber: listNumber,
        focusNode: _focusFor(block.id),
        autofocus: false,
        onUndo: _undo,
        onRedo: _redo,
        onContentChanged: (text) {
          if (_applyingHistory) return;
          final id = block.id;
          final oldContent = block.content;
          _debouncedSave(id, () {
            repo.updateBlock(id, content: text);
            _record(
              undo: () => _restoreContent(id, oldContent),
              redo: () => _restoreContent(id, text),
            );
          });
        },
        onTypeChanged: (newType) async {
          final id = block.id;
          final fromType = block.type;
          final oldContent = block.content;
          await repo.updateBlock(id, type: newType, content: '');
          ref.read(syncProvider.notifier).triggerDirtySync();
          _record(
            undo: () => _restoreTypeAndContent(id, fromType, oldContent),
            redo: () => _restoreTypeAndContent(id, newType, ''),
          );
        },
        onTodoCheckedChanged: (checked) async {
          final id = block.id;
          await repo.updateBlock(id, todoChecked: checked);
          ref.read(syncProvider.notifier).triggerDirtySync();
          _record(
            undo: () async {
              await repo.updateBlock(id, todoChecked: !checked);
              ref.read(syncProvider.notifier).triggerDirtySync();
            },
            redo: () async {
              await repo.updateBlock(id, todoChecked: checked);
              ref.read(syncProvider.notifier).triggerDirtySync();
            },
          );
        },
        onEnterPressed: () async {
          final next = i + 1 < blocks.length ? blocks[i + 1] : null;
          // Lists continue their type onto the next block; everything else falls back to paragraph.
          final newType = (block.type == BlockType.bulletedList ||
                  block.type == BlockType.numberedList ||
                  block.type == BlockType.todo)
              ? block.type
              : BlockType.paragraph;
          _flushPendingSaves();
          final newId = await repo.insertBlock(
            pageId: widget.pageId,
            type: newType,
            afterPosition: block.position,
            beforePosition: next?.position,
          );
          ref.read(syncProvider.notifier).triggerDirtySync();
          _focusBlockAfterLayout(newId);
          _recordInsert(newId);
        },
        onBackspaceAtStart: (currentMarkdown) async {
          // First backspace on a styled/list block just turns it back into text.
          if (block.type != BlockType.paragraph) {
            final id = block.id;
            final fromType = block.type;
            await repo.updateBlock(id, type: BlockType.paragraph);
            ref.read(syncProvider.notifier).triggerDirtySync();
            _record(
              undo: () async {
                await repo.updateBlock(id, type: fromType);
                ref.read(syncProvider.notifier).triggerDirtySync();
              },
              redo: () async {
                await repo.updateBlock(id, type: BlockType.paragraph);
                ref.read(syncProvider.notifier).triggerDirtySync();
              },
            );
            return;
          }
          // Merge into the previous block when it's text; don't reach across a
          // database/divider.
          if (i == 0) return;
          final prev = blocks[i - 1];
          if (prev.type == BlockType.database ||
              prev.type == BlockType.divider ||
              prev.type == BlockType.image) {
            return;
          }
          // Commit any in-flight typing in either block first so the merge and
          // its undo capture the real content.
          _flushPendingSaves();
          _cancelPendingSave(block.id);
          final prevId = prev.id;
          final prevOldContent = prev.content;
          final deletedId = block.id;
          final caretOffset = MarkdownCodec.decode(prevOldContent).text.length;
          final merged = prevOldContent + currentMarkdown;
          await repo.updateBlock(prevId, content: merged);
          await repo.deleteBlock(deletedId);
          ref.read(syncProvider.notifier).triggerDirtySync();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _blockKeys[prevId]?.currentState?.setContentAndCaret(merged, caretOffset);
          });
          _record(
            undo: () async {
              await repo.updateBlock(prevId, content: prevOldContent);
              await repo.restoreBlock(deletedId);
              ref.read(syncProvider.notifier).triggerDirtySync();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _blockKeys[prevId]
                    ?.currentState
                    ?.setContentAndCaret(prevOldContent, caretOffset);
                _focusBlockAfterLayout(deletedId);
              });
            },
            redo: () async {
              await repo.updateBlock(prevId, content: merged);
              await repo.deleteBlock(deletedId);
              ref.read(syncProvider.notifier).triggerDirtySync();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _blockKeys[prevId]
                    ?.currentState
                    ?.setContentAndCaret(merged, caretOffset);
              });
            },
          );
        },
        onArrowUpAtStart: (caretX) {
          final prev = _findTextBlockAt(blocks, i - 1, step: -1);
          if (prev == null) return;
          _focusFor(prev.id).requestFocus();
          _blockKeys[prev.id]?.currentState?.placeCaretAtBottomNear(caretX);
        },
        onArrowDownAtEnd: (caretX) {
          final next = _findTextBlockAt(blocks, i + 1, step: 1);
          if (next == null) return;
          _focusFor(next.id).requestFocus();
          _blockKeys[next.id]?.currentState?.placeCaretAtTopNear(caretX);
        },
        onSlashTyped: (text, link, localOffset) {
          _activeSlashBlockId = block.id;
          _slashQuery = '';
          _slashFocusedIndex = 0;
          _slashLink = link;
          _slashLocalOffset = localOffset;
          _showSlashMenu(block.id);
        },
        onSlashQueryChanged: (query) {
          if (_activeSlashBlockId != block.id) return;
          setState(() {
            _slashQuery = query;
            _slashFocusedIndex = 0;
          });
          _updateSlashMenu();
        },
        onSlashDismissed: () {
          if (_activeSlashBlockId != block.id) return;
          _hideSlashMenu();
        },
        onSlashMoveUp: () {
          if (_activeSlashBlockId != block.id) return;
          final opts = filterSlashOptions(_slashQuery);
          if (opts.isEmpty) return;
          setState(() {
            _slashFocusedIndex =
                (_slashFocusedIndex - 1 + opts.length) % opts.length;
          });
          _updateSlashMenu();
        },
        onSlashMoveDown: () {
          if (_activeSlashBlockId != block.id) return;
          final opts = filterSlashOptions(_slashQuery);
          if (opts.isEmpty) return;
          setState(() {
            _slashFocusedIndex = (_slashFocusedIndex + 1) % opts.length;
          });
          _updateSlashMenu();
        },
        onSlashConfirm: () {
          if (_activeSlashBlockId != block.id) return;
          final opts = filterSlashOptions(_slashQuery);
          if (opts.isEmpty) return;
          final selected =
              opts[_slashFocusedIndex.clamp(0, opts.length - 1)];
          _applySlashSelection(block.id, selected);
        },
      ),
    );
  }

  void _showSlashMenu(String blockId) {
    _slashOverlay?.remove();
    final overlay = Overlay.of(context);
    final link = _slashLink;
    if (link == null) return;

    // Flip the menu above the caret when there isn't enough room below it.
    _slashOpenAbove = false;
    final focusNode = _focusFor(blockId);
    final box = focusNode.context?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final caretBottomGlobal = box.localToGlobal(Offset(0, _slashLocalOffset.dy)).dy;
      final screenHeight = MediaQuery.of(context).size.height;
      const buffer = 16.0;
      if (screenHeight - caretBottomGlobal < _slashMenuMaxHeight + buffer) {
        _slashOpenAbove = true;
      }
    }

    final openAbove = _slashOpenAbove;
    final caretTopY = _slashLocalOffset.dy - _approxLineHeight;
    final followerOffset = openAbove
        ? Offset(_slashLocalOffset.dx, caretTopY - 4)
        : Offset(_slashLocalOffset.dx, _slashLocalOffset.dy + 4);

    _slashOverlay = OverlayEntry(
      builder: (ctx) => Positioned(
        left: 0,
        top: 0,
        child: CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          followerAnchor: openAbove ? Alignment.bottomLeft : Alignment.topLeft,
          offset: followerOffset,
          child: Material(
            color: Colors.transparent,
            child: SlashMenu(
              options: filterSlashOptions(_slashQuery),
              focusedIndex: _slashFocusedIndex,
              onSelect: (type) => _applySlashSelection(blockId, type),
              onHover: (i) {
                if (_slashFocusedIndex != i) {
                  setState(() => _slashFocusedIndex = i);
                  _updateSlashMenu();
                }
              },
            ),
          ),
        ),
      ),
    );
    overlay.insert(_slashOverlay!);
  }

  static const double _approxLineHeight = 16 * 1.6;

  void _updateSlashMenu() {
    if (_slashOverlay != null) {
      _slashOverlay!.markNeedsBuild();
    }
  }

  void _hideSlashMenu() {
    _slashOverlay?.remove();
    _slashOverlay = null;
    _activeSlashBlockId = null;
    _slashQuery = '';
    _slashFocusedIndex = 0;
    _slashLink = null;
    _slashLocalOffset = Offset.zero;
  }

  Future<void> _applySlashSelection(String blockId, BlockType type) async {
    _hideSlashMenu();
    _blockKeys[blockId]?.currentState?.onSlashConfirmed();
    // onSlashConfirmed clears the controller text, which the listener catches
    // and schedules a debounced save with content=''. We're about to set the
    // block's content directly, so cancel that pending save or it would race
    // and overwrite us 400 ms later.
    _cancelPendingSave(blockId);

    final repo = ref.read(blockRepositoryProvider);

    final isDatabase = type == BlockType.databaseTable ||
        type == BlockType.databaseGallery;
    final isImage = type == BlockType.image;

    if (isDatabase) {
      final pageRepo = ref.read(pageRepositoryProvider);
      final dbPage = await pageRepo.createPage(
        isDatabase: true,
        parentId: widget.pageId,
      );
      final view = type == BlockType.databaseTable
          ? DatabaseView.table
          : DatabaseView.gallery;
      await repo.updateBlock(
        blockId,
        type: BlockType.database,
        content: encodeDatabaseBlock(dbPage.id, view),
      );
    } else if (isImage) {
      await repo.updateBlock(blockId, type: BlockType.image, content: '');
    } else {
      await repo.updateBlock(blockId, type: type, content: '');
    }

    // Non-text blocks (database/image) have no text field, so append an empty
    // paragraph after them and focus there — otherwise they're a dead end.
    if (isDatabase || isImage) {
      final blocks = await repo.getBlocks(widget.pageId);
      final idx = blocks.indexWhere((b) => b.id == blockId);
      final next = idx != -1 && idx + 1 < blocks.length ? blocks[idx + 1] : null;
      final newId = await repo.insertBlock(
        pageId: widget.pageId,
        afterPosition: idx != -1 ? blocks[idx].position : null,
        beforePosition: next?.position,
      );
      _focusBlockAfterLayout(newId);
    }

    ref.read(syncProvider.notifier).triggerDirtySync();
    if (!isDatabase && !isImage) _focusFor(blockId).requestFocus();

    // Open the picker right away so the slash flow feels like one action.
    if (isImage) {
      try {
        final id = await ref.read(fileRepositoryProvider).pickAndUploadImage();
        if (id != null) {
          await repo.updateBlock(blockId, content: id);
          ref.read(syncProvider.notifier).triggerDirtySync();
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Couldn't upload image")),
          );
        }
      }
    }
  }
}

class _UndoAction {
  final Future<void> Function() undo;
  final Future<void> Function() redo;
  _UndoAction({required this.undo, required this.redo});
}

class _DraggableBlock extends StatefulWidget {
  final int index;
  final Widget child;
  final VoidCallback onDelete;
  const _DraggableBlock({
    super.key,
    required this.index,
    required this.child,
    required this.onDelete,
  });

  @override
  State<_DraggableBlock> createState() => _DraggableBlockState();
}

class _DraggableBlockState extends State<_DraggableBlock> {
  bool _hovered = false;
  final GlobalKey _handleKey = GlobalKey();

  Future<void> _showMenu() async {
    final box = _handleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final bottomRight =
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay);

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(topLeft, bottomRight),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
    if (result == 'delete') widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tap the handle to open the block menu, drag it to reorder.
            DragHandle(
              index: widget.index,
              visible: _hovered,
              padding: const EdgeInsets.only(top: 6),
              onTap: _showMenu,
              handleKey: _handleKey,
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
