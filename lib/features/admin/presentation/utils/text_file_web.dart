import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;
import 'package:wordshool/features/admin/presentation/utils/text_file_types.dart';

export 'package:wordshool/features/admin/presentation/utils/text_file_types.dart';

const canUseFiles = true;

/// Opens the browser's file chooser; null when the admin cancels.
Future<PickedTextFile?> pickTextFile({String accept = ''}) {
  final completer = Completer<PickedTextFile?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = accept;
  input.addEventListener(
    'change',
    ((web.Event _) {
      _readFirstFile(input, completer);
    }).toJS,
  );
  input.addEventListener(
    'cancel',
    ((web.Event _) {
      if (!completer.isCompleted) completer.complete(null);
    }).toJS,
  );
  input.click();
  return completer.future;
}

Future<void> _readFirstFile(
    web.HTMLInputElement input, Completer<PickedTextFile?> completer) async {
  final file = input.files?.item(0);
  if (file == null) {
    if (!completer.isCompleted) completer.complete(null);
    return;
  }
  try {
    final text = (await file.text().toDart).toDart;
    if (!completer.isCompleted) {
      completer.complete(PickedTextFile(name: file.name, text: text));
    }
  } catch (e) {
    if (!completer.isCompleted) completer.completeError(e);
  }
}

/// Saves [content] as a download called [name].
void downloadTextFile(String name, String content,
    {String mimeType = 'text/plain'}) {
  final blob = web.Blob([content.toJS].toJS,
      web.BlobPropertyBag(type: '$mimeType;charset=utf-8'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = name;
  anchor.click();
  // Revoking straight away can cancel the download in some browsers.
  Timer(const Duration(seconds: 5), () => web.URL.revokeObjectURL(url));
}
