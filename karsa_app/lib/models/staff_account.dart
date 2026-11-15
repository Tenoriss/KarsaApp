/// Akun pengguna sekolah yang dikelola operator sekolah.
///
/// Operator dapat menambah, mengubah, dan menghapus akun guru maupun wali
/// kelas. Akun ini tersimpan di perangkat ini pada kunci "@karsa-demo-v1".
class StaffAccount {
  final String id;

  /// Nama lengkap pengguna.
  final String name;

  /// Nomor induk pegawai.
  final String nip;

  /// Peran: 'guru' atau 'wali'.
  final String role;

  /// Kelas yang diampu. Kosong berarti semua kelas.
  final String className;

  const StaffAccount({
    required this.id,
    required this.name,
    required this.nip,
    required this.role,
    required this.className,
  });

  bool get isWali => role == 'wali';

  String get roleLabel => isWali ? 'Wali kelas' : 'Guru mata pelajaran';

  factory StaffAccount.fromJson(Map<String, dynamic> json) {
    return StaffAccount(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      nip: (json['nip'] ?? '').toString(),
      role: (json['role'] ?? 'guru').toString(),
      className: (json['className'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'nip': nip,
        'role': role,
        'className': className,
      };

  StaffAccount copyWith({
    String? id,
    String? name,
    String? nip,
    String? role,
    String? className,
  }) {
    return StaffAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      nip: nip ?? this.nip,
      role: role ?? this.role,
      className: className ?? this.className,
    );
  }
}
