import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'image_source_stub.dart' if (dart.library.io) 'image_source_io.dart'
    as impl;

/// Mengubah URI lampiran menjadi [ImageProvider] yang bisa dirender.
///
/// Lampiran bisa berupa:
///
/// * `data:<mime>;base64,<payload>` - dipakai di web, byte-nya ikut
///   tersimpan di `@karsa-demo-v1`;
/// * path file absolut - dipakai di Android/iOS, file-nya sudah disalin ke
///   direktori dokumen aplikasi oleh `FileBridge`.
ImageProvider? providerFromAttachmentUri(String uri) {
  if (uri.isEmpty) return null;
  if (uri.startsWith('data:')) {
    final comma = uri.indexOf(',');
    if (comma < 0) return null;
    try {
      final bytes = base64Decode(uri.substring(comma + 1));
      if (bytes.isEmpty) return null;
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }
  return impl.fileImageProvider(uri);
}

/// Membaca byte gambar dari lampiran (dipakai untuk prong preview).
Uint8List? bytesFromAttachmentUri(String uri) {
  if (uri.isEmpty) return null;
  if (uri.startsWith('data:')) {
    final comma = uri.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(uri.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }
  return impl.fileBytes(uri);
}
