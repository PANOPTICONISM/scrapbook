import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/drag_handle.dart';
import '../../sync/sync_provider.dart';
import '../data/database_repository.dart';
import '../domain/database_model.dart';
import '../domain/database_row_model.dart';
import 'property_ui.dart';

/// Renders editable property fields at the top of a page that belongs to
/// a database row. Mirrors Notion's row-page layout: a list of
/// [icon] [property name] [value editor] rows above the page content.
class RowPropertiesPanel extends ConsumerStatefulWidget {
  final String pageId;
  const RowPropertiesPanel({super.key, required this.pageId});

  @override
  ConsumerState<RowPropertiesPanel> createState() => _RowPropertiesPanelState();
}

class _RowPropertiesPanelState extends ConsumerState<RowPropertiesPanel> {
  // Optimistic order applied the instant a drag ends, so the row lands in its
  // new slot immediately instead of snapping back while the DB write +
  // stream round-trips. Reset to the stream's order when membership changes.
  List<String>? _orderIds;

  List<DatabaseProperty> _applyLocalOrder(List<DatabaseProperty> incoming) {
    final byId = {for (final p in incoming) p.id: p};
    final ids = _orderIds;
    if (ids != null &&
        ids.length == byId.length &&
        ids.every(byId.containsKey)) {
      return [for (final id in ids) byId[id]!];
    }
    _orderIds = null;
    return incoming;
  }

  @override
  Widget build(BuildContext context) {
    final row = ref
        .watch(rowByPageIdProvider(widget.pageId))
        .maybeWhen(data: (r) => r, orElse: () => null);
    if (row == null) return const SizedBox.shrink();

    final repo = ref.read(databaseRepositoryProvider);
    final incoming =
        ref.watch(databasePropertiesProvider(row.databaseId)).maybeWhen(
              data: (p) => p,
              orElse: () => const <DatabaseProperty>[],
            );
    final properties = _applyLocalOrder(incoming);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (properties.isNotEmpty)
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              proxyDecorator: (child, _, _) =>
                  Material(color: Colors.transparent, child: child),
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex -= 1;
                final ids = properties.map((p) => p.id).toList();
                ids.insert(newIndex, ids.removeAt(oldIndex));
                setState(() => _orderIds = ids);
                repo.reorderProperties(ids);
                ref.read(syncProvider.notifier).triggerDirtySync();
              },
              children: [
                for (var i = 0; i < properties.length; i++)
                  _PropertyRow(
                    key: ValueKey(properties[i].id),
                    index: i,
                    property: properties[i],
                    value: row.values[properties[i].id],
                    onChanged: (v) async {
                      await repo.setValue(
                        rowId: row.id,
                        propertyId: properties[i].id,
                        type: properties[i].type,
                        value: v,
                      );
                      ref.read(syncProvider.notifier).triggerDirtySync();
                    },
                    onRename: (name) async {
                      await repo.updateProperty(properties[i].id, name: name);
                      ref.read(syncProvider.notifier).triggerDirtySync();
                    },
                    onDelete: () async {
                      await repo.deleteProperty(properties[i].id);
                      ref.read(syncProvider.notifier).triggerDirtySync();
                    },
                  ),
              ],
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: AddPropertyButton(databaseId: row.databaseId),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _PropertyRow extends StatefulWidget {
  final DatabaseProperty property;
  final PropertyValue? value;
  final void Function(dynamic) onChanged;
  final void Function(String) onRename;
  final VoidCallback onDelete;
  final int index;

  const _PropertyRow({
    super.key,
    required this.property,
    required this.value,
    required this.onChanged,
    required this.onRename,
    required this.onDelete,
    required this.index,
  });

  @override
  State<_PropertyRow> createState() => _PropertyRowState();
}

class _PropertyRowState extends State<_PropertyRow> {
  bool _hovered = false;
  final GlobalKey _handleKey = GlobalKey();

  Future<void> _showMenu() async {
    final pos = menuPositionFor(_handleKey, context);
    if (pos == null) return;
    final result = await showMenu<String>(
      context: context,
      position: pos,
      items: const [
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 16, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
    if (result == 'delete') widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tap the handle for options (delete), drag it to reorder.
            DragHandle(
              index: widget.index,
              visible: _hovered,
              width: 20,
              iconSize: 16,
              onTap: _showMenu,
              handleKey: _handleKey,
            ),
            SizedBox(
              width: 160,
              child: Row(
                children: [
                  Icon(propertyTypeIcon(widget.property.type),
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PropertyNameField(
                      initial: widget.property.name,
                      onSubmit: widget.onRename,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _editor()),
          ],
        ),
      ),
    );
  }

  Widget _editor() {
    final value = widget.value;
    switch (widget.property.type) {
      case PropertyType.text:
        return _TextEditor(
          value: value is TextValue ? value.value : '',
          onChanged: widget.onChanged,
        );
      case PropertyType.number:
        return _NumberEditor(
          value: value is NumberValue ? value.value : null,
          onChanged: widget.onChanged,
        );
      case PropertyType.date:
        return _DateEditor(
          value: value is DateValue ? value.value : null,
          onChanged: widget.onChanged,
        );
      case PropertyType.checkbox:
        return _CheckboxEditor(
          value: value is CheckboxValue ? value.value : false,
          onChanged: widget.onChanged,
        );
      case PropertyType.select:
        return SelectValueField(
          property: widget.property,
          value: value is SelectValue ? value.optionId : null,
          onChanged: widget.onChanged,
          emptyStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        );
      case PropertyType.multiSelect:
        return MultiSelectValueField(
          property: widget.property,
          value: value is MultiSelectValue ? value.optionIds : const [],
          onChanged: widget.onChanged,
          emptyStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        );
    }
  }
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

