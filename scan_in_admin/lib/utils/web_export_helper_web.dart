import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

/// ទាញយកឯកសារ Bytes (CSV / Excel) ផ្ទាល់នៅលើ Browser
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

/// បើកផ្ទាំងរបាយការណ៍ HTML ស្អាត និងហៅ Print / Save as PDF លើ Browser
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
