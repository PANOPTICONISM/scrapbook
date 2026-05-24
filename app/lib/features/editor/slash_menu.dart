import 'package:flutter/material.dart';

import 'block_types.dart';

List<BlockType> filterSlashOptions(String query) {
  // `database` is the stored/rendered type; the menu offers Table/Gallery
  // instead, which both create a database with the chosen initial view.
  final options =
      BlockType.values.where((t) => t != BlockType.database).toList();
  final q = query.toLowerCase();
  if (q.isEmpty) return options;
  return options
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
    final theme = Theme.of(context);
    if (options.isEmpty) {
      return Focus(
        canRequestFocus: false,
        descendantsAreFocusable: false,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
          ),
          child: const Text('No matches', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Focus(
      canRequestFocus: false,
      descendantsAreFocusable: false,
      child: Container(
        width: 240,
        constraints: const BoxConstraints(maxHeight: 320),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor),
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
            return _SlashRow(
              option: option,
              focused: isFocused,
              onSelect: () => onSelect(option),
              onHover: () => onHover(i),
            );
          },
        ),
      ),
    );
  }
}

class _SlashRow extends StatelessWidget {
  final BlockType option;
  final bool focused;
  final VoidCallback onSelect;
  final VoidCallback onHover;

  const _SlashRow({
    required this.option,
    required this.focused,
    required this.onSelect,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(),
      // Listener avoids the InkWell's Focus requestFocus, which would steal
      // focus from the TextField and cause our "dismiss on focus loss" guard
      // to close the menu before the tap registers.
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => onSelect(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: focused
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
      ),
    );
  }
}
