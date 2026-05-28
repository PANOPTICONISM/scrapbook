import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Native (macOS/iOS/Android/desktop) connection: a SQLite file in the app's
/// support directory.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'scrapbook.db'));
    return NativeDatabase.createInBackground(file);
  });
}
