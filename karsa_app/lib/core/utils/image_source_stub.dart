import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Tanpa `dart:io` (web) tidak ada path file; gambar selalu berupa data URI.
ImageProvider? fileImageProvider(String path) => null;

Uint8List? fileBytes(String path) => null;
