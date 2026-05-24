import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../features/sync/sync_provider.dart';
import '../data/database_repository.dart';
import '../domain/database_model.dart';
import '../domain/database_row_model.dart';
import 'property_ui.dart';

class TableView extends ConsumerWidget {
  final String databaseId;
  final List<DatabaseRowModel> rows;
  final List<DatabaseProperty> properties;
  final void Function(DatabaseRowModel) onRowTap;

  const TableView({
    super.key,
    required this.databaseId,
    required this.rows,
    required this.properties,
    required this.onRowTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(databaseRepositoryProvider);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: 40),
              ...properties.map((p) => _HeaderCell(
                    property: p,
                    onRename: (name) {
                      repo.updateProperty(p.id, name: name);
                      ref.read(syncProvider.notifier).triggerDirtySync();
                    },
                    onDelete: () {
                      repo.deleteProperty(p.id);
                      ref.read(syncProvider.notifier).triggerDirtySync();
                    },
                  )),
              AddPropertyButton(databaseId: databaseId),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: rows.length + 1,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              if (i == rows.length) {
                return TextButton.icon(
                  onPressed: () async {
                    await repo.createRow(databaseId);
                    ref.read(syncProvider.notifier).triggerDirtySync();
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New row'),
                );
              }
              final row = rows[i];
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        icon: const Icon(Icons.open_in_new, size: 16),
                        onPressed: () => onRowTap(row),
                        tooltip: 'Open page',
                      ),
                    ),
                    ...properties.map((prop) => _DataCell(
                          row: row,
                          property: prop,
                          onValueChanged: (value) async {
                            await repo.setValue(
                              rowId: row.id,
                              propertyId: prop.id,
                              type: prop.type,
                              value: value,
                            );
                            ref.read(syncProvider.notifier).triggerDirtySync();
                          },
                        )),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatefulWidget {
  final DatabaseProperty property;
  final void Function(String) onRename;
  final VoidCallback onDelete;

  const _HeaderCell({
    required this.property,
    required this.onRename,
    required this.onDelete,
  });

  @override
  State<_HeaderCell> createState() => _HeaderCellState();
}

class _HeaderCellState extends State<_HeaderCell> {
  static const double _width = 160;
  final GlobalKey _anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    return SizedBox(
      width: _width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            InkWell(
              key: _anchorKey,
              onTap: _showMenu,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(propertyTypeIcon(p.type), size: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: PropertyNameField(
                initial: p.name,
                onSubmit: widget.onRename,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMenu() async {
    final pos = menuPositionFor(_anchorKey, context);
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
}

class _DataCell extends StatelessWidget {
  final DatabaseRowModel row;
  final DatabaseProperty property;
  final void Function(dynamic) onValueChanged;
  static const double _width = 160;

  const _DataCell({
    required this.row,
    required this.property,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final value = row.values[property.id];
    return SizedBox(
      width: _width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: _buildCell(context, value),
      ),
    );
  }

  Widget _buildCell(BuildContext context, PropertyValue? value) {
    return switch (property.type) {
      PropertyType.text => _TextCell(
          value: value is TextValue ? value.value : '',
          onChanged: onValueChanged,
        ),
      PropertyType.number => _NumberCell(
          value: value is NumberValue ? value.value : null,
          onChanged: onValueChanged,
        ),
      PropertyType.date => _DateCell(
          value: value is DateValue ? value.value : null,
          onChanged: onValueChanged,
        ),
      PropertyType.checkbox => _CheckboxCell(
          value: value is CheckboxValue ? value.value : false,
          onChanged: onValueChanged,
        ),
      PropertyType.select => SelectValueField(
          property: property,
          value: value is SelectValue ? value.optionId : null,
          onChanged: onValueChanged,
          emptyLabel: '—',
          emptyStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          padding: EdgeInsets.zero,
        ),
    };
  }
}

class _TextCell extends StatefulWidget {
  final String value;
  final void Function(String) onChanged;
  const _TextCell({required this.value, required this.onChanged});

  @override
  State<_TextCell> createState() => _TextCellState();
}

class _TextCellState extends State<_TextCell> {
  late final TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_TextCell oldWidget) {
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
        decoration: const InputDecoration(isDense: true, border: InputBorder.none),
        style: const TextStyle(fontSize: 13),
      );
}

class _NumberCell extends StatefulWidget {
  final double? value;
  final void Function(double?) onChanged;
  const _NumberCell({required this.value, required this.onChanged});

  @override
  State<_NumberCell> createState() => _NumberCellState();
}

class _NumberCellState extends State<_NumberCell> {
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
  void didUpdateWidget(_NumberCell oldWidget) {
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
        decoration: const InputDecoration(isDense: true, border: InputBorder.none),
        style: const TextStyle(fontSize: 13),
      );
}

class _DateCell extends StatelessWidget {
  final DateTime? value;
  final void Function(DateTime?) onChanged;

  const _DateCell({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          onChanged(picked);
        },
        child: Text(
          value != null ? DateFormat.yMMMd().format(value!) : '—',
          style: const TextStyle(fontSize: 13),
        ),
      );
}

class _CheckboxCell extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;

  const _CheckboxCell({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Checkbox(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
}

