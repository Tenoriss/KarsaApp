enum UserRole {
  wali('wali'),
  guru('guru'),
  operator('operator'),
  orangtua('orangtua'),
  siswa('siswa');

  final String key;
  const UserRole(this.key);

  bool get isTeacher => this == UserRole.guru || this == UserRole.wali;
  bool get isWali => this == UserRole.wali;
  bool get isGuru => this == UserRole.guru;
  bool get isStudent => this == UserRole.siswa;
  bool get isParent => this == UserRole.orangtua;

  /// Operator sekolah: mengelola seluruh isi aplikasi, termasuk data milik
  /// guru dan wali kelas.
  bool get isOperator => this == UserRole.operator;

  /// Mencari peran dari nama enum yang tersimpan (mis. `'operator'`).
  ///
  /// Mengembalikan `null` bila namanya tidak dikenal, sehingga data tersimpan
  /// yang rusak tidak membuat aplikasi gagal saat dibuka.
  static UserRole? fromName(String name) {
    for (final role in UserRole.values) {
      if (role.name == name) return role;
    }
    return null;
  }

  /// Boleh mengelola data lintas guru/wali (tugas, materi, pengumuman, nilai).
  bool get canManageAll => this == UserRole.operator;

  List<String> get navTabs {
    switch (this) {
      case UserRole.wali:
        return <String>['Beranda', 'Anggota', 'Rekap', 'Agenda', 'Profil'];
      case UserRole.guru:
        return <String>['Beranda', 'Kelas', 'Tugas', 'Kalender', 'Profil'];
      case UserRole.siswa:
        return <String>['Beranda', 'Tugas', 'Profil'];
      case UserRole.orangtua:
        return <String>['Beranda', 'Tugas', 'Latihan', 'Profil'];
      case UserRole.operator:
        return <String>[
          'Beranda',
          'Siswa',
          'Kelas',
          'Materi',
          'Media',
          'Profil',
        ];
    }
  }

  static UserRole? fromKey(String? raw) {
    if (raw == null) return null;
    for (final role in UserRole.values) {
      if (role.key == raw) return role;
    }
    return null;
  }
}
