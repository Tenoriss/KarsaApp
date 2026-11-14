import 'dart:typed_data';

Future<String> persistPickedBytesImpl({
  required String sanitizedName,
  required String mimeType,
  required Uint8List bytes,
  String? sourcePath,
}) async {
  throw UnsupportedError('Platform penyimpanan file tidak tersedia.');
}

Future<String> readTextFromSourceImpl({
  required Uint8List? bytes,
  String? path,
}) async {
  return '';
}

Future<String?> writeTempExportFileImpl({
  required String fileName,
  required Uint8List bytes,
}) async {
  return null;
}
