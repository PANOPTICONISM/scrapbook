// Picks the native file-based connection by default, or the WASM/browser
// connection when compiling for web. Keeps dart:io out of web builds.
export 'native.dart' if (dart.library.js_interop) 'web.dart';
