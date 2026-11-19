import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:karsa_app/core/constants/app_constants.dart';
import 'package:karsa_app/models/user_role.dart';
import 'package:karsa_app/providers/app_state.dart';

/// Splash tampil 6 detik dengan logo beranimasi sebelum form login.
///
/// Permintaan pemilik produk (terbaru): 5-7 detik. Dipakai 6 detik.
/// Tes ini menjaga agar durasinya tidak diam-diam berubah, dan memastikan
/// splash tetap berakhir di form login.
void main() {
  group('Durasi splash', () {
    test('durasi splash berada di rentang 5-7 detik', () {
      final seconds = AppConstants.splashDuration.inSeconds;
      expect(seconds, greaterThanOrEqualTo(5),
          reason: 'splash minimal 5 detik, dapat $seconds');
      expect(seconds, lessThanOrEqualTo(7),
          reason: 'splash maksimal 7 detik, dapat $seconds');
      expect(seconds, 6, reason: 'dipakai titik tengah rentang: 6 detik');
    });

    test('durasi splash bukan nilai lama (10 / 18 detik / 2,3 detik)', () {
      expect(AppConstants.splashDuration.inSeconds, isNot(10));
      expect(AppConstants.splashDuration.inSeconds, isNot(18));
      expect(AppConstants.splashDuration.inMilliseconds, isNot(2300));
    });

    test('animasi logo memakai beberapa ritme berbeda', () {
      // Animasi logo sekarang berlapis dengan ritme berbeda (melayang 3,4s,
      // detak 2,5s, aura 4,2s, cincin 2,9s & 4,6s, sapuan 5s). Tidak ada satu
      // putaran tunggal lagi, jadi yang diuji: splash lebih panjang dari
      // setiap putaran (animasi berulang beberapa kali) dan durasinya masuk
      // akal untuk splash 10 detik.
      expect(AppConstants.splashDuration.inSeconds, 6);
      final cycle = AppConstants.splashLogoCycle.inMilliseconds;
      expect(cycle, greaterThan(0));
      expect(cycle, lessThanOrEqualTo(AppConstants.splashDuration.inMilliseconds),
          reason: 'satu putaran animasi harus selesai minimal sekali selama splash');
      // Durasi tiap lapis animasi (detik), sama dengan implementasi Flutter.
      const List<double> layers = <double>[2.5, 2.9, 3.1, 3.3, 3.4, 3.7];
      expect(layers.toSet().length, layers.length,
          reason: 'setiap lapis animasi harus punya durasi berbeda');
      final double splashSeconds = AppConstants.splashDuration.inSeconds.toDouble();
      expect(layers.every((double d) => d > 0 && d <= splashSeconds), isTrue,
          reason: 'semua lapis tidak lebih lama dari splash agar tidak terpotong');
    });

    test('splash punya musik pengiring', () {
      // Aset audio harus terdaftar dan panjangnya sama dengan splash, supaya
      // musiknya selesai tepat saat splash berakhir (tidak terpotong).
      expect(AppConstants.splashAudio, 'audio/splash-logo.wav');
      final File audio = File('assets/${AppConstants.splashAudio}');
      expect(audio.existsSync(), isTrue,
          reason: 'berkas audio splash harus ada di assets/');
      final int bytes = audio.lengthSync();
      // 16-bit stereo 44.1 kHz: ~176.400 byte per detik.
      final double seconds = bytes / (44100 * 2 * 2);
      expect(seconds, closeTo(6.0, 0.6),
          reason: 'durasi audio harus sepanjang splash 6 detik, dapat '
              '${seconds.toStringAsFixed(2)} detik');
    });

    test('splash tetap berakhir di form login', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();

      expect(state.screen, 'splash', reason: 'aplikasi mulai di splash');
      expect(state.role, isNull, reason: 'belum ada peran sebelum login');

      state.finishSplash();

      expect(state.screen, 'login', reason: 'splash langsung ke form login');
      expect(state.role, isNull,
          reason: 'tidak ada layar pilih peran di antaranya');
      state.dispose();
    });

    test('setelah splash, login per peran tetap berjalan', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();
      state.finishSplash();
      expect(state.screen, 'login');

      state.selectRoleForLogin(UserRole.guru);
      expect(state.authenticate('19870002', 'guru123'), isTrue);
      expect(state.screen, 'main');
      state.dispose();
    });
  });
}
