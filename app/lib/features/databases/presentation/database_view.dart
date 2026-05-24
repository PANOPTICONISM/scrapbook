import 'dart:convert';

import 'package:flutter/material.dart';

enum DatabaseView { gallery, table }

DatabaseView databaseViewFromName(String? name) =>
    name == 'table' ? DatabaseView.table : DatabaseView.gallery;

String databaseViewLabel(DatabaseView view) =>
    view == DatabaseView.table ? 'Table' : 'Gallery';

IconData databaseViewIcon(DatabaseView view) =>
    view == DatabaseView.table ? Icons.table_chart : Icons.grid_view;

/// A database block stores the linked database id plus its list of views and
/// which one is active, as JSON. Older blocks stored a single `view`, and the
/// oldest stored just the id string — both are upgraded on read.
class DatabaseBlockConfig {
  final String databaseId;
  final List<DatabaseView> views;
  final int active;

  const DatabaseBlockConfig({
    required this.databaseId,
    required this.views,
    required this.active,
  });

  DatabaseView get activeView =>
      views.isEmpty ? DatabaseView.gallery : views[active.clamp(0, views.length - 1)];

  DatabaseBlockConfig copyWith({List<DatabaseView>? views, int? active}) =>
      DatabaseBlockConfig(
        databaseId: databaseId,
        views: views ?? this.views,
        active: active ?? this.active,
      );

  String encode() => jsonEncode({
        'id': databaseId,
        'views': views.map((v) => v.name).toList(),
        'active': active,
      });
}

DatabaseBlockConfig parseDatabaseBlock(String content) {
  try {
    final decoded = jsonDecode(content);
    if (decoded is Map && decoded['id'] is String) {
      final id = decoded['id'] as String;
      if (decoded['views'] is List) {
        final views = (decoded['views'] as List)
            .map((e) => databaseViewFromName(e as String?))
            .toList();
        return DatabaseBlockConfig(
          databaseId: id,
          views: views.isEmpty ? const [DatabaseView.gallery] : views,
          active: (decoded['active'] as int?) ?? 0,
        );
      }
      return DatabaseBlockConfig(
        databaseId: id,
        views: [databaseViewFromName(decoded['view'] as String?)],
        active: 0,
      );
    }
  } catch (_) {}
  return DatabaseBlockConfig(
    databaseId: content,
    views: const [DatabaseView.gallery],
    active: 0,
  );
}

String encodeDatabaseBlock(String databaseId, DatabaseView view) =>
    DatabaseBlockConfig(databaseId: databaseId, views: [view], active: 0)
        .encode();
