import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../sync/sync_provider.dart';
import '../data/database_repository.dart';
import '../domain/database_model.dart';
import '../domain/database_row_model.dart';

/// Renders editable property fields at the top of a page that belongs to
/// a database row. Mirrors Notion's row-page layout: a list of
/// [icon] [property name] [value editor] rows above the page content.
class RowPropertiesPanel extends ConsumerWidget {
  final String pageId;
  const RowPropertiesPanel({super.key, required this.pageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(databaseRepositoryProvider);
    return StreamBuilder<DatabaseRowModel?>(
      stream: repo.watchRowByPageId(pageId),
      builder: (context, rowSnap) {
        final row = rowSnap.data;
        if (row == null) return const SizedBox.shrink();
        return StreamBuilder<List<DatabaseProperty>>(
          stream: repo.watchProperties(row.databaseId),
          builder: (context, propsSnap) {
            final properties = propsSnap.data ?? const <DatabaseProperty>[];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...properties.map((p) => _PropertyRow(
                        property: p,
                        value: row.values[p.id],
                        onChanged: (v) async {
                          await repo.setValue(
                            rowId: row.id,
                            propertyId: p.id,
                            type: p.type,
                            value: v,
                          );
                          ref.read(syncProvider.notifier).triggerDirtySync();
                        },
                        onRename: (name) async {
                          await repo.updateProperty(p.id, name: name);
                          ref.read(syncProvider.notifier).triggerDirtySync();
                        },
                      )),
                  _AddPropertyButton(databaseId: row.databaseId),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final DatabaseProperty property;
  final PropertyValue? value;
  final void Function(dynamic) onChanged;
  final void Function(String) onRename;

  const _PropertyRow({
    required this.property,
    required this.value,
    required this.onChanged,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            child: Row(
              children: [
                Icon(_typeIcon(property.type), size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: _PropertyNameField(
                    initial: property.name,
                    onSubmit: onRename,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _editor()),
        ],
      ),
    );
  }

  Widget _editor() {
    switch (property.type) {
      case PropertyType.text:
        return _TextEditor(
          value: value is TextValue ? (value as TextValue).value : '',
          onChanged: onChanged,
        );
      case PropertyType.number:
        return _NumberEditor(
          value: value is NumberValue ? (value as NumberValue).value : null,
          onChanged: onChanged,
        );
      case PropertyType.date:
        return _DateEditor(
          value: value is DateValue ? (value as DateValue).value : null,
          onChanged: onChanged,
        );
      case PropertyType.checkbox:
        return _CheckboxEditor(
          value: value is CheckboxValue ? (value as CheckboxValue).value : false,
          onChanged: onChanged,
        );
      case PropertyType.select:
        return _SelectEditor(
          value: value is SelectValue ? (value as SelectValue).optionId : null,
          options: property.options,
          onChanged: onChanged,
        );
    }
  }

  static IconData _typeIcon(PropertyType type) => switch (type) {
        PropertyType.text => Icons.text_fields,
        PropertyType.number => Icons.numbers,
        PropertyType.date => Icons.calendar_today,
        PropertyType.checkbox => Icons.check_box_outline_blank,
        PropertyType.select => Icons.list,
      };
}

class _TextEditor extends StatefulWidget {
  final String value;
  final void Function(String) onChanged;
  const _TextEditor({required this.value, required this.onChanged});

  @override
  State<_TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<_TextEditor> {
  late final TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_TextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _ctrl.text && !_focus.hasFocus) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _ctrl,
        focusNode: _focus,
        onSubmitted: widget.onChanged,
        onTapOutside: (_) => widget.onChanged(_ctrl.text),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'Empty',
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 4),
        ),
        style: const TextStyle(fontSize: 14),
      );
}

class _NumberEditor extends StatefulWidget {
  final double? value;
  final void Function(double?) onChanged;
  const _NumberEditor({required this.value, required this.onChanged});

  @override
  State<_NumberEditor> createState() => _NumberEditorState();
}

class _NumberEditorState extends State<_NumberEditor> {
  late final TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  static String _format(double? v) => v == null
      ? ''
      : (v.truncateToDouble() == v ? v.toInt().toString() : v.toString());

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _format(widget.value));
  }

  @override
  void didUpdateWidget(_NumberEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final formatted = _format(widget.value);
    if (formatted != _ctrl.text && !_focus.hasFocus) {
      _ctrl.text = formatted;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _ctrl,
        focusNode: _focus,
        keyboardType: TextInputType.number,
        onSubmitted: (v) => widget.onChanged(double.tryParse(v)),
        onTapOutside: (_) => widget.onChanged(double.tryParse(_ctrl.text)),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'Empty',
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 4),
        ),
        style: const TextStyle(fontSize: 14),
      );
}

class _DateEditor extends StatelessWidget {
  final DateTime? value;
  final void Function(DateTime?) onChanged;
  const _DateEditor({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) onChanged(picked);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            value != null ? DateFormat.yMMMd().format(value!) : 'Empty',
            style: TextStyle(
              fontSize: 14,
              color: value != null ? null : Colors.grey,
            ),
          ),
        ),
      );
}

