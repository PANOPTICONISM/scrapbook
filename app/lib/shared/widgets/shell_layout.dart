import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/pages/data/page_repository.dart';
import '../../features/pages/domain/page_model.dart';
import '../../features/sync/sync_provider.dart';

enum _DropZone { before, inside, after }

/// Tracks the currently-dragging page id so the entire subtree can be dimmed.
final ValueNotifier<String?> _draggingPageId = ValueNotifier<String?>(null);

class ShellLayout extends ConsumerWidget {
  final Widget child;
  const ShellLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 700;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(width: 260, child: _Sidebar()),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: SizedBox(width: 280, child: Drawer(child: _Sidebar())),
      appBar: AppBar(title: const Text('Scrapbook'), centerTitle: false),
      body: child,
    );
  }
}

class _Sidebar extends ConsumerStatefulWidget {
  @override
  ConsumerState<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<_Sidebar> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(allPagesProvider);
    final syncStatus = ref.watch(syncProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
          child: Row(
            children: [
              const Text('Scrapbook',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              _SyncIndicator(syncStatus),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search pages...',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(width: 1),
              ),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.article_outlined, size: 18),
                  title: const Text('New Page'),
                  onTap: () async {
                    final repo = ref.read(pageRepositoryProvider);
                    final page = await repo.createPage();
                    ref.read(syncProvider.notifier).triggerDirtySync();
                    if (context.mounted) context.go('/pages/${page.id}');
                  },
                ),
              ),
              IconButton(
                tooltip: 'New Database',
                icon: const Icon(Icons.grid_view_outlined, size: 18),
                onPressed: () async {
                  final repo = ref.read(pageRepositoryProvider);
                  final page = await repo.createPage(isDatabase: true);
                  ref.read(syncProvider.notifier).triggerDirtySync();
                  if (context.mounted) context.go('/pages/${page.id}/db');
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: pages.when(
            data: (list) => _PageTree(pages: list, searchQuery: _searchQuery),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
        const Divider(height: 1),
        _TrashSidebarEntry(),
      ],
    );
  }
}

class _TrashSidebarEntry extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(pageRepositoryProvider);
    return StreamBuilder<List<PageModel>>(
      stream: repo.watchTrash(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return ListTile(
          dense: true,
          leading: const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(Icons.delete_outline, size: 18, color: Colors.grey),
          ),
          title: const Text('Trash', style: TextStyle(fontSize: 14)),
          trailing: count > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$count', style: const TextStyle(fontSize: 11)),
                )
              : null,
          onTap: () => context.go('/trash'),
        );
      },
    );
  }
}

class _PageTree extends ConsumerWidget {
  final List<PageModel> pages;
  final String searchQuery;
  const _PageTree({required this.pages, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentById = <String, String?>{
      for (final p in pages) p.id: p.parentId,
    };

    if (searchQuery.isNotEmpty) {
      final matches = pages
          .where((p) => p.title.toLowerCase().contains(searchQuery))
          .toList();
      if (matches.isEmpty) {
        return const Center(
          child: Text('No matches', style: TextStyle(color: Colors.grey)),
        );
      }
      return ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, i) => _PageTile(
          page: matches[i],
          allPages: const [],
          parentById: parentById,
          depth: 0,
        ),
      );
    }

    final roots = pages.where((p) => p.parentId == null).toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    return ListView(
      children: [
        if (roots.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No pages yet', style: TextStyle(color: Colors.grey))),
          )
        else
          ...roots.map((p) => _PageTile(
                page: p,
                allPages: pages,
                parentById: parentById,
                depth: 0,
              )),
        _RootDropZone(allPages: pages),
      ],
    );
  }
}

/// A drop target at the very bottom of the page tree that promotes a dragged
/// page to a root-level item (parent_id = null) appended at the end.
class _RootDropZone extends ConsumerStatefulWidget {
  final List<PageModel> allPages;
  const _RootDropZone({required this.allPages});

  @override
  ConsumerState<_RootDropZone> createState() => _RootDropZoneState();
}

class _RootDropZoneState extends ConsumerState<_RootDropZone> {
  bool _hover = false;

  bool _isAlreadyRoot(String? draggedId) {
    if (draggedId == null) return false;
    final page = widget.allPages.where((p) => p.id == draggedId).firstOrNull;
    return page?.parentId == null;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !_isAlreadyRoot(details.data),
      onMove: (_) {
        if (!_hover) setState(() => _hover = true);
      },
      onLeave: (_) => setState(() => _hover = false),
      onAcceptWithDetails: (details) async {
        setState(() => _hover = false);
        final repo = ref.read(pageRepositoryProvider);
        final roots = widget.allPages
            .where((p) => p.parentId == null && p.id != details.data)
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));
        await repo.movePage(
          pageId: details.data,
          newParentId: null,
          newIndex: roots.length,
          siblings: roots,
        );
        ref.read(syncProvider.notifier).triggerDirtySync();
      },
      builder: (context, candidate, _) {
        final highlighted = _hover && candidate.isNotEmpty;
        return Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: highlighted ? Theme.of(context).colorScheme.primary : Colors.transparent,
              style: BorderStyle.solid,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
            color: highlighted
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                : null,
          ),
          alignment: Alignment.center,
          child: candidate.isNotEmpty
              ? const Text('Drop here for top-level',
                  style: TextStyle(fontSize: 12, color: Colors.grey))
              : null,
        );
      },
    );
  }
}

