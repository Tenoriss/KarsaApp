import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String> persistPickedBytesImpl({
  required String sanitizedName,
  required String mimeType,
  required Uint8List bytes,
  String? sourcePath,
}) async {
  final dir = await getApplicationDocumentsDirectory();
  final destPath = '${dir.path}/karsa-${DateTime.now().millisecondsSinceEpoch}-$sanitizedName';
  final destFile = File(destPath);
  if (bytes.isNotEmpty) {
    await destFile.writeAsBytes(bytes, flush: true);
  } else if (sourcePath != null && sourcePath.isNotEmpty) {
    await File(sourcePath).copy(destPath);
  }
  return destPath;
}

Future<String> readTextFromSourceImpl({
  required Uint8List? bytes,
  String? path,
}) async {
  if (bytes != null && bytes.isNotEmpty) {
    return utf8.decode(bytes, allowMalformed: true);
  }
  if (path != null && path.isNotEmpty) {
    return await File(path).readAsString();
  }
  return '';
}

Future<String?> writeTempExportFileImpl({
  required String fileName,
  required Uint8List bytes,
}) async {
  final dir = await getTemporaryDirectory();
  final outPath = '${dir.path}/$fileName';
  await File(outPath).writeAsBytes(bytes, flush: true);
  return outPath;
}
