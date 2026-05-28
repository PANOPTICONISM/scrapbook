import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../files/file_repository.dart';
import '../sync/sync_provider.dart';
import 'block_repository.dart';

class ImageBlock extends ConsumerWidget {
  final String blockId;
  final String content; // file id, or '' when not yet set
  const ImageBlock({super.key, required this.blockId, required this.content});

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    try {
      final id = await ref.read(fileRepositoryProvider).pickAndUploadImage();
      if (id == null) return;
      await ref.read(blockRepositoryProvider).updateBlock(blockId, content: id);
      ref.read(syncProvider.notifier).triggerDirtySync();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't upload image")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (content.isEmpty) {
      return _Frame(
        child: InkWell(
          onTap: () => _pick(context, ref),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 20, color: Colors.grey),
                SizedBox(width: 8),
                Text('Add an image', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    final cfg = ref
        .watch(serverConfigProvider)
        .maybeWhen(data: (c) => c, orElse: () => null);
    if (cfg == null) {
      return const _Frame(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('Connect to a server to view images',
                style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 480),
            child: CachedNetworkImage(
              imageUrl: FileRepository.imageUrl(cfg, content),
              cacheKey: content,
              fit: BoxFit.contain,
              placeholder: (context, _) => const _Loading(),
              errorWidget: (context, _, _) => const _Frame(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('Could not load image',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  final Widget child;
  const _Frame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const _Frame(
        child: SizedBox(
          height: 160,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
}
