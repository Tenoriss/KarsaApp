enum UserRole {
  wali('wali'),
  guru('guru'),
  orangtua('orangtua'),
  siswa('siswa');

  final String key;
  const UserRole(this.key);

  bool get isTeacher => this == UserRole.guru || this == UserRole.wali;
  bool get isWali => this == UserRole.wali;
  bool get isGuru => this == UserRole.guru;
  bool get isStudent => this == UserRole.siswa;
  bool get isParent => this == UserRole.orangtua;

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
