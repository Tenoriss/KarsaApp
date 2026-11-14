import 'dart:convert';
import 'dart:typed_data';
import 'file_bridge_stub.dart' if (dart.library.io) 'file_bridge_io.dart';

class FileBridge {
  FileBridge._();

  static Future<String> persistPickedFile({
    required bool isWeb,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
    String? sourcePath,
  }) async {
    if (isWeb) {
      final b64 = base64Encode(bytes);
      return 'data:$mimeType;base64,$b64';
    }
    final sanitized = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return persistPickedBytesImpl(
      sanitizedName: sanitized,
      mimeType: mimeType,
      bytes: bytes,
      sourcePath: sourcePath,
    );
  }

  static Future<String> readText({
    required bool isWeb,
    required Uint8List? bytes,
    String? path,
  }) async {
    if (isWeb) {
      if (bytes == null) return '';
      return utf8.decode(bytes, allowMalformed: true);
    }
    return readTextFromSourceImpl(bytes: bytes, path: path);
  }

  static Future<String?> writeTempExport({
    required bool isWeb,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (isWeb) return null;
    return writeTempExportFileImpl(fileName: fileName, bytes: bytes);
  }
}
