import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:karsa_app/core/constants/app_constants.dart';
import 'package:karsa_app/models/user_role.dart';
import 'package:karsa_app/providers/app_state.dart';

/// Splash tampil 10 detik dengan logo beranimasi sebelum form login.
///
/// Permintaan pemilik produk (terbaru): 10 detik, bukan 15-20 detik lagi.
/// Tes ini menjaga agar durasinya tidak diam-diam berubah, dan memastikan
/// splash tetap berakhir di form login.
void main() {
  group('Durasi splash', () {
    test('durasi splash tepat 10 detik', () {
      final seconds = AppConstants.splashDuration.inSeconds;
      expect(seconds, 10, reason: 'permintaan terakhir: 10 detik, dapat $seconds');
      expect(AppConstants.splashDuration.inMilliseconds, 10000);
    });

    test('durasi splash bukan nilai lama (18 detik / 2,3 detik)', () {
      expect(AppConstants.splashDuration.inSeconds, isNot(18));
      expect(AppConstants.splashDuration.inMilliseconds, isNot(2300));
    });

    test('animasi logo membagi habis durasi splash', () {
      // Satu putaran 2,5 detik: 10 / 2,5 = 4 putaran penuh, jadi animasi
      // tidak pernah terpotong di tengah saat splash selesai.
      final cycle = AppConstants.splashLogoCycle.inMilliseconds;
      expect(cycle, greaterThan(0));
      expect(AppConstants.splashDuration.inMilliseconds % cycle, 0,
          reason: 'durasi splash harus kelipatan satu putaran animasi logo');
      expect(cycle, lessThanOrEqualTo(3000),
          reason: 'satu putaran cukup cepat agar terlihat hidup');
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
