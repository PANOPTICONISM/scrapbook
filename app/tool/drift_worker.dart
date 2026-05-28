// Entry point for drift's web worker. Compiled to web/drift_worker.js, which
// (together with web/sqlite3.wasm) drift loads to run SQLite in the browser.
//
// These two web assets are vendored and version-pinned. Regenerate them when
// upgrading drift / sqlite3:
//
//   dart compile js -O2 tool/drift_worker.dart -o web/drift_worker.js
//   curl -L -o web/sqlite3.wasm \
//     https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-<ver>/sqlite3.wasm
//
// (<ver> = the `sqlite3` package version in pubspec.lock.)
import 'package:drift/wasm.dart';

void main() => WasmDatabase.workerMainForOpen();
