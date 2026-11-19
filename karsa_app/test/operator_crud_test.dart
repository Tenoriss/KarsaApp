import 'package:flutter_test/flutter_test.dart';
import 'package:karsa_app/data/curriculum_data.dart';
import 'package:karsa_app/models/staff_account.dart';
import 'package:karsa_app/models/student_profile.dart';
import 'package:karsa_app/models/user_role.dart';
import 'package:karsa_app/providers/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cakupan operator sekolah: operator boleh menambah, mengubah, dan menghapus
/// tugas, materi, pengumuman, agenda, nilai, kelas, akun guru/wali, dan data
/// siswa. Semua perubahan harus tetap berada di store "@karsa-demo-v1".
void main() {
  group('Operator sekolah - CRUD seluruh data', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    Future<AppState> loggedInOperator() async {
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();
      state.selectRoleForLogin(UserRole.operator);
      expect(state.authenticate('19870003', 'operator123'), isTrue);
      return state;
    }

    test('operator menambah, mengubah, dan menghapus tugas', () async {
      final state = await loggedInOperator();

      final before = state.data.tasks.length;
      state.openOperatorTaskForm();
      expect(state.screen, 'operatorTaskForm');
      state.setDraftTitle('Tugas operator');
      state.setDraftSubject('Matematika');
      state.setDraftClass('Kelas 5');
      state.setDraftMinutes('45');
      state.setDraftDue('2030-12-31');
      state.saveOperatorTask();
      expect(state.data.tasks.length, before + 1);
      expect(state.screen, 'operatorTasks');

      final created = state.data.tasks.lastWhere((t) => t.title == 'Tugas operator');
      expect(created.className, 'Kelas 5');
      expect(created.minutes, '45');

      // Ubah tugas yang sama.
      state.openOperatorTaskForm(created.id);
      expect(state.draftTaskId, created.id);
      expect(state.draftTitle, 'Tugas operator');
      state.setDraftTitle('Tugas operator diubah');
      state.saveOperatorTask();
      expect(
        state.data.tasks.firstWhere((t) => t.id == created.id).title,
        'Tugas operator diubah',
      );

      state.deleteTask(created.id);
      expect(state.data.tasks.length, before);
      expect(state.data.tasks.any((t) => t.id == created.id), isFalse);

      state.dispose();
    });

    test('operator menambah, mengubah, dan menghapus materi', () async {
      final state = await loggedInOperator();

      final before = state.data.materials.length;
      state.openOperatorMaterialForm();
      expect(state.screen, 'operatorMaterialForm');
      state.setDraftTitle('Materi operator');
      state.setDraftSubject('Bahasa Indonesia');
      state.setDraftClass('Kelas 3');
      state.setSummaryText('Ringkasan dari operator');
      state.saveOperatorMaterial();
      expect(state.data.materials.length, before + 1);

      final created = state.data.materials.firstWhere((m) => m.title == 'Materi operator');
      state.openOperatorMaterialForm(created.id);
      expect(state.draftMaterialId, created.id);
      state.setDraftTitle('Materi operator diubah');
      state.saveOperatorMaterial();
      expect(
        state.data.materials.firstWhere((m) => m.id == created.id).title,
        'Materi operator diubah',
      );

      state.deleteMaterial(created.id);
      expect(state.data.materials.length, before);

      state.dispose();
    });

    test('operator menambah, mengubah, dan menghapus pengumuman', () async {
      final state = await loggedInOperator();

      final before = state.data.announcements.length;
      state.openOperatorAnnouncementForm();
      expect(state.screen, 'operatorAnnouncementForm');
      state.setDraftTitle('Pengumuman operator');
      state.setDraftBody('Isi pengumuman operator');
      state.setDraftClass('Semua kelas');
      state.saveOperatorAnnouncement();
      expect(state.data.announcements.length, before + 1);
      expect(state.screen, 'operatorAnnouncements');

      final created = state.data.announcements
          .firstWhere((a) => a.title == 'Pengumuman operator');
      state.openOperatorAnnouncementForm(created.id);
      expect(state.draftAnnouncementId, created.id);
      state.setDraftTitle('Pengumuman operator diubah');
      state.saveOperatorAnnouncement();
      expect(
        state.data.announcements.firstWhere((a) => a.id == created.id).title,
        'Pengumuman operator diubah',
      );

      state.deleteAnnouncement(created.id);
      expect(state.data.announcements.length, before);

      state.dispose();
    });

    test('operator menambah, mengubah, dan menghapus agenda', () async {
      final state = await loggedInOperator();

      final before = state.data.classEvents.length;
      state.openOperatorEventForm();
      expect(state.screen, 'operatorAgendaForm');
      state.setDraftTitle('Agenda operator');
      state.setDraftBody('Catatan agenda');
      state.setEventDate('2030-11-20');
      state.setDraftClass('Kelas 2');
      state.saveOperatorEvent();
      expect(state.data.classEvents.length, before + 1);
      expect(state.screen, 'operatorAgenda');

      final created = state.data.classEvents
          .firstWhere((e) => e.title == 'Agenda operator');
      state.openOperatorEventForm(created.id);
      expect(state.draftEventId, created.id);
      state.setDraftTitle('Agenda operator diubah');
      state.saveOperatorEvent();
      expect(
        state.data.classEvents.firstWhere((e) => e.id == created.id).title,
        'Agenda operator diubah',
      );

      state.deleteEvent(created.id);
      expect(state.data.classEvents.length, before);

      state.dispose();
    });

    test('operator mengisi, mengubah, dan menghapus nilai siswa', () async {
      final state = await loggedInOperator();
      final student = state.roster.first;

      expect(state.operatorScore(student.id), isNull);
      expect(state.operatorClassAverage(student.className), isNull);

      state.saveOperatorScore(student.id, 88);
      expect(state.operatorScore(student.id), 88);
      expect(state.operatorClassAverage(student.className), 88);

      state.saveOperatorScore(student.id, 92);
      expect(state.operatorScore(student.id), 92);

      state.saveOperatorScore(student.id, null);
      expect(state.operatorScore(student.id), isNull);
      expect(state.operatorClassAverage(student.className), isNull);

      state.dispose();
    });

    test('operator ditolak saat menyimpan nilai di luar 0-100', () async {
      final state = await loggedInOperator();
      final student = state.roster.first;

      expect(state.saveOperatorScore(student.id, 120), isFalse);
      expect(state.error, 'Nilai harus antara 0 sampai 100.');
      expect(state.operatorScore(student.id), isNull);

      expect(state.saveOperatorScore(student.id, -1), isFalse);
      expect(state.error, 'Nilai harus antara 0 sampai 100.');
      expect(state.operatorScore(student.id), isNull);

      expect(state.saveOperatorScore(student.id, double.nan), isFalse);
      expect(state.error, 'Nilai harus berupa angka.');
      expect(state.operatorScore(student.id), isNull);

      expect(state.saveOperatorScore(student.id, 100), isTrue);
      expect(state.operatorScore(student.id), 100);

      state.dispose();
    });

    test('operator menambah, mengubah, dan menghapus kelas sekolah', () async {
      final state = await loggedInOperator();

      expect(state.schoolClasses.length, 6);
      expect(state.operatorClassNames.length, 6);

      state.openOperatorClassForm();
      expect(state.screen, 'operatorClassForm');
      state.setDraftSchoolClassName('Kelas 7');
      state.setDraftSchoolClassTeacher('Pak Adi');
      state.saveOperatorClass();
      expect(state.schoolClasses.length, 7);
      expect(state.operatorClassNames.contains('Kelas 7'), isTrue);

      // Nama kelas ganda ditolak.
      state.openOperatorClassForm();
      state.setDraftSchoolClassName('Kelas 7');
      state.saveOperatorClass();
      expect(state.error, 'Kelas dengan nama itu sudah ada.');
      expect(state.schoolClasses.length, 7);

      final created = state.schoolClasses.firstWhere((c) => c.name == 'Kelas 7');
      state.openOperatorClassForm(created.id);
      expect(state.draftSchoolClassId, created.id);
      state.setDraftSchoolClassName('Kelas 7B');
      state.saveOperatorClass();
      expect(state.schoolClasses.firstWhere((c) => c.id == created.id).name, 'Kelas 7B');

      // Menghapus kelas memindahkan siswanya ke kelas yang tersisa.
      state.addStudent(
        const StudentProfile(
          id: 'uji-kelas-7',
          nisn: '10058888',
          name: 'Uji Kelas Tujuh',
          className: 'Kelas 7B',
        ),
      );
      expect(state.rosterForClass('Kelas 7B').length, 1);

      state.removeSchoolClass(created.id);
      expect(state.schoolClasses.length, 6);
      expect(state.rosterForClass('Kelas 7B').length, 0);
      expect(state.roster.firstWhere((s) => s.id == 'uji-kelas-7').className,
          state.operatorClassNames.first);

      state.dispose();
    });

    test('kelas terakhir tidak boleh dihapus', () async {
      final state = await loggedInOperator();

      for (final schoolClass in state.schoolClasses.skip(1).toList()) {
        expect(state.removeSchoolClass(schoolClass.id), isTrue);
      }
      expect(state.schoolClasses.length, 1);

      final last = state.schoolClasses.first;
      expect(state.removeSchoolClass(last.id), isFalse);
      expect(state.error, 'Minimal satu kelas sekolah harus tetap ada.');
      expect(state.schoolClasses.length, 1);

      state.dispose();
    });

    test('kelas dan akun yang dihapus tidak dibangkitkan lagi setelah reload',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = await loggedInOperator();

      state.removeSchoolClass(state.schoolClasses.first.id);
      state.removeStaffAccount(state.staffAccounts.first.id);
      expect(state.schoolClasses.length, 5);
      expect(state.staffAccounts.length, 6);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final reopened = AppState(autoLoad: false);
      await reopened.loadFromStorage();
      expect(reopened.schoolClasses.length, 5);
      expect(reopened.staffAccounts.length, 6);
      expect(reopened.schoolClasses.any((c) => c.id == 'c1'), isFalse);
      expect(reopened.staffAccounts.any((a) => a.id == 'u1'), isFalse);

      state.dispose();
      reopened.dispose();
    });

    test('siswa yang dihapus operator tidak muncul lagi setelah reload', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = await loggedInOperator();

      state.removeStudent('s1a');
      expect(state.roster.length, 23);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final reopened = AppState(autoLoad: false);
      await reopened.loadFromStorage();
      expect(reopened.roster.length, 23);
      expect(reopened.roster.any((s) => s.id == 's1a'), isFalse);

      state.dispose();
      reopened.dispose();
    });

    test('operator menambah, mengubah, dan menghapus akun guru dan wali', () async {
      final state = await loggedInOperator();

      final before = state.staffAccounts.length;
      state.openOperatorStaffForm();
      expect(state.screen, 'operatorStaffForm');
      state.setDraftStaffName('Bu Lilis');
      state.setDraftStaffNip('19870099');
      state.setDraftStaffRole('wali');
      state.setDraftStaffClass('Kelas 4');
      state.saveOperatorStaff();
      expect(state.staffAccounts.length, before + 1);

      final created = state.staffAccounts.firstWhere((a) => a.nip == '19870099');
      expect(created.role, 'wali');
      expect(created.className, 'Kelas 4');

      // NIP ganda ditolak.
      state.openOperatorStaffForm();
      state.setDraftStaffName('Bu Lilis 2');
      state.setDraftStaffNip('19870099');
      state.saveOperatorStaff();
      expect(state.error, 'NIP itu sudah dipakai akun lain.');
      expect(state.staffAccounts.length, before + 1);

      state.openOperatorStaffForm(created.id);
      expect(state.draftStaffId, created.id);
      state.setDraftStaffName('Bu Lilis diubah');
      state.saveOperatorStaff();
      expect(
        state.staffAccounts.firstWhere((a) => a.id == created.id).name,
        'Bu Lilis diubah',
      );

      state.removeStaffAccount(created.id);
      expect(state.staffAccounts.length, before);

      state.dispose();
    });

    test('operator bisa memindahkan siswa antar kelas', () async {
      final state = await loggedInOperator();
      final student = state.roster.first;

      state.moveStudentToClass(student.id, 'Kelas 6');
      expect(state.rosterForClass('Kelas 6').length, 5);
      expect(state.rosterForClass(student.className).length, 3);

      state.dispose();
    });

    test('perubahan operator tersimpan di store @karsa-demo-v1', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = await loggedInOperator();

      state.openOperatorClassForm();
      state.setDraftSchoolClassName('Kelas 7');
      state.setDraftSchoolClassTeacher('Pak Adi');
      state.saveOperatorClass();
      state.openOperatorStaffForm();
      state.setDraftStaffName('Bu Lilis');
      state.setDraftStaffNip('19870099');
      state.saveOperatorStaff();

      // Tunggu penulisan store selesai.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final reopened = AppState(autoLoad: false);
      await reopened.loadFromStorage();
      expect(reopened.data.schoolClasses.any((c) => c.name == 'Kelas 7'), isTrue);
      expect(reopened.data.staffAccounts.any((a) => a.nip == '19870099'), isTrue);

      state.dispose();
      reopened.dispose();
    });

    test('operator tidak dapat menambah tugas tanpa judul atau tenggat', () async {
      final state = await loggedInOperator();
      final before = state.data.tasks.length;

      state.openOperatorTaskForm();
      state.saveOperatorTask();
      expect(state.error, 'Isi judul dan batas waktu yang valid.');
      expect(state.data.tasks.length, before);

      state.setDraftTitle('Tanpa tenggat');
      state.setDraftMinutes('30');
      state.setDraftDue('bukan tanggal');
      state.saveOperatorTask();
      expect(state.error, 'Isi tanggal tenggat dengan format YYYY-MM-DD.');
      expect(state.data.tasks.length, before);

      state.dispose();
    });

    test('kelas dengan nama bebas memakai semua mata pelajaran', () {
      // Kelas "Kelas Alfa" tidak punya angka tingkat, jadi operator tidak
      // terkunci dari IPAS.
      expect(
        CurriculumData.subjectsForClass('Kelas Alfa')
            .contains('Ilmu Pengetahuan Alam dan Sosial (IPAS)'),
        isTrue,
      );
      expect(
        CurriculumData.subjectsForClass('Kelas 1')
            .contains('Ilmu Pengetahuan Alam dan Sosial (IPAS)'),
        isFalse,
      );
      expect(
        CurriculumData.subjectsForClass('Kelas 7')
            .contains('Ilmu Pengetahuan Alam dan Sosial (IPAS)'),
        isTrue,
      );
    });

    test('operator menyimpan profil kerja lengkap dengan validasi', () async {
      final state = await loggedInOperator();

      // Profil bawaan mengikuti akun demo.
      expect(state.operatorProfile.nip, '19870003');
      expect(state.operatorProfile.unit, 'SD Karitas Purwokerto');

      // Nama kosong ditolak dan tidak mengubah apa pun.
      state.openSetting('Informasi pribadi');
      expect(state.draftOperatorNip, '19870003');
      state.setDraftTitle('   ');
      expect(state.saveOperatorProfileForm(), isFalse);
      expect(state.error, 'Nama operator tidak boleh kosong.');
      expect(state.operatorProfile.nip, '19870003');

      // NIP wajib dan harus angka.
      state.setDraftTitle('Sari Operator');
      state.setDraftOperatorNip('');
      expect(state.saveOperatorProfileForm(), isFalse);
      expect(state.error, 'NIP tidak boleh kosong.');
      state.setDraftOperatorNip('abc');
      expect(state.saveOperatorProfileForm(), isFalse);
      expect(state.error, 'NIP harus berupa 6-20 angka.');

      // Surel harus valid bila diisi.
      state.setDraftOperatorNip('19870099');
      state.setDraftOperatorEmail('bukan-surel');
      expect(state.saveOperatorProfileForm(), isFalse);
      expect(state.error, 'Format surel belum benar, mis. nama@sekolah.sch.id');

      // Telepon harus 8-16 angka.
      state.setDraftOperatorEmail('sari@sekolah.sch.id');
      state.setDraftOperatorPhone('123');
      expect(state.saveOperatorProfileForm(), isFalse);
      expect(state.error, 'Nomor telepon harus 8-16 angka.');

      // Simpan yang sah menyimpan semua kolom dan menutup form.
      state.setDraftOperatorPhone('081234567890');
      state.setDraftOperatorRole('Operator Data');
      expect(state.saveOperatorProfileForm(), isTrue);
      expect(state.screen, 'main');
      expect(state.operatorProfile.name, 'Sari Operator');
      expect(state.operatorProfile.nip, '19870099');
      expect(state.operatorProfile.role, 'Operator Data');
      expect(state.operatorProfile.email, 'sari@sekolah.sch.id');
      expect(state.operatorProfile.phone, '081234567890');
      // Nama operator tidak menimpa nama siswa.
      expect(state.data.studentName, 'Dimas Nugroho');

      state.dispose();
    });

    test('section profil operator menampilkan kelengkapan kolom', () async {
      final state = await loggedInOperator();

      // Profil bawaan: nama, NIP, jabatan, dan unit terisi; kontak kosong.
      final profile = state.operatorProfile;
      expect(profile.filledFields, 4);
      expect(profile.totalFields, 6);
      expect(profile.hasContact, isFalse);
      expect(profile.initials, 'OS');

      // Section profil di beranda memakai getter yang sama dengan form,
      // jadi angka kelengkapan tidak bisa berbeda dari isi form.
      state.openSetting('Informasi pribadi');
      state.setDraftOperatorEmail('operator@sekolah.sch.id');
      state.setDraftOperatorPhone('081200000000');
      expect(state.saveOperatorProfileForm(), isTrue);

      final lengkap = state.operatorProfile;
      expect(lengkap.filledFields, 6);
      expect(lengkap.hasContact, isTrue);

      state.dispose();
    });

    test('profil operator tersimpan di store setelah dimuat ulang', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = await loggedInOperator();

      state.openSetting('Informasi pribadi');
      state.setDraftTitle('Sari Operator');
      state.setDraftOperatorNip('19870099');
      state.setDraftOperatorEmail('sari@sekolah.sch.id');
      state.saveOperatorProfileForm();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final reopened = AppState(autoLoad: false);
      await reopened.loadFromStorage();
      expect(reopened.operatorProfile.name, 'Sari Operator');
      expect(reopened.operatorProfile.nip, '19870099');
      expect(reopened.operatorProfile.email, 'sari@sekolah.sch.id');

      state.dispose();
      reopened.dispose();
    });

    test('StaffAccount menyimpan peran dan kelas', () {
      const wali = StaffAccount(
        id: 'u1',
        name: 'Ibu Sari',
        nip: '19870001',
        role: 'wali',
        className: 'Kelas 1',
      );
      expect(wali.isWali, isTrue);
      expect(wali.roleLabel, 'Wali kelas');

      const guru = StaffAccount(
        id: 'u2',
        name: 'Pak Rudi',
        nip: '19870021',
        role: 'guru',
        className: '',
      );
      expect(guru.isWali, isFalse);
      expect(guru.roleLabel, 'Guru mata pelajaran');
    });
  });
}
