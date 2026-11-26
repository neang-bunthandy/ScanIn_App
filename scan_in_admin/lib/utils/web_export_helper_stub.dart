// Browser file download, print/PDF, and file picker helpers.
import 'dart:typed_data';

void downloadBytesFile({
  required Uint8List bytes,
  required String filename,
  String mimeType = 'text/csv;charset=utf-8',
}) {

}

void printHtmlReport(String htmlContent) {

}

Future<({String name, Uint8List bytes})?> pickFileBytes({
  String accept = '.csv,.xlsx,.xls',
}) async {
  return null;
}
