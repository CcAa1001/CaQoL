import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> saveNotesExport(String content, {required String filename}) async {
  final baseDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  final file = File('${baseDir.path}\\$filename');
  await file.writeAsString(content);
  return 'Saved to ${file.path}';
}
