import 'package:flutter/material.dart';

import 'block_types.dart';

List<BlockType> filterSlashOptions(String query) {
  final q = query.toLowerCase();
  if (q.isEmpty) return BlockType.values;
  return BlockType.values
      .where((t) => t.label.toLowerCase().contains(q) || t.value.contains(q))
      .toList();
}

class SlashMenu extends StatelessWidget {
  final List<BlockType> options;
  final int focusedIndex;
  final void Function(BlockType) onSelect;
  final void Function(int) onHover;

  const SlashMenu({
    super.key,
    required this.options,
    required this.focusedIndex,
    required this.onSelect,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: const Text('No matches', style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      width: 240,
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        shrinkWrap: true,
        itemCount: options.length,
        itemBuilder: (context, i) {
          final option = options[i];
          final isFocused = i == focusedIndex;
          return InkWell(
            onTap: () => onSelect(option),
            onHover: (hovering) {
              if (hovering) onHover(i);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: isFocused
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                  : null,
              child: Row(
                children: [
                  Icon(option.icon, size: 18, color: Colors.grey.shade700),
                  const SizedBox(width: 10),
                  Text(option.label, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
