import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../sync/sync_provider.dart';
import '../data/database_repository.dart';
import '../domain/database_model.dart';

/// Anchors a [showMenu] popup just to the right of the widget owning [key],
/// tops aligned, so the menu opens beside the click instead of on top of it.
RelativeRect? menuPositionFor(GlobalKey key, BuildContext context) {
  final box = key.currentContext?.findRenderObject() as RenderBox?;
  if (box == null) return null;
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return null;
  final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
  final bottomRight =
      box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay);
  return RelativeRect.fromLTRB(
    bottomRight.dx + 4,
    topLeft.dy,
    overlay.size.width - bottomRight.dx + 4,
    overlay.size.height - topLeft.dy,
  );
}

IconData propertyTypeIcon(PropertyType type) => switch (type) {
      PropertyType.text => Icons.text_fields,
      PropertyType.number => Icons.numbers,
      PropertyType.date => Icons.calendar_today,
      PropertyType.checkbox => Icons.check_box_outline_blank,
      PropertyType.select => Icons.list,
    };

String propertyTypeLabel(PropertyType type) => switch (type) {
      PropertyType.text => 'Text',
      PropertyType.number => 'Number',
      PropertyType.date => 'Date',
      PropertyType.checkbox => 'Checkbox',
      PropertyType.select => 'Select',
    };

/// Borderless inline editor for a property's name. Looks like plain text;
/// saves on submit or when focus leaves.
class PropertyNameField extends StatefulWidget {
  final String initial;
  final void Function(String) onSubmit;
  final TextStyle? style;

  const PropertyNameField({
    super.key,
    required this.initial,
    required this.onSubmit,
    this.style,
  });

  @override
  State<PropertyNameField> createState() => _PropertyNameFieldState();
}

class _PropertyNameFieldState extends State<PropertyNameField> {
  late final TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void didUpdateWidget(PropertyNameField old) {
    super.didUpdateWidget(old);
    if (widget.initial != _ctrl.text && !_focus.hasFocus) {
      _ctrl.text = widget.initial;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _save() {
    final v = _ctrl.text.trim();
    if (v.isNotEmpty && v != widget.initial) widget.onSubmit(v);
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _ctrl,
        focusNode: _focus,
        onSubmitted: (_) => _save(),
        onTapOutside: (_) {
          _save();
          _focus.unfocus();
        },
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: widget.style ??
            const TextStyle(fontSize: 13, color: Colors.grey),
      );
}

/// "+ Add property" button that opens an anchored popup of property types and
/// creates the chosen one with a sensible default name.
class AddPropertyButton extends ConsumerStatefulWidget {
  final String databaseId;
  const AddPropertyButton({super.key, required this.databaseId});

  @override
  ConsumerState<AddPropertyButton> createState() => _AddPropertyButtonState();
}

class _AddPropertyButtonState extends ConsumerState<AddPropertyButton> {
  final GlobalKey _anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: _anchorKey,
      onPressed: _showTypeMenu,
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Add property'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Future<void> _showTypeMenu() async {
    final pos = menuPositionFor(_anchorKey, context);
    if (pos == null) return;
    final type = await showMenu<PropertyType>(
      context: context,
      position: pos,
      items: PropertyType.values
          .map((t) => PopupMenuItem<PropertyType>(
                value: t,
                child: Row(children: [
                  Icon(propertyTypeIcon(t), size: 16, color: Colors.grey),
                  const SizedBox(width: 10),
                  Text(propertyTypeLabel(t)),
                ]),
              ))
          .toList(),
    );
    if (type == null) return;
    await ref.read(databaseRepositoryProvider).createProperty(
          databaseId: widget.databaseId,
          name: propertyTypeLabel(type),
          type: type,
        );
    ref.read(syncProvider.notifier).triggerDirtySync();
  }
}

/// Inline select editor: shows the current option as a chip, opens an anchored
/// popover to pick an existing option or create a new one by typing.
class SelectValueField extends StatefulWidget {
  final DatabaseProperty property;
  final String? value;
  final void Function(String?) onChanged;
  final String emptyLabel;
  final TextStyle? emptyStyle;
  final EdgeInsetsGeometry padding;

  const SelectValueField({
    super.key,
    required this.property,
    required this.value,
    required this.onChanged,
    this.emptyLabel = 'Empty',
    this.emptyStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 6),
  });

  @override
  State<SelectValueField> createState() => _SelectValueFieldState();
}

