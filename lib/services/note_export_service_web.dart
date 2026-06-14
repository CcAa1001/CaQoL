import 'dart:convert';
import 'dart:html' as html;

Future<String> saveNotesExport(String content, {required String filename}) async {
  final bytes = utf8.encode(content);
  final mimeType = filename.toLowerCase().endsWith('.txt')
      ? 'text/plain'
      : 'application/json';
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);

  return 'Downloaded $filename';
}
