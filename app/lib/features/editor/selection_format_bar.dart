import 'package:flutter/material.dart';

enum FormatAction { bold, italic, code, strikethrough, link }

class SelectionFormatBar extends StatelessWidget {
  final void Function(FormatAction) onAction;

  const SelectionFormatBar({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Focus(
      canRequestFocus: false,
      descendantsAreFocusable: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Btn(icon: Icons.format_bold, onTap: () => onAction(FormatAction.bold)),
            _Btn(icon: Icons.format_italic, onTap: () => onAction(FormatAction.italic)),
            _Btn(icon: Icons.code, onTap: () => onAction(FormatAction.code)),
            _Btn(icon: Icons.format_strikethrough, onTap: () => onAction(FormatAction.strikethrough)),
            _Btn(icon: Icons.link, onTap: () => onAction(FormatAction.link)),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.onTap});

  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      // Use a raw pointer-down listener so the tap never goes through a Focus-
      // requesting widget — the TextField keeps focus and the selection stays alive.
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (PointerDownEvent _) => widget.onTap(),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _hovered
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }

  IconData get icon => widget.icon;
}