class _CheckboxEditor extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;
  const _CheckboxEditor({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
}

class _SelectEditor extends StatefulWidget {
  final String? value;
  final List<SelectOption> options;
  final void Function(String?) onChanged;

  const _SelectEditor({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  State<_SelectEditor> createState() => _SelectEditorState();
}

class _SelectEditorState extends State<_SelectEditor> {
  final GlobalKey _anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final selected =
        widget.options.where((o) => o.id == widget.value).firstOrNull;
    return InkWell(
      key: _anchorKey,
      onTap: _showOptions,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: selected != null
            ? Align(
                alignment: Alignment.centerLeft,
                child: _OptionChip(option: selected),
              )
            : const Text('Empty',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
      ),
    );
  }

  Future<void> _showOptions() async {
    final pos = _menuPositionFor(_anchorKey, context);
    if (pos == null) return;
    final result = await showMenu<String>(
      context: context,
      position: pos,
      items: [
        if (widget.value != null)
          const PopupMenuItem<String>(
            value: '__clear__',
            child: Row(children: [
              Icon(Icons.clear, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text('Clear'),
            ]),
          ),
        ...widget.options.map((o) => PopupMenuItem<String>(
              value: o.id,
              child: _OptionChip(option: o),
            )),
      ],
    );
    if (result == null) return;
    widget.onChanged(result == '__clear__' ? null : result);
  }
}

class _OptionChip extends StatelessWidget {
  final SelectOption option;
  const _OptionChip({required this.option});

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

String _typeLabel(PropertyType t) => switch (t) {
      PropertyType.text => 'Text',
      PropertyType.number => 'Number',
      PropertyType.date => 'Date',
      PropertyType.checkbox => 'Checkbox',
      PropertyType.select => 'Select',
    };

/// Anchors a [showMenu] popup to the bounds of the widget owning [key].
RelativeRect? _menuPositionFor(GlobalKey key, BuildContext context) {
  final box = key.currentContext?.findRenderObject() as RenderBox?;
  if (box == null) return null;
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return null;
  final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
  final bottomRight =
      box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay);
  return RelativeRect.fromRect(
    Rect.fromPoints(topLeft, bottomRight),
    Offset.zero & overlay.size,
  );
}

/// Borderless inline editor for a property's name. Looks like plain text;
/// saves on submit or when focus leaves.
class _PropertyNameField extends StatefulWidget {
  final String initial;
  final void Function(String) onSubmit;
  const _PropertyNameField({required this.initial, required this.onSubmit});

  @override
  State<_PropertyNameField> createState() => _PropertyNameFieldState();
}

class _PropertyNameFieldState extends State<_PropertyNameField> {
  late final TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void didUpdateWidget(_PropertyNameField old) {
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
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      );
}

class _AddPropertyButton extends ConsumerStatefulWidget {
  final String databaseId;
  const _AddPropertyButton({required this.databaseId});

  @override
  ConsumerState<_AddPropertyButton> createState() => _AddPropertyButtonState();
}

class _AddPropertyButtonState extends ConsumerState<_AddPropertyButton> {
  final GlobalKey _anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        key: _anchorKey,
        onPressed: _showTypeMenu,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add property'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Future<void> _showTypeMenu() async {
    final pos = _menuPositionFor(_anchorKey, context);
    if (pos == null) return;
    final type = await showMenu<PropertyType>(
      context: context,
      position: pos,
      items: PropertyType.values
          .map((t) => PopupMenuItem<PropertyType>(
                value: t,
                child: Row(children: [
                  Icon(_PropertyRow._typeIcon(t), size: 16, color: Colors.grey),
                  const SizedBox(width: 10),
                  Text(_typeLabel(t)),
                ]),
              ))
          .toList(),
    );
    if (type == null) return;
    await ref.read(databaseRepositoryProvider).createProperty(
          databaseId: widget.databaseId,
          name: _typeLabel(type),
          type: type,
        );
    ref.read(syncProvider.notifier).triggerDirtySync();
  }
}
