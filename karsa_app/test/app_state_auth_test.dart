import 'package:flutter_test/flutter_test.dart';
import 'package:karsa_app/core/utils/offline_summarizer.dart';
import 'package:karsa_app/models/user_role.dart';
import 'package:karsa_app/providers/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppState authentication & offline summarizer', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('validates all four demo accounts and rejects wrong credentials', () async {
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();

      state.selectRoleForLogin(UserRole.wali);
      expect(state.authenticate('19870001', 'salah'), isFalse);
      expect(state.error, 'NIP/NISN atau kata sandi tidak sesuai.');
      expect(state.authenticate('19870001', 'wali123'), isTrue);
      expect(state.screen, 'main');
      expect(state.filter, 'Kelas 1');

      state.selectRoleForLogin(UserRole.guru);
      expect(state.authenticate('19870002', 'guru123'), isTrue);

      state.selectRoleForLogin(UserRole.orangtua);
      expect(state.authenticate('10010001', 'ortu123'), isTrue);
      expect(state.data.childClass, 'Kelas 1');

      state.selectRoleForLogin(UserRole.siswa);
      expect(state.authenticate('10050001', 'siswa123'), isTrue);
      expect(state.data.childClass, 'Kelas 5');

      state.dispose();
    });

    test('OfflineSummarizer picks up to first three sentences', () {
      const sample =
          'Akar menyerap air dari tanah. Batang menyalurkan nutrisi! Daun melakukan fotosintesis? Bunga menjadi buah.';
      final summary = OfflineSummarizer.summarizeFirstThreeSentences(sample);
      expect(
        summary,
        'Akar menyerap air dari tanah. Batang menyalurkan nutrisi! Daun melakukan fotosintesis?',
      );
    });
  });
}
