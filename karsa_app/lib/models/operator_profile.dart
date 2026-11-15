/// Data pribadi lengkap operator sekolah.
///
/// Layar "Informasi pribadi" operator sebelumnya hanya berisi satu kolom nama,
/// sehingga tidak ada tempat untuk NIP, jabatan, kontak, atau unit kerja.
/// Profil ini menampung semuanya dan disimpan di `@karsa-demo-v1` lewat
/// `KarsaStoreData.operatorProfile`.
///
/// Semua kolom opsional kecuali [name]: operator demo boleh mengosongkan
/// kontak, tetapi nama yang kosong selalu ditolak supaya identitas di beranda
/// tidak hilang.
class OperatorProfile {
  /// Nama lengkap operator. Sama dengan `state.operatorName`.
  final String name;

  /// Nomor induk pegawai. Bawaan mengikuti akun demo `19870003`.
  final String nip;

  /// Jabatan yang tampil di kartu profil, mis. "Operator Sekolah".
  final String role;

  /// Alamat surel kantor. Boleh kosong.
  final String email;

  /// Nomor telepon/WhatsApp. Boleh kosong.
  final String phone;

  /// Unit kerja, mis. "SD Karitas Purwokerto".
  final String unit;

  const OperatorProfile({
    required this.name,
    this.nip = '',
    this.role = '',
    this.email = '',
    this.phone = '',
    this.unit = '',
  });

  /// Profil bawaan akun demo operator (`19870003` / `operator123`).
  factory OperatorProfile.defaults() => const OperatorProfile(
        name: 'Operator Sekolah',
        nip: '19870003',
        role: 'Operator Sekolah',
        email: '',
        phone: '',
        unit: 'SD Karitas Purwokerto',
      );

  /// Membaca profil dari JSON yang tersimpan, dengan fallback aman.
  ///
  /// Data lama belum punya objek `operatorProfile` sama sekali; saat itu
  /// terjadi, kolom non-nama diisi nilai bawaan dan [fallbackName] dipakai
  /// sebagai nama supaya nama yang terlanjur diubah operator tidak hilang.
  factory OperatorProfile.fromSaved(Object? saved, {required String fallbackName}) {
    if (saved is! Map) {
      return OperatorProfile.defaults().copyWith(name: fallbackName);
    }
    final base = OperatorProfile.defaults();
    String read(String key, String fallback) {
      final value = saved[key];
      if (value == null) return fallback;
      final text = value.toString().trim();
      return text.isEmpty ? fallback : text;
    }

    return OperatorProfile(
      name: read('name', fallbackName),
      nip: read('nip', base.nip),
      role: read('role', base.role),
      // Kontak memang boleh kosong: jangan diisi bawaan supaya operator tahu
      // bahwa dirinya belum mengisinya.
      email: (saved['email'] ?? '').toString().trim(),
      phone: (saved['phone'] ?? '').toString().trim(),
      unit: read('unit', base.unit),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'nip': nip,
        'role': role,
        'email': email,
        'phone': phone,
        'unit': unit,
      };

  OperatorProfile copyWith({
    String? name,
    String? nip,
    String? role,
    String? email,
    String? phone,
    String? unit,
  }) {
    return OperatorProfile(
      name: name ?? this.name,
      nip: nip ?? this.nip,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      unit: unit ?? this.unit,
    );
  }

  /// Inisial dua huruf untuk avatar, mis. "Operator Sekolah" -> "OS".
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final single = parts.first;
      return single.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  /// Apakah minimal satu kanal kontak sudah diisi.
  bool get hasContact => email.isNotEmpty || phone.isNotEmpty;

  /// Jumlah kolom yang sudah diisi, dipakai untuk indikator kelengkapan.
  int get filledFields {
    var count = 0;
    if (name.isNotEmpty) count++;
    if (nip.isNotEmpty) count++;
    if (role.isNotEmpty) count++;
    if (email.isNotEmpty) count++;
    if (phone.isNotEmpty) count++;
    if (unit.isNotEmpty) count++;
    return count;
  }

  /// Jumlah seluruh kolom profil.
  static const int totalFields = 6;
}
