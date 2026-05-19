import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'block_types.dart';

class SlashMenu extends StatefulWidget {
  final String query;
  final void Function(BlockType) onSelect;
  final VoidCallback onDismiss;

  const SlashMenu({
    super.key,
    required this.query,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  State<SlashMenu> createState() => _SlashMenuState();
}

class _SlashMenuState extends State<SlashMenu> {
  int _focusedIndex = 0;

  List<BlockType> get _filteredOptions {
    final q = widget.query.toLowerCase();
    if (q.isEmpty) return BlockType.values;
    return BlockType.values
        .where((t) => t.label.toLowerCase().contains(q) || t.value.contains(q))
        .toList();
  }

  @override
  void didUpdateWidget(SlashMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _focusedIndex = 0;
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final options = _filteredOptions;
    if (options.isEmpty) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _focusedIndex = (_focusedIndex + 1) % options.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() => _focusedIndex = (_focusedIndex - 1 + options.length) % options.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      widget.onSelect(options[_focusedIndex]);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final options = _filteredOptions;
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

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Container(
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
            final isFocused = i == _focusedIndex;
            return InkWell(
              onTap: () => widget.onSelect(option),
              onHover: (hovering) {
                if (hovering) setState(() => _focusedIndex = i);
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
      ),
    );
  }
}
