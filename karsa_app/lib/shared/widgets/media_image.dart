import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/image_source.dart';
import '../../models/media_asset.dart';
import '../../providers/app_state.dart';

/// Menampilkan gambar yang dikelola operator sekolah, dengan aset bawaan
/// sebagai fallback.
///
/// Bila operator belum mengunggah gambar untuk slot tersebut, aset PNG bawaan
/// yang dipakai. Begitu operator memilih gambar baru, gambar itu yang tampil di
/// seluruh aplikasi.
class MediaImage extends StatelessWidget {
  /// Slot media yang dipakai (lihat `MediaAssetSlot`).
  final String slotKey;

  /// Aset bawaan bila slot belum diisi.
  final String fallbackAsset;

  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  const MediaImage({
    super.key,
    required this.slotKey,
    required this.fallbackAsset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final attachment = state.mediaAsset(slotKey);
    final provider = attachment == null
        ? null
        : providerFromAttachmentUri(attachment.uri);

    final fallback = Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
    );

    final image = provider == null
        ? fallback
        : Image(
            image: provider,
            width: width,
            height: height,
            fit: fit,
            semanticLabel: semanticLabel,
            errorBuilder: (context, error, stack) => fallback,
          );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

/// Slot grafis sekolah yang siap dipakai widget lain.
class SchoolMedia {
  static const String logoSlot = MediaAssetSlot.schoolLogoKey;
  static const String studentBannerSlot = MediaAssetSlot.studentBannerKey;
  static const String teacherBannerSlot = MediaAssetSlot.teacherBannerKey;
}
