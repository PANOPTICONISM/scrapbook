import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../files/file_repository.dart';
import '../domain/database_model.dart';
import '../domain/database_row_model.dart';

class GalleryView extends StatelessWidget {
  final List<DatabaseRowModel> rows;
  final List<DatabaseProperty> properties;
  final void Function(DatabaseRowModel) onRowTap;
  /// Optional map of pageId -> page title. Each row's title is taken from
  /// the linked page, so editing the row page's title updates the card.
  final Map<String, String> pageTitles;

  /// Optional map of pageId -> page icon (emoji), shown before the title.
  final Map<String, String> pageIcons;

  /// Optional map of pageId -> cover file id, shown atop the card.
  final Map<String, String> pageCovers;

  /// Resolved server config, needed to build authenticated cover image URLs.
  final ServerConfig? serverConfig;

  const GalleryView({
    super.key,
    required this.rows,
    required this.properties,
    required this.onRowTap,
    this.pageTitles = const {},
    this.pageIcons = const {},
    this.pageCovers = const {},
    this.serverConfig,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
        child: Text('No rows yet. Tap + to add one.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Size the columns off the actual available width, not the screen — the
        // gallery often lives inside a narrow column (e.g. embedded in a page).
        final width = constraints.maxWidth;
        final crossAxisCount = (width / 180).floor().clamp(1, 6);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: rows.length,
          itemBuilder: (context, i) => _GalleryCard(
            row: rows[i],
            title: pageTitles[rows[i].pageId] ?? '',
            icon: pageIcons[rows[i].pageId] ?? '',
            cover: pageCovers[rows[i].pageId] ?? '',
            serverConfig: serverConfig,
            properties: properties,
            onTap: () => onRowTap(rows[i]),
          ),
        );
      },
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final DatabaseRowModel row;
  final String title;
  final String icon;
  final String cover;
  final ServerConfig? serverConfig;
  final List<DatabaseProperty> properties;
  final VoidCallback onTap;

  const _GalleryCard({
    required this.row,
    required this.title,
    required this.icon,
    required this.cover,
    required this.serverConfig,
    required this.properties,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    for (final prop in properties) {
      final v = row.values[prop.id];
      if (v is MultiSelectValue) {
        for (final id in v.optionIds) {
          final opt = prop.options.where((o) => o.id == id).firstOrNull;
          if (opt != null) chips.add(_PropertyChip(label: opt.name, property: prop));
        }
        continue;
      }
      final val = _displayValue(v, prop);
      if (val.isEmpty) continue;
      chips.add(_PropertyChip(label: val, property: prop));
    }

    final cfg = serverConfig;
    final showCover = cover.isNotEmpty && cfg != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCover)
              Expanded(
                flex: 2,
                child: SizedBox(
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: FileRepository.imageUrl(cfg, cover),
                    cacheKey: cover,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest),
                  ),
                ),
              ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (icon.isNotEmpty) ...[
                          Text(icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            title.isEmpty ? 'Untitled' : title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
          ],
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
    if (property.type == PropertyType.select ||
        property.type == PropertyType.multiSelect) {
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
    MultiSelectValue(:final optionIds) => optionIds
        .map((id) =>
            property.options.where((o) => o.id == id).firstOrNull?.name ?? '')
        .where((s) => s.isNotEmpty)
        .join(', '),
  };
}
