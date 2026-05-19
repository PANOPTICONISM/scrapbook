import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/databases/data/database_repository.dart';
import '../../../features/databases/domain/database_model.dart';
import '../../../features/databases/domain/database_row_model.dart';
import '../../../features/pages/data/page_repository.dart';
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

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(allPagesProvider).when(
          data: (pages) => pages.where((p) => p.id == widget.pageId).firstOrNull,
          loading: () => null,
          error: (_, _) => null,
        );

    final repo = ref.watch(databaseRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(page == null || page.title.isEmpty ? 'Untitled' : page.title),
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
