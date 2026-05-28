import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../databases/data/database_repository.dart';
import '../databases/domain/database_model.dart';
import '../databases/domain/database_row_model.dart';
import '../databases/presentation/database_view.dart';
import '../databases/presentation/gallery_view.dart';
import '../databases/presentation/property_ui.dart';
import '../databases/presentation/table_view.dart';
import '../files/file_repository.dart';
import '../pages/data/page_repository.dart';
import '../pages/domain/page_model.dart';
import '../sync/sync_provider.dart';
import 'block_repository.dart';

class EmbeddedDatabase extends ConsumerWidget {
  final String blockId;
  final String content;
  const EmbeddedDatabase({
    super.key,
    required this.blockId,
    required this.content,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = parseDatabaseBlock(content);
    final databaseId = config.databaseId;

    if (databaseId.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Database link missing.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    final repo = ref.watch(databaseRepositoryProvider);
    final allPages = ref.watch(allPagesProvider).maybeWhen(
          data: (pages) => pages,
          orElse: () => const <PageModel>[],
        );
    final databasePage = allPages.where((p) => p.id == databaseId).firstOrNull;
    final pageTitles = <String, String>{for (final p in allPages) p.id: p.title};
    final pageIcons = <String, String>{
      for (final p in allPages) p.id: p.icon ?? ''
    };
    final pageCovers = <String, String>{
      for (final p in allPages)
        if (p.cover != null) p.id: p.cover!
    };
    final serverConfig = ref
        .watch(serverConfigProvider)
        .maybeWhen(data: (c) => c, orElse: () => null);

    void writeConfig(DatabaseBlockConfig next) {
      ref.read(blockRepositoryProvider).updateBlock(blockId, content: next.encode());
      ref.read(syncProvider.notifier).triggerDirtySync();
    }

    final view = config.activeView;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            databaseId: databaseId,
            initialTitle: databasePage?.title ?? '',
            onOpen: () => context.go('/pages/$databaseId/db?view=${view.name}'),
            onAddRow: () async {
              await repo.createRow(databaseId);
              ref.read(syncProvider.notifier).triggerDirtySync();
            },
          ),
          _ViewTabs(
            views: config.views,
            active: config.active,
            onSelect: (i) => writeConfig(config.copyWith(active: i)),
            onAdd: (v) => writeConfig(
              config.copyWith(views: [...config.views, v], active: config.views.length),
            ),
            onRemove: (i) {
              if (config.views.length <= 1) return;
              final views = [...config.views]..removeAt(i);
              final active = config.active >= views.length
                  ? views.length - 1
                  : config.active;
              writeConfig(config.copyWith(views: views, active: active));
            },
          ),
          const Divider(height: 1),
          StreamBuilder<List<DatabaseProperty>>(
            stream: repo.watchProperties(databaseId),
            builder: (context, propsSnap) {
              if (propsSnap.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${propsSnap.error}'),
                );
              }
              final properties = propsSnap.data ?? const <DatabaseProperty>[];
              return StreamBuilder<List<DatabaseRowModel>>(
                stream: repo.watchRows(databaseId),
                builder: (context, rowsSnap) {
                  if (rowsSnap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: ${rowsSnap.error}'),
                    );
                  }
                  final rows = rowsSnap.data ?? const <DatabaseRowModel>[];
                  return SizedBox(
                    height: rows.isEmpty ? 120 : 320,
                    child: view == DatabaseView.table
                        ? TableView(
                            databaseId: databaseId,
                            rows: rows,
                            properties: properties,
                            pageTitles: pageTitles,
                            onRowTap: (row) =>
                                context.go('/pages/${row.pageId}'),
                          )
                        : GalleryView(
                            rows: rows,
                            properties: properties,
                            pageTitles: pageTitles,
                            pageIcons: pageIcons,
                            pageCovers: pageCovers,
                            serverConfig: serverConfig,
                            onRowTap: (row) =>
                                context.go('/pages/${row.pageId}'),
                          ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ViewTabs extends StatefulWidget {
  final List<DatabaseView> views;
  final int active;
  final void Function(int) onSelect;
  final void Function(DatabaseView) onAdd;
  final void Function(int) onRemove;

  const _ViewTabs({
    required this.views,
    required this.active,
    required this.onSelect,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_ViewTabs> createState() => _ViewTabsState();
}

class _ViewTabsState extends State<_ViewTabs> {
  final GlobalKey _addKey = GlobalKey();

  Future<void> _showAddMenu() async {
    final pos = menuPositionFor(_addKey, context);
    if (pos == null) return;
    final result = await showMenu<DatabaseView>(
      context: context,
      position: pos,
      items: [
        for (final v in DatabaseView.values)
          PopupMenuItem(
            value: v,
            child: Row(children: [
              Icon(databaseViewIcon(v), size: 16, color: Colors.grey),
              const SizedBox(width: 10),
              Text(databaseViewLabel(v)),
            ]),
          ),
      ],
    );
    if (result != null) widget.onAdd(result);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: widget.views.length,
              itemBuilder: (context, i) {
                final v = widget.views[i];
                final selected = i == widget.active;
                return GestureDetector(
                  onLongPress: widget.views.length > 1
                      ? () => widget.onRemove(i)
                      : null,
                  child: InkWell(
                    onTap: () => widget.onSelect(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 2,
                            color: selected ? primary : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(databaseViewIcon(v),
                              size: 14,
                              color: selected ? primary : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            databaseViewLabel(v),
                            style: TextStyle(
                              fontSize: 13,
                              color: selected ? primary : Colors.grey,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            key: _addKey,
            tooltip: 'Add view',
            icon: const Icon(Icons.add, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: _showAddMenu,
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerStatefulWidget {
  final String databaseId;
  final String initialTitle;
  final VoidCallback onOpen;
  final VoidCallback onAddRow;

  const _Header({
    required this.databaseId,
    required this.initialTitle,
    required this.onOpen,
    required this.onAddRow,
  });

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  late final TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialTitle);
  }

  @override
  void didUpdateWidget(_Header old) {
    super.didUpdateWidget(old);
    if (widget.initialTitle != _ctrl.text && !_focus.hasFocus) {
      _ctrl.text = widget.initialTitle;
    }
  }

  void _onChanged(String value) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), () async {
      await ref.read(pageRepositoryProvider).updateTitle(widget.databaseId, value);
      ref.read(syncProvider.notifier).triggerDirtySync();
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 0),
      child: Row(
        children: [
          const Icon(Icons.storage, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              onChanged: _onChanged,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Untitled database',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Add row',
            icon: const Icon(Icons.add, size: 18),
            onPressed: widget.onAddRow,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Open as page',
            icon: const Icon(Icons.open_in_new, size: 16),
            onPressed: widget.onOpen,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
