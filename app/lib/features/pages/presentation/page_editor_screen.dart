import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/databases/presentation/row_properties_panel.dart';
import '../../../features/editor/block_editor.dart';
import '../../../features/sync/sync_provider.dart';
import '../data/page_repository.dart';

class PageEditorScreen extends ConsumerStatefulWidget {
  final String pageId;
  const PageEditorScreen({super.key, required this.pageId});

  @override
  ConsumerState<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends ConsumerState<PageEditorScreen> {
  late TextEditingController _titleController;
  Timer? _saveTimer;
  String? _loadedPageId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _loadTitle();
  }

  @override
  void didUpdateWidget(PageEditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageId != widget.pageId) {
      _loadTitle();
    }
  }

  Future<void> _loadTitle() async {
    if (_loadedPageId == widget.pageId) return;
    _loadedPageId = widget.pageId;
    final page = await ref.read(pageRepositoryProvider).getPage(widget.pageId);
    if (page != null && mounted) {
      _titleController.text = page.title;
    }
  }

  void _onTitleChanged(String value) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () async {
      await ref.read(pageRepositoryProvider).updateTitle(widget.pageId, value);
      ref.read(syncProvider.notifier).triggerDirtySync();
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () async {
            final repo = ref.read(pageRepositoryProvider);
            final page = await repo.getPage(widget.pageId);
            if (!context.mounted) return;
            final parentId = page?.parentId;
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(60, 16, 60, 8),
            child: TextField(
              controller: _titleController,
              onChanged: _onTitleChanged,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Untitled',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: RowPropertiesPanel(
              key: ValueKey('props-${widget.pageId}'),
              pageId: widget.pageId,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56),
              child: BlockEditor(
                key: ValueKey(widget.pageId),
                pageId: widget.pageId,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
