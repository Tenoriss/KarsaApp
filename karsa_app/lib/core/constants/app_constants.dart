class AppConstants {
  AppConstants._();

  static const String storeKey = '@karsa-demo-v1';
  static const String schoolName = 'SD KARITAS PURWOKERTO';
  static const String schoolCaption = 'Karitas Sahabat Belajar';
  static const String brandLabel = '✿ KARSA';
  static const String waliClass = 'Kelas 1';

  /// Lama splash tampil sebelum masuk ke form login.
  ///
  /// Satu sumber kebenaran: dipakai [SplashPage] dan diuji oleh
  /// `splash_duration_test.dart` / `preview/test_preview.js`. Permintaan
  /// pemilik produk: **5-7 detik**; dipakai 6 detik (tengah rentang). Ubah di
  /// sini bila perlu disesuaikan lagi.
  static const Duration splashDuration = Duration(seconds: 6);

  /// Lama satu putaran animasi logo di splash (skala + cahaya + cincin).
  ///
  /// Splash 6 detik berarti animasinya berulang beberapa kali; pakai durasi
  /// yang membagi habis 6 detik supaya tidak terpotong di tengah putaran.
  static const Duration splashLogoCycle = Duration(seconds: 2);

  static const List<String> classes = <String>[
    'Kelas 1',
    'Kelas 2',
    'Kelas 3',
    'Kelas 4',
    'Kelas 5',
    'Kelas 6',
  ];

  static const List<String> parentClasses = <String>[
    'Kelas 1',
    'Kelas 2',
    'Kelas 3',
    'Kelas 4',
  ];

  static const List<String> studentClasses = <String>[
    'Kelas 5',
    'Kelas 6',
  ];

  static const List<String> attendanceStatuses = <String>[
    'Hadir',
    'Izin',
    'Sakit',
    'Alpa',
  ];

  static const List<List<String>> moodOptions = <List<String>>[
    <String>['😊', 'Senang'],
    <String>['😌', 'Tenang'],
    <String>['😴', 'Lelah'],
    <String>['😔', 'Sedih'],
  ];

  // Asset paths
  static const String assetIcon = 'assets/images/icon.png';
  static const String assetLoginLogo = 'assets/images/karsa-login-logo.png';
  static const String assetSchoolLogo = 'assets/images/logo-sd-karitas.png';
  static const String assetSplashArt = 'assets/images/splash-art.png';
  static const String assetStudentBanner = 'assets/images/student-banner.png';
  static const String assetTeacherBanner = 'assets/images/teacher-banner.png';
}
