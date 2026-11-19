/// Login yang diingat lewat centang "Ingat saya".
///
/// Menyimpan identitas terakhir yang berhasil masuk sehingga pengguna tidak
/// perlu mengetik ulang. **Kata sandi tidak pernah disimpan** — hanya identitas
/// dan peran, supaya aman dipakai di perangkat bersama.
class RememberedLogin {
  /// NIP atau NISN terakhir yang berhasil masuk.
  final String identifier;

  /// Peran yang terdeteksi dari [identifier], disimpan sebagai nama enum
  /// (mis. `'operator'`) supaya tidak perlu import `UserRole` di model data.
  final String roleName;

  const RememberedLogin({
    required this.identifier,
    required this.roleName,
  });

  /// Membaca dari JSON tersimpan. Mengembalikan `null` bila tidak valid,
  /// sehingga store lama tanpa kunci ini tetap aman.
  static RememberedLogin? fromSaved(Object? saved) {
    if (saved is! Map) return null;
    final identifier = (saved['identifier'] ?? '').toString().trim();
    final roleName = (saved['roleName'] ?? '').toString().trim();
    if (identifier.isEmpty || roleName.isEmpty) return null;
    return RememberedLogin(identifier: identifier, roleName: roleName);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'identifier': identifier,
        'roleName': roleName,
      };

  RememberedLogin copyWith({String? identifier, String? roleName}) {
    return RememberedLogin(
      identifier: identifier ?? this.identifier,
      roleName: roleName ?? this.roleName,
    );
  }
}
