import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/databases/data/database_repository.dart';
import '../../../features/databases/domain/database_model.dart';
import '../../../features/databases/domain/database_row_model.dart';
import '../../../features/pages/data/page_repository.dart';
import '../../../features/pages/domain/page_model.dart';
import '../../../features/sync/sync_provider.dart';
import 'gallery_view.dart';
import 'table_view.dart';

enum DatabaseView { gallery, table }

class DatabaseScreen extends ConsumerStatefulWidget {
  final String pageId;
  const DatabaseScreen({super.key, required this.pageId});

  @override
  ConsumerState<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends ConsumerState<DatabaseScreen> {
  DatabaseView _currentView = DatabaseView.gallery;
  late final TextEditingController _titleCtrl;
  final FocusNode _titleFocus = FocusNode();
  Timer? _titleSaveTimer;
  String? _loadedTitle;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleSaveTimer?.cancel();
    _titleCtrl.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _onTitleChanged(String value) {
    _titleSaveTimer?.cancel();
    _titleSaveTimer = Timer(const Duration(milliseconds: 400), () async {
      await ref.read(pageRepositoryProvider).updateTitle(widget.pageId, value);
      ref.read(syncProvider.notifier).triggerDirtySync();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allPages = ref.watch(allPagesProvider).maybeWhen(
          data: (pages) => pages,
          orElse: () => const <PageModel>[],
        );
    final page = allPages.where((p) => p.id == widget.pageId).firstOrNull;
    final pageTitles = <String, String>{for (final p in allPages) p.id: p.title};

    // Sync the title controller when the page is loaded or changed externally,
    // but only when the user isn't actively editing it.
    if (page != null && page.title != _loadedTitle && !_titleFocus.hasFocus) {
      _loadedTitle = page.title;
      _titleCtrl.text = page.title;
    }

    final repo = ref.watch(databaseRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () async {
            final repo = ref.read(pageRepositoryProvider);
            final self = await repo.getPage(widget.pageId);
            if (!context.mounted) return;
            final parentId = self?.parentId;
            if (parentId == null) {
              context.go('/pages');
              return;
            }
            final parent = await repo.getPage(parentId);
            if (!context.mounted) return;
            context.go(parent != null && parent.isDatabase
                ? '/pages/$parentId/db'
                : '/pages/$parentId');
          },
        ),
        title: TextField(
          controller: _titleCtrl,
          focusNode: _titleFocus,
          onChanged: _onTitleChanged,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            hintText: 'Untitled database',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Gallery view',
            icon: const Icon(Icons.grid_view),
            color: _currentView == DatabaseView.gallery
                ? Theme.of(context).colorScheme.primary
                : null,
            onPressed: () => setState(() => _currentView = DatabaseView.gallery),
          ),
          IconButton(
            tooltip: 'Table view',
            icon: const Icon(Icons.table_chart),
            color: _currentView == DatabaseView.table
                ? Theme.of(context).colorScheme.primary
                : null,
            onPressed: () => setState(() => _currentView = DatabaseView.table),
          ),
          IconButton(
            tooltip: 'Add row',
            icon: const Icon(Icons.add),
            onPressed: () async {
              await repo.createRow(widget.pageId);
              ref.read(syncProvider.notifier).triggerDirtySync();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<DatabaseProperty>>(
        stream: repo.watchProperties(widget.pageId),
        builder: (context, propsSnap) {
          if (propsSnap.hasError) {
            return Center(child: Text('Error: ${propsSnap.error}'));
          }
          final properties = propsSnap.data ?? const <DatabaseProperty>[];
          return StreamBuilder<List<DatabaseRowModel>>(
            stream: repo.watchRows(widget.pageId),
            builder: (context, rowsSnap) {
              if (rowsSnap.hasError) {
                return Center(child: Text('Error: ${rowsSnap.error}'));
              }
              final rows = rowsSnap.data ?? const <DatabaseRowModel>[];
              return _currentView == DatabaseView.gallery
                  ? GalleryView(
                      rows: rows,
                      properties: properties,
                      pageTitles: pageTitles,
                      onRowTap: (row) => context.go('/pages/${row.pageId}'),
                    )
                  : TableView(
                      databaseId: widget.pageId,
                      rows: rows,
                      properties: properties,
                      onRowTap: (row) => context.go('/pages/${row.pageId}'),
                    );
            },
          );
        },
      ),
    );
  }
}
