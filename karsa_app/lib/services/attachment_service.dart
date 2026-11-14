import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../models/attachment_file.dart';
import 'file_bridge.dart';

class PickedAttachmentOutcome {
  final AttachmentFile? attachment;
  final String? extractedText;
  final String? notice;
  final String? error;
  final bool canceled;

  const PickedAttachmentOutcome({
    this.attachment,
    this.extractedText,
    this.notice,
    this.error,
    this.canceled = false,
  });
}

class AttachmentService {
  const AttachmentService();

  static const List<String> allowedExtensions = <String>[
    'pdf',
    'txt',
    'docx',
    'jpg',
    'jpeg',
    'png',
  ];

  String _guessMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.txt')) return 'text/plain';
    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream';
  }

  Future<PickedAttachmentOutcome> pickAttachment({required int currentStoreBytes}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return const PickedAttachmentOutcome(canceled: true);
      }

      final f = result.files.first;
      final maxBytes = kIsWeb ? 1024 * 1024 : 10 * 1024 * 1024;
      if (f.size > maxBytes) {
        return PickedAttachmentOutcome(
          error: 'File terlalu besar. Batas ${kIsWeb ? "1" : "10"} MB per file.',
        );
      }

      if (kIsWeb && (currentStoreBytes + (f.size * 1.4)) > 2.5 * 1024 * 1024) {
        return const PickedAttachmentOutcome(
          error: 'Penyimpanan demo browser hampir penuh. Gunakan file lebih kecil.',
        );
      }

      final mime = _guessMime(f.name);
      final isText = mime == 'text/plain' || f.name.toLowerCase().endsWith('.txt');
      final bytes = f.bytes ?? Uint8List(0);

      final uri = await FileBridge.persistPickedFile(
        isWeb: kIsWeb,
        fileName: f.name,
        mimeType: mime,
        bytes: bytes,
        sourcePath: f.path,
      );

      String? extracted;
      if (isText) {
        final rawText = await FileBridge.readText(
          isWeb: kIsWeb,
          bytes: f.bytes,
          path: uri,
        );
        extracted = rawText.length > 12000 ? rawText.substring(0, 12000) : rawText;
      }

      return PickedAttachmentOutcome(
        attachment: AttachmentFile(
          name: f.name,
          mimeType: mime,
          uri: uri,
          size: f.size,
        ),
        extractedText: extracted,
        notice: isText
            ? 'File teks berhasil dibaca.'
            : 'File terlampir. Untuk ringkasan, tempel teks materi secara manual.',
      );
    } catch (e) {
      return PickedAttachmentOutcome(
        error: 'Gagal memilih file: $e',
      );
    }
  }

  Future<String?> openAttachment(AttachmentFile? file) async {
    if (file == null || file.uri.isEmpty) {
      return 'Tidak ada file terlampir.';
    }
    try {
      if (file.uri.startsWith('data:')) {
        final commaIdx = file.uri.indexOf(',');
        if (commaIdx < 0) return 'Format data file tidak valid.';
        final bytes = base64Decode(file.uri.substring(commaIdx + 1));
        await Share.shareXFiles(
          <XFile>[XFile.fromData(bytes, name: file.name, mimeType: file.mimeType)],
          subject: 'Buka atau bagikan ${file.name}',
        );
        return null;
      }

      final openResult = await OpenFilex.open(file.uri, type: file.mimeType);
      if (openResult.type == ResultType.done) {
        return null;
      }

      await Share.shareXFiles(
        <XFile>[XFile(file.uri, name: file.name, mimeType: file.mimeType)],
        subject: 'Buka atau bagikan ${file.name}',
      );
      return null;
    } catch (e) {
      return 'Tidak dapat membuka file: $e';
    }
  }
}
