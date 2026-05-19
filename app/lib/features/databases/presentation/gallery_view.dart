import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/database_model.dart';
import '../domain/database_row_model.dart';

class GalleryView extends StatelessWidget {
  final List<DatabaseRowModel> rows;
  final List<DatabaseProperty> properties;
  final void Function(DatabaseRowModel) onRowTap;

  const GalleryView({
    super.key,
    required this.rows,
    required this.properties,
    required this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
        child: Text('No rows yet. Tap + to add one.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    // Name property is the first text property or just the first property
    final nameProperty = properties.firstOrNull;
    // Non-name properties to show as chips (up to 3)
    final chipProperties = properties.skip(1).take(3).toList();

    final crossAxisCount = MediaQuery.of(context).size.width > 900 ? 4 :
                           MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: rows.length,
      itemBuilder: (context, i) => _GalleryCard(
        row: rows[i],
        nameProperty: nameProperty,
        chipProperties: chipProperties,
        allProperties: properties,
        onTap: () => onRowTap(rows[i]),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final DatabaseRowModel row;
  final DatabaseProperty? nameProperty;
  final List<DatabaseProperty> chipProperties;
  final List<DatabaseProperty> allProperties;
  final VoidCallback onTap;

  const _GalleryCard({
    required this.row,
    required this.nameProperty,
    required this.chipProperties,
    required this.allProperties,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = nameProperty != null
        ? _displayValue(row.values[nameProperty!.id], nameProperty!, allProperties)
        : '';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.isEmpty ? 'Untitled' : title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: chipProperties.map((prop) {
                  final val = _displayValue(row.values[prop.id], prop, allProperties);
                  if (val.isEmpty) return const SizedBox.shrink();
                  return _PropertyChip(label: val, property: prop, allProperties: allProperties);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyChip extends StatelessWidget {
  final String label;
  final DatabaseProperty property;
  final List<DatabaseProperty> allProperties;

  const _PropertyChip({required this.label, required this.property, required this.allProperties});

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (property.type == PropertyType.select) {
      final option = property.options.where((o) => o.name == label).firstOrNull;
      if (option != null) {
        try {
          color = Color(int.parse(option.color.replaceFirst('#', '0xFF')));
        } catch (_) {}
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.15) ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color ?? Theme.of(context).colorScheme.onSurface)),
    );
  }
}

String _displayValue(PropertyValue? value, DatabaseProperty property, List<DatabaseProperty> allProperties) {
  if (value == null) return '';
  return switch (value) {
    TextValue(:final value) => value,
    NumberValue(:final value) => value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2),
    DateValue(:final value) => DateFormat.yMMMd().format(value),
    CheckboxValue(:final value) => value ? '✓' : '',
    SelectValue(:final optionId) =>
      property.options.where((o) => o.id == optionId).firstOrNull?.name ?? '',
  };
}
