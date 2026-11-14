import 'user_role.dart';

class DemoAccount {
  final UserRole role;
  final String id;
  final String password;
  final String label;
  final String idFieldLabel;
  final String forgotFieldLabel;
  final String loginTitle;
  final String loginSubtitle;
  final String roleCardTitle;
  final String roleCardSubtitle;
  final String roleEmoji;

  const DemoAccount({
    required this.role,
    required this.id,
    required this.password,
    required this.label,
    required this.idFieldLabel,
    required this.forgotFieldLabel,
    required this.loginTitle,
    required this.loginSubtitle,
    required this.roleCardTitle,
    required this.roleCardSubtitle,
    required this.roleEmoji,
  });

  static const Map<UserRole, DemoAccount> accounts = <UserRole, DemoAccount>{
    UserRole.wali: DemoAccount(
      role: UserRole.wali,
      id: '19870001',
      password: 'wali123',
      label: 'Wali kelas',
      idFieldLabel: 'NIP',
      forgotFieldLabel: 'NIP',
      loginTitle: 'Selamat datang,\nWali Kelas!',
      loginSubtitle: 'Masuk untuk melanjutkan',
      roleCardTitle: 'Saya Wali Kelas',
      roleCardSubtitle: 'Pantau kelas, siswa, dan perkembangan belajar.',
      roleEmoji: '👩🏻‍🏫',
    ),
    UserRole.guru: DemoAccount(
      role: UserRole.guru,
      id: '19870002',
      password: 'guru123',
      label: 'Guru mata pelajaran',
      idFieldLabel: 'NIP',
      forgotFieldLabel: 'NIP',
      loginTitle: 'Selamat datang,\nGuru!',
      loginSubtitle: 'Masuk untuk melanjutkan',
      roleCardTitle: 'Saya Guru Mata Pelajaran',
      roleCardSubtitle: 'Kelola tugas berdasarkan mata pelajaran dan kelas.',
      roleEmoji: '📚',
    ),
    UserRole.orangtua: DemoAccount(
      role: UserRole.orangtua,
      id: '10010001',
      password: 'ortu123',
      label: 'Orang tua / wali',
      idFieldLabel: 'NISN',
      forgotFieldLabel: 'NISN anak',
      loginTitle: 'Halo, Orang Tua!',
      loginSubtitle: 'Untuk pendamping anak kelas 1–4',
      roleCardTitle: 'Saya Orang Tua/Wali',
      roleCardSubtitle: 'Dampingi anak kelas 1–4 belajar dan mengerjakan tugas.',
      roleEmoji: '👩🏻',
    ),
    UserRole.siswa: DemoAccount(
      role: UserRole.siswa,
      id: '10050001',
      password: 'siswa123',
      label: 'Siswa kelas 5–6',
      idFieldLabel: 'NISN',
      forgotFieldLabel: 'NISN anak',
      loginTitle: 'Halo, Siswa!',
      loginSubtitle: 'Untuk siswa kelas 5–6',
      roleCardTitle: 'Saya Siswa',
      roleCardSubtitle: 'Kelas 5–6: lihat dan kerjakan tugas secara mandiri.',
      roleEmoji: '🎒',
    ),
  };

  static DemoAccount forRole(UserRole role) => accounts[role]!;
}
