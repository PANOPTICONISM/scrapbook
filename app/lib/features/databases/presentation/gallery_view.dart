import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/database_model.dart';
import '../domain/database_row_model.dart';

class GalleryView extends StatelessWidget {
  final List<DatabaseRowModel> rows;
  final List<DatabaseProperty> properties;
  final void Function(DatabaseRowModel) onRowTap;
  /// Optional map of pageId -> page title. Each row's title is taken from
  /// the linked page, so editing the row page's title updates the card.
  final Map<String, String> pageTitles;

  const GalleryView({
    super.key,
    required this.rows,
    required this.properties,
    required this.onRowTap,
    this.pageTitles = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
        child: Text('No rows yet. Tap + to add one.',
            style: TextStyle(color: Colors.grey)),
      );
    }

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
        title: pageTitles[rows[i].pageId] ?? '',
        properties: properties,
        onTap: () => onRowTap(rows[i]),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final DatabaseRowModel row;
  final String title;
  final List<DatabaseProperty> properties;
  final VoidCallback onTap;

  const _GalleryCard({
    required this.row,
    required this.title,
    required this.properties,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    for (final prop in properties) {
      final val = _displayValue(row.values[prop.id], prop);
      if (val.isEmpty) continue;
      chips.add(_PropertyChip(label: val, property: prop));
    }

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
              Expanded(
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: chips,
                    ),
                  ),
                ),
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

  const _PropertyChip({required this.label, required this.property});

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

String _displayValue(PropertyValue? value, DatabaseProperty property) {
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
