import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web connection: SQLite compiled to WASM, persisted in the browser
/// (OPFS/IndexedDB). `sqlite3.wasm` and `drift_worker.js` are served from web/.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'scrapbook',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
