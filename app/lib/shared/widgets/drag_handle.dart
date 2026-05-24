import 'package:flutter/material.dart';

/// Hover-revealed drag handle for items inside a [ReorderableListView] built
/// with `buildDefaultDragHandles: false`. Shows the standard drag_indicator
/// icon that fades in when [visible] (driven by the row's hover state).
///
/// Optionally acts as a tap target (e.g. to open a context menu); pass
/// [handleKey] when the tap opens something that needs to anchor to the icon.
class DragHandle extends StatelessWidget {
  final int index;
  final bool visible;
  final double width;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Key? handleKey;

  const DragHandle({
    super.key,
    required this.index,
    required this.visible,
    this.width = 24,
    this.iconSize = 18,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.handleKey,
  });

  @override
  Widget build(BuildContext context) {
    Widget handle = ReorderableDragStartListener(
      index: index,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Icon(Icons.drag_indicator,
            key: handleKey, size: iconSize, color: Colors.grey),
      ),
    );
    if (onTap != null) {
      handle = GestureDetector(onTapUp: (_) => onTap!(), child: handle);
    }
    return SizedBox(
      width: width,
      child: AnimatedOpacity(
        opacity: visible ? 0.6 : 0.0,
        duration: const Duration(milliseconds: 120),
        child: Padding(padding: padding, child: handle),
      ),
    );
  }
}