class _SelectValueFieldState extends State<SelectValueField> {
  final GlobalKey _anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final selected =
        widget.property.options.where((o) => o.id == widget.value).firstOrNull;
    return InkWell(
      key: _anchorKey,
      onTap: () => _openPopup(),
      child: Padding(
        padding: widget.padding,
        child: selected != null
            ? Align(alignment: Alignment.centerLeft, child: OptionChip(option: selected))
            : Text(
                widget.emptyLabel,
                style: widget.emptyStyle ??
                    const TextStyle(fontSize: 14, color: Colors.grey),
              ),
      ),
    );
  }

  Future<void> _openPopup() async {
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);

    final result = await showDialog<_SelectResult>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (_) => _SelectPopup(
        anchorTopLeft: topLeft,
        anchorSize: box.size,
        overlaySize: overlay.size,
        property: widget.property,
        value: widget.value,
      ),
    );
    if (result == null) return;
    widget.onChanged(result.clear ? null : result.optionId);
  }
}

class _SelectResult {
  final String? optionId;
  final bool clear;
  const _SelectResult.option(this.optionId) : clear = false;
  const _SelectResult.cleared()
      : optionId = null,
        clear = true;
}

const _optionPalette = [
  '#EB5757', '#F2994A', '#F2C94C', '#27AE60',
  '#2F80ED', '#9B51E0', '#BB6BD9', '#56CCF2',
];

class _SelectPopup extends ConsumerStatefulWidget {
  final Offset anchorTopLeft;
  final Size anchorSize;
  final Size overlaySize;
  final DatabaseProperty property;
  final String? value;

  const _SelectPopup({
    required this.anchorTopLeft,
    required this.anchorSize,
    required this.overlaySize,
    required this.property,
    required this.value,
  });

  @override
  ConsumerState<_SelectPopup> createState() => _SelectPopupState();
}

class _SelectPopupState extends ConsumerState<_SelectPopup> {
  String _query = '';

  static const double _cardWidth = 240;
  static const double _maxHeight = 300;

  Future<void> _create(String name) async {
    final id = const Uuid().v4();
    final color =
        _optionPalette[widget.property.options.length % _optionPalette.length];
    final options = [
      ...widget.property.options,
      SelectOption(id: id, name: name, color: color),
    ];
    await ref
        .read(databaseRepositoryProvider)
        .updateProperty(widget.property.id, options: options);
    ref.read(syncProvider.notifier).triggerDirtySync();
    if (mounted) Navigator.pop(context, _SelectResult.option(id));
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim();
    final options = widget.property.options;
    final filtered = q.isEmpty
        ? options
        : options
            .where((o) => o.name.toLowerCase().contains(q.toLowerCase()))
            .toList();
    final exactExists =
        options.any((o) => o.name.toLowerCase() == q.toLowerCase());

    var left = widget.anchorTopLeft.dx;
    if (left + _cardWidth > widget.overlaySize.width - 8) {
      left = widget.overlaySize.width - 8 - _cardWidth;
    }
    if (left < 8) left = 8;
    var top = widget.anchorTopLeft.dy + widget.anchorSize.height + 4;
    if (top + _maxHeight > widget.overlaySize.height - 8) {
      top = (widget.overlaySize.height - 8 - _maxHeight).clamp(8.0, double.infinity);
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onTap: () {},
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: _cardWidth,
                  maxWidth: _cardWidth,
                  maxHeight: _maxHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        onSubmitted: (v) {
                          final t = v.trim();
                          if (t.isEmpty) return;
                          final match = options
                              .where((o) =>
                                  o.name.toLowerCase() == t.toLowerCase())
                              .firstOrNull;
                          if (match != null) {
                            Navigator.pop(
                                context, _SelectResult.option(match.id));
                          } else {
                            _create(t);
                          }
                        },
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Search or create…',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        children: [
                          if (widget.value != null)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.clear, size: 16),
                              title: const Text('Clear'),
                              onTap: () => Navigator.pop(
                                  context, const _SelectResult.cleared()),
                            ),
                          ...filtered.map((o) => ListTile(
                                dense: true,
                                title:
                                    Align(alignment: Alignment.centerLeft, child: OptionChip(option: o)),
                                trailing: o.id == widget.value
                                    ? const Icon(Icons.check, size: 16)
                                    : null,
                                onTap: () => Navigator.pop(
                                    context, _SelectResult.option(o.id)),
                              )),
                          if (q.isNotEmpty && !exactExists)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.add, size: 16),
                              title: Text('Create "$q"'),
                              onTap: () => _create(q),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OptionChip extends StatelessWidget {
  final SelectOption option;
  const OptionChip({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    Color? color;
    try {
      color = Color(int.parse(option.color.replaceFirst('#', '0xFF')));
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.15) ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(option.name,
          style: TextStyle(fontSize: 12, color: color ?? Colors.grey.shade800)),
    );
  }
}
