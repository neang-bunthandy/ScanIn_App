import 'dart:typed_data';

void downloadBytesFile({
  required Uint8List bytes,
  required String filename,
  String mimeType = 'text/csv;charset=utf-8',
}) {
  // No-op on non-web platforms
}

void printHtmlReport(String htmlContent) {
  // No-op on non-web platforms
}
