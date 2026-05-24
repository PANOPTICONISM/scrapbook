import 'dart:convert';

enum DatabaseView { gallery, table }

DatabaseView databaseViewFromName(String? name) =>
    name == 'table' ? DatabaseView.table : DatabaseView.gallery;

/// A database block's content stores the linked database id plus the chosen
/// view, as JSON. Older blocks stored just the id (treated as gallery).
({String databaseId, DatabaseView view}) parseDatabaseBlock(String content) {
  try {
    final decoded = jsonDecode(content);
    if (decoded is Map && decoded['id'] is String) {
      return (
        databaseId: decoded['id'] as String,
        view: databaseViewFromName(decoded['view'] as String?),
      );
    }
  } catch (_) {}
  return (databaseId: content, view: DatabaseView.gallery);
}

String encodeDatabaseBlock(String databaseId, DatabaseView view) =>
    jsonEncode({'id': databaseId, 'view': view.name});
