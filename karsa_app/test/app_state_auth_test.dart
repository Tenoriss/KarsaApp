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

    test('student profile exposes editable personal info and class grades', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();

      state.selectRoleForLogin(UserRole.siswa);
      expect(state.authenticate('10050001', 'siswa123'), isTrue);

      // Kelas yang dipakai untuk ringkasan nilai mengikuti peran.
      expect(state.learnerClassName, 'Kelas 5');

      // Demo history tasks untuk kelas 5 sudah bernilai 7/10 = 70%.
      final summaries = state.classGradeSummaries;
      expect(summaries, isNotEmpty);
      expect(summaries.length, 9);
      // Matematika kelas 5 punya 3 tugas (1 seed + 2 demo), 1 yang dinilai.
      final math = summaries.firstWhere((s) => s.subject == 'Matematika');
      expect(math.gradedTasks, 1);
      expect(math.totalTasks, 3);
      expect(math.statusLabel, 'Baik');
      expect(math.average, 70);
      expect(math.averageLabel, '70');
      expect(state.classGradeAverage, 70);
      expect(state.classGradedTaskCount, 9);

      // Orang tua melihat kelas anaknya (Kelas 1): IPAS hanya untuk kelas 3-6.
      state.selectRoleForLogin(UserRole.orangtua);
      expect(state.authenticate('10010001', 'ortu123'), isTrue);
      expect(state.learnerClassName, 'Kelas 1');
      final parentSummaries = state.classGradeSummaries;
      expect(
        parentSummaries.any((s) => s.subject == 'Ilmu Pengetahuan Alam dan Sosial (IPAS)'),
        isFalse,
      );
      expect(
        parentSummaries.map((s) => s.subject),
        containsAll(<String>['Matematika', 'Bahasa Indonesia']),
      );
      // Belum ada nilai di kelas 1 -> rata-rata kosong, bukan nol.
      expect(state.classGradeAverage, isNull);
      expect(
        parentSummaries.every((s) => s.gradedTasks == 0 && s.averageLabel == '\u2014'),
        isTrue,
      );

      state.selectRoleForLogin(UserRole.siswa);
      expect(state.authenticate('10050001', 'siswa123'), isTrue);

      // Informasi pribadi dapat diedit dan tersimpan di "@karsa-demo-v1".
      state.openSetting('Informasi pribadi');
      expect(state.screen, 'setting');
      state.setDraftTitle('Nadia Lestari');
      state.setChildClassFromSetting('Kelas 6');
      state.setReligion('Islam');
      state.savePersonalInfo();
      expect(state.screen, 'main');
      expect(state.data.studentName, 'Nadia Lestari');
      expect(state.data.studentClass, 'Kelas 6');
      expect(state.data.childClass, 'Kelas 6');
      expect(state.data.religion, 'Islam');

      // Nama kosong ditolak.
      state.openSetting('Informasi pribadi');
      state.setDraftTitle('   ');
      state.savePersonalInfo();
      expect(state.error, 'Nama tidak boleh kosong.');
      expect(state.screen, 'setting');

      state.dispose();
    });

    test('student notifications and materials are scoped to the learner class', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();

      // Siswa: notifikasi dan materi untuk kelasnya sendiri (Kelas 5).
      state.selectRoleForLogin(UserRole.siswa);
      expect(state.authenticate('10050001', 'siswa123'), isTrue);
      expect(state.data.childClass, 'Kelas 5');

      final notifTitles = state.relevantNotifications.map((n) => n.title).toList();
      expect(notifTitles, contains('Tugas baru · Pecahan dan perbandingan'));
      expect(notifTitles, contains('Materi baru · Ringkasan Pecahan Kelas 5'));
      expect(notifTitles, isNot(contains('Tugas baru · Penjumlahan sampai 20')));

      final studentMaterials = state.data.materials
          .where((m) => m.className == 'Kelas 5')
          .toList();
      expect(studentMaterials.length, 2);
      expect(studentMaterials.first.title, 'Ringkasan Pecahan Kelas 5');

      // Semua notifikasi siswa masih baru, jadi badge dihitung.
      expect(state.unreadEventsCount, 2);

      // Mengetuk notifikasi membuka tugas yang terkait dan menandainya dibaca.
      final taskNotif = state.relevantNotifications
          .firstWhere((n) => n.kind == 'task' && n.className == 'Kelas 5');
      state.markNotification(taskNotif);
      expect(state.screen, 'taskDetail');
      expect(state.isNotificationRead(taskNotif.id), isTrue);
      expect(state.unreadEventsCount, 1);

      // Orang tua: kelas anaknya (Kelas 1), bukan kelas siswa.
      state.selectRoleForLogin(UserRole.orangtua);
      expect(state.authenticate('10010001', 'ortu123'), isTrue);
      expect(state.data.childClass, 'Kelas 1');
      final parentNotifs = state.relevantNotifications.map((n) => n.title).toList();
      expect(parentNotifs, contains('Tugas baru · Penjumlahan sampai 20'));
      expect(parentNotifs, isNot(contains('Tugas baru · Pecahan dan perbandingan')));
      expect(
        state.data.materials.where((m) => m.className == 'Kelas 1').length,
        2,
      );

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
