import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/data/page_repository.dart';
import '../sync/sync_provider.dart';
import 'block_repository.dart';
import 'block_types.dart';
import 'block_widget.dart';
import 'embedded_database.dart';
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
          blocks[i].type != BlockType.divider) {
        return blocks[i];
      }
      i += step;
    }
    return null;
  }

  void _debouncedSave(String blockId, void Function() save) {
    _saveTimers[blockId]?.cancel();
    _saveTimers[blockId] = Timer(const Duration(milliseconds: 400), () {
      save();
      ref.read(syncProvider.notifier).triggerDirtySync();
    });
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
          padding: const EdgeInsets.only(bottom: 200, top: 8),
          buildDefaultDragHandles: false,
          itemCount: blocks.length,
          itemBuilder: (context, i) => _buildBlock(blocks, i),
          onReorder: (oldIndex, newIndex) async {
            final movingBlock = blocks[oldIndex];
            final adjustedIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
            await repo.moveBlock(movingBlock.id, adjustedIndex, blocks);
            ref.read(syncProvider.notifier).triggerDirtySync();
          },
        );
      },
    );
  }

  Widget _buildBlock(List<BlockData> blocks, int i) {
    final block = blocks[i];
    final repo = ref.read(blockRepositoryProvider);

    if (block.type == BlockType.database) {
      return _DraggableBlock(
        key: ValueKey(block.id),
        index: i,
        child: EmbeddedDatabase(databaseId: block.content),
      );
    }

    final blockKey = _blockKeys.putIfAbsent(
      block.id,
      () => GlobalKey<BlockWidgetState>(),
    );

    return _DraggableBlock(
      key: ValueKey(block.id),
      index: i,
      child: BlockWidget(
        key: blockKey,
        type: block.type,
        content: block.content,
        todoChecked: block.todoChecked,
        focusNode: _focusFor(block.id),
        autofocus: false,
        onContentChanged: (text) {
          _debouncedSave(block.id, () => repo.updateBlock(block.id, content: text));
        },
        onTypeChanged: (newType) async {
          await repo.updateBlock(block.id, type: newType, content: '');
          ref.read(syncProvider.notifier).triggerDirtySync();
        },
        onTodoCheckedChanged: (checked) async {
          await repo.updateBlock(block.id, todoChecked: checked);
          ref.read(syncProvider.notifier).triggerDirtySync();
        },
        onEnterPressed: () async {
          final next = i + 1 < blocks.length ? blocks[i + 1] : null;
          // Lists continue their type onto the next block; everything else falls back to paragraph.
          final newType = (block.type == BlockType.bulletedList ||
                  block.type == BlockType.numberedList ||
                  block.type == BlockType.todo)
              ? block.type
              : BlockType.paragraph;
          final newId = await repo.insertBlock(
            pageId: widget.pageId,
            type: newType,
            afterPosition: block.position,
            beforePosition: next?.position,
          );
          ref.read(syncProvider.notifier).triggerDirtySync();
          _focusBlockAfterLayout(newId);
        },
        onBackspaceEmpty: () async {
          // Convert non-paragraph blocks back to paragraph before deleting.
          if (block.type != BlockType.paragraph) {
            await repo.updateBlock(block.id, type: BlockType.paragraph);
            ref.read(syncProvider.notifier).triggerDirtySync();
            return;
          }
          if (blocks.length <= 1) return;
          final prev = i > 0 ? blocks[i - 1] : null;
          await repo.deleteBlock(block.id);
          ref.read(syncProvider.notifier).triggerDirtySync();
          if (prev != null) _focusBlockAfterLayout(prev.id);
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
    _saveTimers.remove(blockId)?.cancel();

    final repo = ref.read(blockRepositoryProvider);

    if (type == BlockType.database) {
      final pageRepo = ref.read(pageRepositoryProvider);
      final dbPage = await pageRepo.createPage(
        isDatabase: true,
        parentId: widget.pageId,
      );
      await repo.updateBlock(blockId, type: type, content: dbPage.id);
    } else {
      await repo.updateBlock(blockId, type: type, content: '');
    }

    ref.read(syncProvider.notifier).triggerDirtySync();
    if (type != BlockType.database) _focusFor(blockId).requestFocus();
  }
}

class _DraggableBlock extends StatefulWidget {
  final int index;
  final Widget child;
  const _DraggableBlock({super.key, required this.index, required this.child});

  @override
  State<_DraggableBlock> createState() => _DraggableBlockState();
}

class _DraggableBlockState extends State<_DraggableBlock> {
  bool _hovered = false;

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
            SizedBox(
              width: 24,
              child: AnimatedOpacity(
                opacity: _hovered ? 0.6 : 0.0,
                duration: const Duration(milliseconds: 120),
                child: ReorderableDragStartListener(
                  index: widget.index,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.grab,
                      child: Icon(Icons.drag_indicator, size: 18, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
