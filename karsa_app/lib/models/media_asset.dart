import 'attachment_file.dart';

/// Satu slot grafis yang dikelola operator sekolah.
///
/// Slot disimpan sebagai pasangan `key -> AttachmentFile` di dalam
/// `KarsaStoreData.mediaAssets`, sehingga gambar yang dipilih operator tetap
/// ada setelah aplikasi ditutup (kunci `@karsa-demo-v1`).
class MediaAssetSlot {
  /// Kunci slot, dipakai sebagai key di store.
  final String key;

  /// Nama slot yang ditampilkan ke pengguna.
  final String label;

  /// Penjelasan singkat tempat slot ini dipakai.
  final String description;

  /// Aset bawaan yang dipakai sampai operator mengunggah gambar sendiri.
  final String fallbackAsset;

  const MediaAssetSlot({
    required this.key,
    required this.label,
    required this.description,
    required this.fallbackAsset,
  });

  static const String schoolLogoKey = 'school-logo';
  static const String studentBannerKey = 'banner-siswa';
  static const String teacherBannerKey = 'banner-guru';

  static const List<MediaAssetSlot> slots = <MediaAssetSlot>[
    MediaAssetSlot(
      key: schoolLogoKey,
      label: 'Logo sekolah',
      description: 'Tampil di kartu identitas sekolah pada semua layar.',
      fallbackAsset: 'assets/images/logo-sd-karitas.png',
    ),
    MediaAssetSlot(
      key: studentBannerKey,
      label: 'Banner siswa',
      description: 'Gambar besar di beranda siswa dan orang tua.',
      fallbackAsset: 'assets/images/student-banner.png',
    ),
    MediaAssetSlot(
      key: teacherBannerKey,
      label: 'Banner guru',
      description: 'Gambar besar di beranda guru dan wali kelas.',
      fallbackAsset: 'assets/images/teacher-banner.png',
    ),
  ];

  static MediaAssetSlot? byKey(String key) {
    for (final slot in slots) {
      if (slot.key == key) return slot;
    }
    return null;
  }
}

/// Pembungkus satu slot media yang sudah terisi.
class MediaAsset {
  final MediaAssetSlot slot;
  final AttachmentFile attachment;

  const MediaAsset({required this.slot, required this.attachment});

  String get key => slot.key;
  String get label => slot.label;
}
