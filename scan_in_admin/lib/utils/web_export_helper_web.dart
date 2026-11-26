// Browser file download, print/PDF, and file picker helpers.
import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

void downloadBytesFile({
  required Uint8List bytes,
  required String filename,
  String mimeType = 'text/csv;charset=utf-8',
}) {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

void printHtmlReport(String htmlContent) {
  final blob = web.Blob(
    [htmlContent.toJS].toJS,
    web.BlobPropertyBag(type: 'text/html;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final win = web.window.open(url, '_blank');
  if (win != null) {
    Future.delayed(const Duration(milliseconds: 500), () {
      win.print();
    });
  }
}

Future<({String name, Uint8List bytes})?> pickFileBytes({
  String accept = '.csv,.xlsx,.xls',
}) {
  final completer = Completer<({String name, Uint8List bytes})?>();
  final input = web.document.createElement('input') as web.HTMLInputElement;
  input.type = 'file';
  input.accept = accept;

  input.onChange.listen((_) async {
    final files = input.files;
    if (files == null || files.length == 0) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    final file = files.item(0);
    if (file == null) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    try {
      final buffer = await file.arrayBuffer().toDart;
      final bytes = Uint8List.view(buffer.toDart);
      if (!completer.isCompleted) {
        completer.complete((name: file.name, bytes: bytes));
      }
    } catch (_) {
      if (!completer.isCompleted) completer.complete(null);
    }
  });

  input.click();
  return completer.future;
}
