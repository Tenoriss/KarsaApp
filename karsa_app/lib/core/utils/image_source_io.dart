import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Platform IO (Android/iOS): lampiran gambar berupa path file di direktori
/// dokumen aplikasi.
ImageProvider? fileImageProvider(String path) {
  try {
    final file = File(path);
    if (!file.existsSync()) return null;
    return FileImage(file);
  } catch (_) {
    return null;
  }
}

Uint8List? fileBytes(String path) {
  try {
    final file = File(path);
    if (!file.existsSync()) return null;
    return file.readAsBytesSync();
  } catch (_) {
    return null;
  }
}