class _PageTile extends ConsumerStatefulWidget {
  final PageModel page;
  final List<PageModel> allPages;
  final Map<String, String?> parentById;
  final int depth;

  const _PageTile({
    required this.page,
    required this.allPages,
    required this.parentById,
    required this.depth,
  });

  @override
  ConsumerState<_PageTile> createState() => _PageTileState();
}

class _PageTileState extends ConsumerState<_PageTile> {
  bool _hovered = false;
  _DropZone? _hoverZone;
  final GlobalKey _dropTargetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    final children = widget.allPages.where((p) => p.parentId == page.id).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    final route = page.isDatabase ? '/pages/${page.id}/db' : '/pages/${page.id}';

    final dragData = Draggable<String>(
      data: page.id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => _draggingPageId.value = page.id,
      onDragEnd: (_) => _draggingPageId.value = null,
      onDraggableCanceled: (_, _) => _draggingPageId.value = null,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: const BoxConstraints(maxWidth: 240),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(page.icon ?? (page.isDatabase ? '🗃' : '📄')),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  page.title.isEmpty ? 'Untitled' : page.title,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      child: const MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
      ),
    );

    final subtree = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _wrapAsDropTarget(
          MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              onSecondaryTapUp: (details) => _showContextMenu(context, details.globalPosition),
              child: _buildTile(page, route, dragHandle: dragData),
            ),
          ),
        ),
        ...children.map((child) => _PageTile(
              page: child,
              allPages: widget.allPages,
              parentById: widget.parentById,
              depth: widget.depth + 1,
            )),
      ],
    );

    // Precompute the ancestry chain so the drag-listener can decide whether
    // to dim this subtree in O(1) on every drag-tick rebuild.
    final ancestry = <String>{widget.page.id};
    String? cursor = widget.parentById[widget.page.id];
    while (cursor != null) {
      ancestry.add(cursor);
      cursor = widget.parentById[cursor];
    }

    return ValueListenableBuilder<String?>(
      valueListenable: _draggingPageId,
      builder: (context, draggingId, child) {
        final dim = draggingId != null && ancestry.contains(draggingId);
        return IgnorePointer(
          ignoring: dim,
          child: Opacity(opacity: dim ? 0.4 : 1.0, child: child),
        );
      },
      child: subtree,
    );
  }

  Widget _buildTile(PageModel page, String route, {required Widget dragHandle}) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(left: 4.0 + widget.depth * 16, right: 8),
      leading: SizedBox(
        width: 44,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              child: AnimatedOpacity(
                opacity: _hovered ? 0.7 : 0.0,
                duration: const Duration(milliseconds: 120),
                child: dragHandle,
              ),
            ),
            const SizedBox(width: 4),
            Text(page.icon ?? (page.isDatabase ? '🗃' : '📄'),
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      title: Text(
        page.title.isEmpty ? 'Untitled' : page.title,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _hovered
          ? IconButton(
              icon: const Icon(Icons.more_horiz, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                final renderBox = context.findRenderObject() as RenderBox?;
                final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
                _showContextMenu(context, offset);
              },
            )
          : null,
      onTap: () => context.go(route),
    );
  }

  /// Wraps a tile with three drop zones: top (insert above as sibling),
  /// middle (nest as child), bottom (insert below as sibling).
  /// Returns true if `draggedId` is already a direct child of this tile —
  /// in that case before/after drops on this tile would un-nest the page,
  /// which is rarely what the user wants. We treat all zones as no-op (inside).
  bool _draggedIsOwnChild(String draggedId) {
    final dragged = widget.allPages.where((p) => p.id == draggedId).firstOrNull;
    return dragged?.parentId == widget.page.id;
  }

  Widget _wrapAsDropTarget(Widget child) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data != widget.page.id,
      onMove: (details) {
        final box = _dropTargetKey.currentContext?.findRenderObject() as RenderBox?;
        if (box == null) return;
        final local = box.globalToLocal(details.offset);
        final h = box.size.height;
        // When dragging a child onto its own parent, only trigger un-nest on a
        // 4px edge band — middle of the tile stays a no-op so it doesn't escape
        // by accident. Otherwise use the standard 25%/50%/25% zones.
        final isOwnChild = _draggedIsOwnChild(details.data);
        final edgePx = isOwnChild ? 4.0 : h * 0.25;
        _DropZone zone;
        if (local.dy < edgePx) {
          zone = _DropZone.before;
        } else if (local.dy > h - edgePx) {
          zone = _DropZone.after;
        } else {
          zone = _DropZone.inside;
        }
        if (_hoverZone != zone) setState(() => _hoverZone = zone);
      },
      onLeave: (_) => setState(() => _hoverZone = null),
      onAcceptWithDetails: (details) async {
        final zone = _hoverZone ?? _DropZone.inside;
        setState(() => _hoverZone = null);
        await _handleDrop(details.data, zone);
      },
      builder: (context, candidate, rejected) {
        final color = Theme.of(context).colorScheme.primary;
        final showInside = _hoverZone == _DropZone.inside && candidate.isNotEmpty;
        // Material (not ColoredBox) so the underlying ListTile splashes show through.
        final tile = Material(
          color: showInside ? color.withValues(alpha: 0.10) : Colors.transparent,
          child: child,
        );
        return Column(
          key: _dropTargetKey,
          children: [
            Container(
              height: 2,
              color: (_hoverZone == _DropZone.before && candidate.isNotEmpty) ? color : Colors.transparent,
              margin: EdgeInsets.only(left: 16.0 + widget.depth * 16, right: 16),
            ),
            tile,
            Container(
              height: 2,
              color: (_hoverZone == _DropZone.after && candidate.isNotEmpty) ? color : Colors.transparent,
              margin: EdgeInsets.only(left: 16.0 + widget.depth * 16, right: 16),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDrop(String draggedId, _DropZone zone) async {
    final repo = ref.read(pageRepositoryProvider);
    final allPages = widget.allPages;

    String? newParentId;
    int newIndex;

    if (zone == _DropZone.inside) {
      if (_draggedIsOwnChild(draggedId)) return;
      newParentId = widget.page.id;
      final siblings = allPages
          .where((p) => p.parentId == newParentId && p.id != draggedId)
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position));
      newIndex = siblings.length;
      await repo.movePage(
        pageId: draggedId,
        newParentId: newParentId,
        newIndex: newIndex,
        siblings: siblings,
      );
    } else {
      newParentId = widget.page.parentId;
      final siblings = allPages
          .where((p) => p.parentId == newParentId && p.id != draggedId)
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position));
      final targetIndex = siblings.indexWhere((p) => p.id == widget.page.id);
      newIndex = zone == _DropZone.before ? targetIndex : targetIndex + 1;
      await repo.movePage(
        pageId: draggedId,
        newParentId: newParentId,
        newIndex: newIndex,
        siblings: siblings,
      );
    }

    ref.read(syncProvider.notifier).triggerDirtySync();
  }

  Future<void> _showContextMenu(BuildContext context, Offset position) async {
    final router = GoRouter.of(context);
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx, position.dy, position.dx + 200, position.dy + 200,
      ),
      items: [
        const PopupMenuItem(value: 'rename', child: Row(
          children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Rename')],
        )),
        if (!widget.page.isDatabase)
          const PopupMenuItem(value: 'add_child', child: Row(
            children: [Icon(Icons.subdirectory_arrow_right, size: 16), SizedBox(width: 8), Text('Add sub-page')],
          )),
        const PopupMenuItem(value: 'delete', child: Row(
          children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.red))],
        )),
      ],
    );

    if (!mounted) return;

    switch (result) {
      case 'rename':
        _showRenameDialog();
      case 'add_child':
        final newPage = await ref
            .read(pageRepositoryProvider)
            .createPage(parentId: widget.page.id);
        ref.read(syncProvider.notifier).triggerDirtySync();
        router.go('/pages/${newPage.id}');
      case 'delete':
        _confirmDelete();
    }
  }

  void _showRenameDialog() {
    final ctrl = TextEditingController(text: widget.page.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename page'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref.read(pageRepositoryProvider)
                  .updateTitle(widget.page.id, ctrl.text.trim());
              ref.read(syncProvider.notifier).triggerDirtySync();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete page?'),
        content: Text(
          widget.page.title.isEmpty
              ? 'Delete this untitled page?'
              : 'Delete "${widget.page.title}"?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final router = GoRouter.of(ctx);
              await ref.read(pageRepositoryProvider).deletePage(widget.page.id);
              ref.read(syncProvider.notifier).triggerDirtySync();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                router.go('/pages');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SyncIndicator extends StatelessWidget {
  final AsyncValue<SyncStatus> status;
  const _SyncIndicator(this.status);

  @override
  Widget build(BuildContext context) {
    return status.when(
      data: (s) => switch (s) {
        SyncStatus.idle => const Icon(Icons.cloud_done, size: 16, color: Colors.green),
        SyncStatus.syncing => const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2)),
        SyncStatus.error => const Icon(Icons.cloud_off, size: 16, color: Colors.red),
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const Icon(Icons.cloud_off, size: 16, color: Colors.red),
    );
  }
}
