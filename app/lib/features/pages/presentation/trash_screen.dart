import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sync/sync_provider.dart';
import '../data/page_repository.dart';
import '../domain/page_model.dart';

/// Pages remain in trash for 30 days after deletion before being permanently
/// removed. This mirrors the server's `cleanup::TRASH_TTL_MS`.
const Duration _trashTtl = Duration(days: 30);

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(pageRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Pages in trash are permanently deleted after 30 days.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PageModel>>(
              stream: repo.watchTrash(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final pages = snapshot.data ?? const <PageModel>[];
                if (pages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'Trash is empty',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: pages.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => _TrashTile(page: pages[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TrashTile extends ConsumerWidget {
  final PageModel page;
  const _TrashTile({required this.page});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedAt = page.deletedAt != null
        ? DateTime.fromMillisecondsSinceEpoch(page.deletedAt!)
        : null;
    final daysLeft = deletedAt != null ? _daysUntilCleanup(deletedAt) : null;

    return ListTile(
      leading: Text(page.icon ?? (page.isDatabase ? '🗃' : '📄'),
          style: const TextStyle(fontSize: 16)),
      title: Text(page.title.isEmpty ? 'Untitled' : page.title),
      subtitle: deletedAt != null
          ? Text(
              'Deleted ${_formatTimeAgo(deletedAt)} · '
              '${daysLeft == 0 ? 'deletes today' : daysLeft == 1 ? 'deletes tomorrow' : 'deletes in $daysLeft days'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          : null,
      trailing: TextButton.icon(
        icon: const Icon(Icons.restore, size: 18),
        label: const Text('Restore'),
        onPressed: () async {
          await ref.read(pageRepositoryProvider).restorePage(page.id);
          ref.read(syncProvider.notifier).triggerDirtySync();
        },
      ),
    );
  }

  static int _daysUntilCleanup(DateTime deletedAt) {
    final remaining = _trashTtl - DateTime.now().difference(deletedAt);
    if (remaining.isNegative) return 0;
    // Round up so a just-deleted page reads "deletes in 30 days", not 29.
    return (remaining.inSeconds / Duration.secondsPerDay).ceil().clamp(0, 30);
  }

  static String _formatTimeAgo(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
