// Opening and saving text files in the browser. The admin panel is web-only;
// other platforms get the stub so tests and the mobile build still compile.
export 'text_file_stub.dart' if (dart.library.js_interop) 'text_file_web.dart';
