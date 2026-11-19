import 'package:flutter_test/flutter_test.dart';
import 'package:karsa_app/core/utils/offline_summarizer.dart';
import 'package:karsa_app/models/attachment_file.dart';
import 'package:karsa_app/models/student_profile.dart';
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

    test('operator sekolah mengelola seluruh isi aplikasi', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();

      state.selectRoleForLogin(UserRole.operator);
      expect(state.authenticate('19870003', 'operator123'), isTrue);
      expect(state.role, UserRole.operator);
      expect(state.isOperator, isTrue);
      expect(state.canManageAll, isTrue);
      // Operator punya enam tab: Profil di paling kanan, di sebelah Media.
      expect(state.role!.navTabs, <String>[
        'Beranda',
        'Siswa',
        'Kelas',
        'Materi',
        'Media',
        'Profil',
      ]);

      // Roster siswa tersedia lintas kelas.
      expect(state.roster.length, 24);
      expect(state.rosterForClass('Kelas 5').length, 4);
      expect(state.activeStudentCount, 24);

      // Operator boleh menambah, mengubah, dan menghapus siswa.
      final added = StudentProfile(
        id: 'uji-1',
        nisn: '10059999',
        name: 'Uji Operator',
        className: 'Kelas 3',
        gender: 'P',
        parentName: 'Ibu Uji',
      );
      state.addStudent(added);
      expect(state.roster.length, 25);
      expect(state.rosterForClass('Kelas 3').length, 5);

      state.updateStudent(added.copyWith(name: 'Uji Operator Diperbarui'));
      expect(
        state.roster.firstWhere((s) => s.id == 'uji-1').name,
        'Uji Operator Diperbarui',
      );

      state.removeStudent('uji-1');
      expect(state.roster.length, 24);

      // Graphic sekolah dikelola lewat slot media.
      expect(state.mediaAsset('school-logo'), isNull);
      state.setMediaAsset(
        'school-logo',
        const AttachmentFile(
          name: 'logo.png',
          mimeType: 'image/png',
          uri: 'data:image/png;base64,AAAA',
          size: 4,
        ),
      );
      expect(state.mediaAsset('school-logo'), isNotNull);
      expect(state.mediaAsset('school-logo')!.mimeType, 'image/png');
      state.removeMediaAsset('school-logo');
      expect(state.mediaAsset('school-logo'), isNull);

      // Operator boleh menghapus data milik guru dan wali.
      final materialId = state.data.materials.isNotEmpty
          ? state.data.materials.first.id
          : '';
      if (materialId.isNotEmpty) {
        final before = state.data.materials.length;
        state.deleteMaterial(materialId);
        expect(state.data.materials.length, before - 1);
      }

      // Data pribadi operator tidak boleh menimpa nama siswa.
      state.openSetting('Informasi pribadi');
      expect(state.screen, 'setting');
      state.setDraftTitle('Sari Operator');
      state.savePersonalInfo();
      expect(state.screen, 'main');
      expect(state.data.operatorName, 'Sari Operator');
      expect(state.data.studentName, 'Dimas Nugroho');

      // Role lain tidak punya akses managing penuh.
      state.selectRoleForLogin(UserRole.guru);
      expect(state.authenticate('19870002', 'guru123'), isTrue);
      expect(state.canManageAll, isFalse);

      state.dispose();
    });

    test('login tunggal mendeteksi peran dari kredensial', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();

      // Tanpa memilih peran lebih dulu: cukup NIP/NISN.
      expect(state.roleForCredentials('19870003', 'operator123'), UserRole.operator);
      expect(state.roleForCredentials('19870001', 'wali123'), UserRole.wali);
      expect(state.roleForCredentials('19870002', 'guru123'), UserRole.guru);
      expect(state.roleForCredentials('10050001', 'siswa123'), UserRole.siswa);
      expect(state.roleForCredentials('10010001', 'ortu123'), UserRole.orangtua);

      // Kombinasi salah tidak menghasilkan peran.
      expect(state.roleForCredentials('19870003', 'salah'), isNull);
      expect(state.roleForCredentials('99999999', 'operator123'), isNull);

      // Galat terpisah untuk kolom kosong.
      expect(state.authenticate(), isFalse);
      expect(state.error, 'Isi NIP atau NISN terlebih dahulu.');
      state.setUsername('19870003');
      expect(state.authenticate(), isFalse);
      expect(state.error, 'Isi kata sandi terlebih dahulu.');

      // Masuk tanpa pernah memanggil selectRoleForLogin.
      state.setPassword('operator123');
      expect(state.authenticate(), isTrue);
      expect(state.role, UserRole.operator);
      expect(state.screen, 'main');

      state.dispose();
    });

    test('splash langsung ke login, bukan ke pemilih peran', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();
      expect(state.screen, 'splash');
      state.finishSplash();
      expect(state.screen, 'login');
      state.dispose();
    });

    test('"Ingat saya" menyimpan identitas tanpa kata sandi', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();

      expect(state.rememberMe, isTrue);
      state.setUsername('19870002');
      state.setPassword('guru123');
      expect(state.authenticate(), isTrue);

      final saved = state.rememberedLogin;
      expect(saved, isNotNull);
      expect(saved!.identifier, '19870002');
      expect(saved.roleName, 'guru');
      // Kata sandi tidak pernah ikut tersimpan.
      expect(saved.toJson().containsKey('password'), isFalse);

      state.dispose();
    });

    test('keluar tetap mengingat identitas, "Bukan saya" menghapusnya', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();

      state.setUsername('19870001');
      state.setPassword('wali123');
      state.authenticate();
      state.logout();

      // Kembali ke form login dengan identitas terisi, sandi kosong.
      expect(state.screen, 'login');
      expect(state.username, '19870001');
      expect(state.password, isEmpty);
      expect(state.rememberedLogin, isNotNull);

      state.forgetRememberedLogin();
      expect(state.rememberedLogin, isNull);
      expect(state.username, isEmpty);

      state.dispose();
    });

    test('"Ingat saya" dimatikan tidak menyimpan apa pun', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();

      state.setRememberMe(false);
      state.setUsername('10050001');
      state.setPassword('siswa123');
      expect(state.authenticate(), isTrue);
      expect(state.rememberedLogin, isNull);

      state.dispose();
    });

    test('identitas tersimpan mengisi form setelah splash', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final first = AppState(autoLoad: false);
      await first.loadFromStorage();
      first.setUsername('19870003');
      first.setPassword('operator123');
      first.authenticate();
      // Penyimpanan berjalan asinkron; tunggu sampai benar-benar tertulis.
      final prefs = await SharedPreferences.getInstance();
      for (var i = 0; i < 50 && !prefs.containsKey('@karsa-demo-v1'); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      first.dispose();

      final reopened = AppState(autoLoad: false);
      await reopened.loadFromStorage();
      expect(reopened.screen, 'splash');
      reopened.finishSplash();
      expect(reopened.screen, 'login');
      // Terisi otomatis: tidak perlu mengetik ulang.
      expect(reopened.username, '19870003');
      expect(reopened.password, isEmpty);
      expect(reopened.hasRememberedLogin, isTrue);

      reopened.dispose();
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
