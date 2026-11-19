import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:karsa_app/core/constants/app_constants.dart';
import 'package:karsa_app/data/curriculum_data.dart';
import 'package:karsa_app/models/user_role.dart';
import 'package:karsa_app/providers/app_state.dart';

/// Pengumuman oleh guru mata pelajaran.
///
/// Guru hanya mengajar satu mapel, jadi pengumumannya harus dibatasi ke kelas
/// yang benar-benar diajar mapel itu - bukan seluruh kelas sekolah.
void main() {
  group('Pengumuman guru mapel', () {
    late AppState state;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    Future<AppState> loginGuru(String subject) async {
      final s = AppState(autoLoad: false);
      await s.loadFromStorage();
      s.selectRoleForLogin(UserRole.guru);
      expect(s.authenticate('19870002', 'guru123'), isTrue);
      s.setTeacherSubject(subject);
      return s;
    }

    test('guru Matematika mengajar semua kelas', () async {
      state = await loginGuru('Matematika');
      expect(state.teacherClasses, AppConstants.classes,
          reason: 'Matematika ada di semua kelas');
      state.dispose();
    });

    test('guru IPAS hanya mengajar Kelas 3 ke atas', () async {
      state = await loginGuru(
        'Ilmu Pengetahuan Alam dan Sosial (IPAS)',
      );
      expect(state.teacherClasses, isNotEmpty,
          reason: 'guru IPAS harus punya kelas');
      expect(state.teacherClasses, isNot(contains('Kelas 1')),
          reason: 'IPAS tidak diajarkan di Kelas 1');
      expect(state.teacherClasses, isNot(contains('Kelas 2')));
      expect(state.teacherClasses, contains('Kelas 3'),
          reason: 'IPAS mulai Kelas 3');

      // Konsisten dengan kurikulum: setiap kelas yang dilaporkan memang
      // memuat mapel ini.
      for (final c in state.teacherClasses) {
        expect(CurriculumData.subjectsForClass(c), contains(
          'Ilmu Pengetahuan Alam dan Sosial (IPAS)',
        ));
      }
      state.dispose();
    });

    test('form pengumuman guru memakai kelas yang diajar, bukan filter tugas',
        () async {
      state = await loginGuru(
        'Ilmu Pengetahuan Alam dan Sosial (IPAS)',
      );
      // Filter daftar tugas sengaja diset ke kelas yang tidak diajar.
      state.setFilter('Kelas 1');
      state.openForm('announcementForm');

      expect(state.screen, 'announcementForm');
      expect(state.teacherClasses, isNot(contains(state.draftClass)),
          reason: 'kelas awal tidak boleh kelas yang tidak diajar');
      expect(state.teacherClasses, contains(state.draftClass),
          reason: 'kelas awal harus salah satu kelas yang diajar, dapat '
              '${state.draftClass}');
      state.dispose();
    });

    test('guru bisa menyimpan pengumuman untuk kelas yang diajar', () async {
      state = await loginGuru('Matematika');
      final before = state.data.announcements.length;
      final target = state.teacherClasses.first;

      state.openForm('announcementForm');
      state.setDraftClass(target);
      state.setDraftTitle('Ulangan Matematika');
      state.setDraftBody('Belajar bab pecahan untuk ulangan besok.');
      state.saveAnnouncement();

      expect(state.data.announcements.length, before + 1);
      final created = state.data.announcements.first;
      expect(created.title, 'Ulangan Matematika');
      expect(created.body, 'Belajar bab pecahan untuk ulangan besok.');
      expect(created.className, target);
      expect(created.category, 'PENGUMUMAN GURU');
      state.dispose();
    });

    test('guru boleh mengumumkan ke semua kelas', () async {
      state = await loginGuru('Matematika');
      final before = state.data.announcements.length;

      state.openForm('announcementForm');
      state.setDraftClass('Semua kelas');
      state.setDraftTitle('Libur bersama');
      state.setDraftBody('Sekolah libur hari Jumat.');
      state.saveAnnouncement();

      expect(state.data.announcements.length, before + 1);
      expect(state.data.announcements.first.className, 'Semua kelas');
      state.dispose();
    });

    test('guru ditolak saat mengumumkan ke kelas yang tidak diajar',
        () async {
      state = await loginGuru(
        'Ilmu Pengetahuan Alam dan Sosial (IPAS)',
      );
      final before = state.data.announcements.length;

      state.openForm('announcementForm');
      // Paksa kelas di luar kewenangan (meniru jalur/kelas sisa).
      state.setDraftClass('Kelas 1');
      state.setDraftTitle('Pengumuman salah kelas');
      state.setDraftBody('Ini tidak boleh tersimpan.');
      state.saveAnnouncement();

      expect(state.data.announcements.length, before,
          reason: 'pengumuman ke kelas yang tidak diajar harus ditolak');
      expect(state.error, isNotEmpty, reason: 'guru diberi tahu alasannya');
      expect(state.error.toLowerCase(), contains('kelas'));
      state.dispose();
    });

    test('judul atau isi kosong ditolak', () async {
      state = await loginGuru('Matematika');
      final before = state.data.announcements.length;

      state.openForm('announcementForm');
      state.setDraftTitle('   ');
      state.setDraftBody('Ada isi tapi tanpa judul.');
      state.saveAnnouncement();
      expect(state.data.announcements.length, before);

      state.setDraftTitle('Ada judul tanpa isi');
      state.setDraftBody('   ');
      state.saveAnnouncement();
      expect(state.data.announcements.length, before);
      expect(state.error, isNotEmpty);
      state.dispose();
    });

    test('pengumuman guru sampai ke siswa di kelas tujuan', () async {
      // Siswa demo berada di Kelas 5.
      state = await loginGuru('Matematika');
      state.openForm('announcementForm');
      state.setDraftClass('Kelas 5');
      state.setDraftTitle('PR Matematika Kelas 5');
      state.setDraftBody('Kerjakan halaman 40.');
      state.saveAnnouncement();
      state.dispose();

      final siswa = AppState(autoLoad: false);
      await siswa.loadFromStorage();
      siswa.selectRoleForLogin(UserRole.siswa);
      expect(siswa.authenticate('10050001', 'siswa123'), isTrue);
      expect(siswa.data.childClass, 'Kelas 5');
      expect(
        siswa.visibleAnnouncements.any((a) => a.title == 'PR Matematika Kelas 5'),
        isTrue,
        reason: 'siswa Kelas 5 harus menerima pengumuman Kelas 5',
      );
      siswa.dispose();
    });

    test('pengumuman guru untuk kelas lain tidak terlihat siswa', () async {
      state = await loginGuru('Matematika');
      state.openForm('announcementForm');
      state.setDraftClass('Kelas 2'); // bukan kelas siswa demo (Kelas 5)
      state.setDraftTitle('Khusus Kelas 2');
      state.setDraftBody('Hanya untuk Kelas 2.');
      state.saveAnnouncement();
      state.dispose();

      final siswa = AppState(autoLoad: false);
      await siswa.loadFromStorage();
      siswa.selectRoleForLogin(UserRole.siswa);
      expect(siswa.authenticate('10050001', 'siswa123'), isTrue);
      expect(
        siswa.visibleAnnouncements.any((a) => a.title == 'Khusus Kelas 2'),
        isFalse,
        reason: 'siswa Kelas 5 tidak boleh menerima pengumuman Kelas 2',
      );
      siswa.dispose();
    });

    test('pengumuman guru untuk satu kelas tidak bocor ke kelas lain',
        () async {
      state = await loginGuru('Matematika');
      state.openForm('announcementForm');
      state.setDraftClass('Kelas 4');
      state.setDraftTitle('Khusus Kelas 4');
      state.setDraftBody('Hanya untuk Kelas 4.');
      state.saveAnnouncement();

      final visible = state.visibleAnnouncements
          .map((a) => a.title)
          .toList();
      expect(visible, contains('Khusus Kelas 4'),
          reason: 'guru melihat pengumumannya sendiri');

      // Wali kelas hanya melihat kelasnya (Kelas 1) + semua kelas.
      state.dispose();
      final wali = AppState(autoLoad: false);
      await wali.loadFromStorage();
      wali.selectRoleForLogin(UserRole.wali);
      expect(wali.authenticate('19870001', 'wali123'), isTrue);
      expect(
        wali.visibleAnnouncements.any((a) => a.title == 'Khusus Kelas 4'),
        isFalse,
        reason: 'wali Kelas 1 tidak boleh menerima pengumuman Kelas 4',
      );
      wali.dispose();
    });

    test('pengumuman guru bertahan setelah data dimuat ulang', () async {
      state = await loginGuru('Matematika');
      state.openForm('announcementForm');
      state.setDraftClass('Kelas 2');
      state.setDraftTitle('Tugas Kelas 2');
      state.setDraftBody('Bawa buku gambar besok.');
      state.saveAnnouncement();
      final savedClass = state.data.announcements.first.className;
      state.dispose();

      final reloaded = AppState(autoLoad: false);
      await reloaded.loadFromStorage();
      final found = reloaded.data.announcements
          .where((a) => a.title == 'Tugas Kelas 2')
          .toList();
      expect(found, hasLength(1), reason: 'pengumuman tersimpan di disk');
      expect(found.first.className, savedClass);
      expect(found.first.category, 'PENGUMUMAN GURU');
      reloaded.dispose();
    });
  });
}
