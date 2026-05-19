import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/sync_provider.dart';
import 'block_repository.dart';
import 'block_types.dart';
import 'block_widget.dart';
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

  String? _activeSlashBlockId;
  String _slashQuery = '';
  OverlayEntry? _slashOverlay;

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

  void _debouncedSave(String blockId, void Function() save) {
    _saveTimers[blockId]?.cancel();
    _saveTimers[blockId] = Timer(const Duration(milliseconds: 400), () {
      save();
      ref.read(syncProvider.notifier).triggerDirtySync();
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
        if (blocks.isEmpty) {
          // Ensure first block exists (only once)
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
            // ReorderableListView passes a newIndex that's incremented by 1 when moving down
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

    return _DraggableBlock(
      key: ValueKey(block.id),
      index: i,
      child: BlockWidget(
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
          // After lists, continue the list type
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
          // Focus the new block on next frame
          Future.delayed(const Duration(milliseconds: 50), () {
            _focusFor(newId).requestFocus();
          });
        },
        onBackspaceEmpty: () async {
          // If the block type isn't paragraph, convert to paragraph first
          if (block.type != BlockType.paragraph) {
            await repo.updateBlock(block.id, type: BlockType.paragraph);
            ref.read(syncProvider.notifier).triggerDirtySync();
            return;
          }
          // Otherwise delete the block and move focus to previous
          if (blocks.length <= 1) return; // never delete last block
          final prev = i > 0 ? blocks[i - 1] : null;
          await repo.deleteBlock(block.id);
          ref.read(syncProvider.notifier).triggerDirtySync();
          if (prev != null) {
            Future.delayed(const Duration(milliseconds: 50), () {
              _focusFor(prev.id).requestFocus();
            });
          }
        },
        onSlashTyped: (text, _) {
          _activeSlashBlockId = block.id;
          _slashQuery = '';
          _showSlashMenu(block.id);
        },
        onSlashQueryChanged: (query) {
          if (_activeSlashBlockId != block.id) return;
          setState(() => _slashQuery = query);
          _updateSlashMenu();
        },
        onSlashDismissed: () {
          if (_activeSlashBlockId != block.id) return;
          _hideSlashMenu();
        },
      ),
    );
  }

  void _showSlashMenu(String blockId) {
    _slashOverlay?.remove();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final focusNode = _focusFor(blockId);
    final blockContext = focusNode.context;
    if (blockContext == null) return;
    final blockBox = blockContext.findRenderObject() as RenderBox?;
    if (blockBox == null) return;

    final blockOffset = blockBox.localToGlobal(Offset.zero);
    final blockSize = blockBox.size;

    _slashOverlay = OverlayEntry(
      builder: (ctx) => Positioned(
        left: blockOffset.dx,
        top: blockOffset.dy + blockSize.height + 4,
        child: Material(
          color: Colors.transparent,
          child: SlashMenu(
            query: _slashQuery,
            onSelect: (type) => _applySlashSelection(blockId, type),
            onDismiss: _hideSlashMenu,
          ),
        ),
      ),
    );
    overlay.insert(_slashOverlay!);
  }

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
  }

  Future<void> _applySlashSelection(String blockId, BlockType type) async {
    _hideSlashMenu();
    final repo = ref.read(blockRepositoryProvider);
    // Clear the slash query text and set new type
    await repo.updateBlock(blockId, type: type, content: '');
    ref.read(syncProvider.notifier).triggerDirtySync();
    Future.delayed(const Duration(milliseconds: 50), () {
      _focusFor(blockId).requestFocus();
    });
  }
}

/// Wraps a block with a drag handle that appears on hover (left gutter).
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
            // Drag handle gutter
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
