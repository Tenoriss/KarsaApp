import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:karsa_app/core/constants/app_constants.dart';
import 'package:karsa_app/models/user_role.dart';
import 'package:karsa_app/providers/app_state.dart';

/// Splash sengaja tampil lama sebelum form login.
///
/// Permintaan pemilik produk: 15-20 detik. Tes ini menjaga agar durasinya
/// tidak diam-diam kembali ke ~2 detik, dan memastikan splash tetap berakhir
/// di form login.
void main() {
  group('Durasi splash', () {
    test('durasi splash berada di rentang 15-20 detik', () {
      final seconds = AppConstants.splashDuration.inSeconds;
      expect(seconds, greaterThanOrEqualTo(15),
          reason: 'splash minimal 15 detik, dapat $seconds');
      expect(seconds, lessThanOrEqualTo(20),
          reason: 'splash maksimal 20 detik, dapat $seconds');
    });

    test('durasi splash bukan 2-3 detik lagi', () {
      // Nilai lama yang diminta diganti.
      expect(AppConstants.splashDuration.inMilliseconds, isNot(2300));
      expect(AppConstants.splashDuration.inSeconds, greaterThan(3));
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
