import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../features/sync/sync_provider.dart';
import '../data/database_repository.dart';
import '../domain/database_model.dart';
import '../domain/database_row_model.dart';

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
    return Column(
      children: [
        // Header row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: 40), // row open button column
              ...properties.map((p) => _HeaderCell(
                    property: p,
                    onRename: (name) => ref
                        .read(databaseRepositoryProvider)
                        .updateProperty(p.id, name: name),
                    onDelete: () => ref
                        .read(databaseRepositoryProvider)
                        .deleteProperty(p.id),
                  )),
              // Add property button
              TextButton.icon(
                onPressed: () => _showAddPropertyDialog(context, ref),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add property'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Data rows
        Expanded(
          child: ListView.separated(
            itemCount: rows.length + 1,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              if (i == rows.length) {
                return TextButton.icon(
                  onPressed: () async {
                    await ref.read(databaseRepositoryProvider).createRow(databaseId);
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
                    // Open page button
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
                            await ref.read(databaseRepositoryProvider).setValue(
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

  void _showAddPropertyDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    var selectedType = PropertyType.text;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add property'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PropertyType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: PropertyType.values.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.name),
                    )).toList(),
                onChanged: (t) => setState(() => selectedType = t!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                await ref.read(databaseRepositoryProvider).createProperty(
                      databaseId: databaseId,
                      name: nameController.text.trim(),
                      type: selectedType,
                    );
                ref.read(syncProvider.notifier).triggerDirtySync();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final DatabaseProperty property;
  final Future<void> Function(String) onRename;
  final Future<void> Function() onDelete;
  static const double _width = 160;

  const _HeaderCell({required this.property, required this.onRename, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMenu(context),
      child: Container(
        width: _width,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Icon(_typeIcon(property.type), size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(property.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: property.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename property'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              onRename(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(PropertyType type) => switch (type) {
        PropertyType.text => Icons.text_fields,
        PropertyType.number => Icons.numbers,
        PropertyType.date => Icons.calendar_today,
        PropertyType.checkbox => Icons.check_box_outline_blank,
        PropertyType.select => Icons.list,
      };
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
          context: context,
        ),
      PropertyType.checkbox => _CheckboxCell(
          value: value is CheckboxValue ? value.value : false,
          onChanged: onValueChanged,
        ),
      PropertyType.select => _SelectCell(
          value: value is SelectValue ? value.optionId : null,
          options: property.options,
          onChanged: onValueChanged,
          context: context,
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

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _ctrl,
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

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.value != null
            ? (widget.value!.truncateToDouble() == widget.value
                ? widget.value!.toInt().toString()
                : widget.value.toString())
            : '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _ctrl,
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
  final BuildContext context;

  const _DateCell({required this.value, required this.onChanged, required this.context});

  @override
  Widget build(BuildContext _) => InkWell(
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

class _SelectCell extends StatelessWidget {
  final String? value;
  final List<SelectOption> options;
  final void Function(String?) onChanged;
  final BuildContext context;

  const _SelectCell({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    final selected = options.where((o) => o.id == value).firstOrNull;
    return InkWell(
      onTap: () => _showOptions(),
      child: selected != null
          ? _OptionChip(option: selected)
          : const Text('—', style: TextStyle(fontSize: 13, color: Colors.grey)),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Clear'),
              leading: const Icon(Icons.clear),
              onTap: () {
                onChanged(null);
                Navigator.pop(context);
              },
            ),
            ...options.map((o) => ListTile(
                  title: _OptionChip(option: o),
                  onTap: () {
                    onChanged(o.id);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
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
