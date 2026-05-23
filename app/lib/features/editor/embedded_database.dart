import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../databases/data/database_repository.dart';
import '../databases/domain/database_model.dart';
import '../databases/domain/database_row_model.dart';
import '../databases/presentation/gallery_view.dart';
import '../pages/data/page_repository.dart';
import '../pages/domain/page_model.dart';
import '../sync/sync_provider.dart';

class EmbeddedDatabase extends ConsumerWidget {
  final String databaseId;
  const EmbeddedDatabase({super.key, required this.databaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final pagesAsync = ref.watch(allPagesProvider);
    final allPages = pagesAsync.maybeWhen(
      data: (pages) => pages,
      orElse: () => const <PageModel>[],
    );
    final databasePage =
        allPages.where((p) => p.id == databaseId).firstOrNull;
    final pageTitles = <String, String>{for (final p in allPages) p.id: p.title};

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
            onOpen: () => context.go('/pages/$databaseId/db'),
            onAddRow: () async {
              await repo.createRow(databaseId);
              ref.read(syncProvider.notifier).triggerDirtySync();
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
                    child: GalleryView(
                      rows: rows,
                      properties: properties,
                      pageTitles: pageTitles,
                      onRowTap: (row) => context.go('/pages/${row.pageId}'),
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
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      child: Row(
        children: [
          const Icon(Icons.grid_view, size: 16, color: Colors.grey),
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
