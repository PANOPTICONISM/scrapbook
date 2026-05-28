import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/databases/presentation/row_properties_panel.dart';
import '../../../features/editor/block_editor.dart';
import '../../../features/files/file_repository.dart';
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
    final cover = ref.watch(allPagesProvider).maybeWhen(
          data: (pages) =>
              pages.where((p) => p.id == widget.pageId).firstOrNull?.cover,
          orElse: () => null,
        );
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
          _CoverArea(pageId: widget.pageId, cover: cover),
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

class _CoverArea extends ConsumerStatefulWidget {
  final String pageId;
  final String? cover;
  const _CoverArea({required this.pageId, required this.cover});

  @override
  ConsumerState<_CoverArea> createState() => _CoverAreaState();
}

class _CoverAreaState extends ConsumerState<_CoverArea> {
  bool _hovered = false;

  Future<void> _setCover() async {
    try {
      final id = await ref.read(fileRepositoryProvider).pickAndUploadImage();
      if (id == null) return;
      await ref.read(pageRepositoryProvider).updateCover(widget.pageId, id);
      ref.read(syncProvider.notifier).triggerDirtySync();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't upload image")),
        );
      }
    }
  }

  Future<void> _removeCover() async {
    await ref.read(pageRepositoryProvider).updateCover(widget.pageId, null);
    ref.read(syncProvider.notifier).triggerDirtySync();
  }

  @override
  Widget build(BuildContext context) {
    final cover = widget.cover;
    if (cover == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 56, top: 8),
          child: TextButton.icon(
            onPressed: _setCover,
            icon: const Icon(Icons.image_outlined, size: 16),
            label: const Text('Add cover'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      );
    }

    final cfg = ref
        .watch(serverConfigProvider)
        .maybeWhen(data: (c) => c, orElse: () => null);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (cfg != null)
              CachedNetworkImage(
                imageUrl: FileRepository.imageUrl(cfg, cover),
                cacheKey: cover,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest),
              )
            else
              Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
            if (_hovered)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    _CoverButton(label: 'Change cover', onTap: _setCover),
                    const SizedBox(width: 6),
                    _CoverButton(label: 'Remove', onTap: _removeCover),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoverButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _CoverButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ),
    );
  }
}
