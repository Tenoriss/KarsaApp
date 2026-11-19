import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:karsa_app/models/local_notification.dart';
import 'package:karsa_app/models/user_role.dart';
import 'package:karsa_app/providers/app_state.dart';

/// Notifikasi pengumpulan untuk guru.
///
/// Keluhan aslinya: kartu notifikasi hanya berbunyi "Tugas dikumpulkan siswa"
/// tanpa nama, dan mengetuknya membuka tugas untuk DIKERJAKAN guru sendiri.
/// Yang diharapkan: nama siswa + nilainya, dan daftar siapa saja yang sudah
/// mengerjakan.
void main() {
  group('Notifikasi pengumpulan untuk guru', () {
    late AppState state;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      state = AppState(autoLoad: false);
      await state.loadFromStorage();
    });

    tearDown(() => state.dispose());

    Future<void> loginGuru() async {
      state.selectRoleForLogin(UserRole.guru);
      expect(state.authenticate('19870002', 'guru123'), isTrue);
      state.setTeacherSubject('Matematika');
    }

    Future<void> loginSiswa() async {
      state.selectRoleForLogin(UserRole.siswa);
      expect(state.authenticate('10050001', 'siswa123'), isTrue);
    }

    test('notifikasi pengumpulan membawa nama siswa dan nilai', () async {
      await loginGuru();
      final submissions = state.relevantNotifications
          .where((n) => n.isSubmission && n.studentName != null)
          .toList();

      expect(submissions, isNotEmpty,
          reason: 'guru harus punya notifikasi pengumpulan yang menyebut nama');
      final n = submissions.first;
      expect(n.studentName, isNotEmpty);
      expect(n.score, isNotNull, reason: 'nilai ikut ditampilkan');
      expect(n.total, isNotNull);
      // Judul tidak boleh generik tanpa nama.
      expect(n.title, isNot('Tugas dikumpulkan siswa'),
          reason: 'judul generik tanpa nama adalah bug aslinya');
      expect(n.title.toLowerCase(), contains(n.studentName!.toLowerCase()),
          reason: 'judul menyebut nama siswa');
    });

    test('label nilai terbaca: "9/10" atau "Belum dinilai"', () {
      const scored = LocalNotification(
        id: 'x',
        target: 'teachers',
        subject: 'Matematika',
        className: 'Kelas 1',
        title: 'A mengumpulkan',
        kind: 'submission',
        contentId: 't1',
        createdAt: '2026-11-19T00:00:00Z',
        studentName: 'A',
        score: 9,
        total: 10,
      );
      expect(scored.scoreLabel, '9/10');

      const unscored = LocalNotification(
        id: 'y',
        target: 'teachers',
        subject: 'Matematika',
        className: 'Kelas 1',
        title: 'A mengirim esai',
        kind: 'submission',
        contentId: 't1',
        createdAt: '2026-11-19T00:00:00Z',
        studentName: 'A',
      );
      expect(unscored.scoreLabel, 'Belum dinilai',
          reason: 'esai tidak dinilai otomatis');
    });

    test('mengetuk notifikasi membuka REKAP, bukan tugas untuk dikerjakan',
        () async {
      await loginGuru();
      final n = state.relevantNotifications
          .firstWhere((x) => x.isSubmission);

      state.markNotification(n);

      expect(state.screen, 'submissions',
          reason: 'guru melihat daftar pengumpulan, bukan halaman tugas');
      expect(state.screen, isNot('teacherTask'));
      expect(state.screen, isNot('taskDetail'));
      expect(state.selectedTask, isNotNull);
      expect(state.isNotificationRead(n.id), isTrue,
          reason: 'notifikasi tetap ditandai terbaca');
    });

    test('rekap memuat roster kelas dan menandai yang belum mengumpulkan',
        () async {
      await loginGuru();
      final task = state.data.tasks.firstWhere((t) => t.id == 't1');
      final rows = state.submissionsFor(task);

      expect(rows, isNotEmpty, reason: 'rekap tidak boleh kosong');
      // Roster Kelas 1 punya beberapa siswa.
      final rosterKelas1 = state.rosterForClass(task.className);
      expect(rows.length, greaterThanOrEqualTo(rosterKelas1.length));

      final belum = rows.where((r) => !r.submitted).toList();
      expect(belum, isNotEmpty,
          reason: 'tidak semua siswa mengumpulkan, sisanya harus tampil "Belum"');
      expect(belum.first.scoreLabel, 'Belum');
      expect(belum.first.status, 'Belum');
    });

    test('rata-rata hanya menghitung yang sudah punya nilai', () async {
      await loginGuru();
      final task = state.data.tasks.firstWhere((t) => t.id == 't1');
      final graded = state.submissionsFor(task).where((r) => r.submitted).toList();
      final avg = state.averageSubmissionScore(task);

      if (graded.isEmpty) {
        expect(avg, isNull, reason: 'tanpa nilai, rata-rata kosong');
      } else {
        expect(avg, isNotNull);
        expect(avg!, greaterThanOrEqualTo(0));
        expect(avg, lessThanOrEqualTo(10));
      }
    });

    test('siswa menyelesaikan kuis membuat notifikasi bernama untuk guru',
        () async {
      await loginSiswa();
      final task = state.activeTasks.first;
      state.openTask(task);
      state.startQuiz();

      final bank = state.currentQuizBank;
      for (var i = 0; i < bank.length; i++) {
        state.selectQuizChoice(bank[i].answerIndex);
        state.checkOrAdvanceQuiz();
        state.checkOrAdvanceQuiz();
      }
      expect(state.screen, 'result');

      final created = state.data.localNotifications.first;
      expect(created.target, 'teachers');
      expect(created.isSubmission, isTrue,
          reason: 'pengumpulan memakai kind submission');
      expect(created.studentName, state.data.studentName,
          reason: 'nama siswa ikut pada notifikasi');
      expect(created.score, bank.length, reason: 'semua benar');
      expect(created.total, bank.length);
      expect(created.title, contains(state.data.studentName));
    });

    test('esai tugas mengirim notifikasi tanpa nilai (tidak dinilai otomatis)',
        () async {
      await loginSiswa();
      final task = state.activeTasks.first;
      state.openTask(task);
      state.startTaskEssay();

      final bank = state.currentEssayBank;
      state.updateEssay('Jawaban esai pertama yang cukup panjang.');
      state.checkOrAdvanceEssay();
      for (var i = 1; i < bank.length; i++) {
        state.updateEssay('Jawaban ${i + 1}.');
        state.checkOrAdvanceEssay();
        state.checkOrAdvanceEssay();
      }

      final created = state.data.localNotifications.first;
      expect(created.isSubmission, isTrue);
      expect(created.studentName, isNotNull);
      expect(created.score, isNull,
          reason: 'esai tidak dinilai otomatis, jadi tanpa skor');
      expect(created.scoreLabel, 'Belum dinilai');
    });

    test('notifikasi pengumpulan bertahan setelah dimuat ulang', () async {
      await loginSiswa();
      final task = state.activeTasks.first;
      state.openTask(task);
      state.startQuiz();
      final bank = state.currentQuizBank;
      for (var i = 0; i < bank.length; i++) {
        state.selectQuizChoice(bank[i].answerIndex);
        state.checkOrAdvanceQuiz();
        state.checkOrAdvanceQuiz();
      }
      final savedTitle = state.data.localNotifications.first.title;
      state.dispose();

      final reloaded = AppState(autoLoad: false);
      await reloaded.loadFromStorage();
      final found = reloaded.data.localNotifications
          .where((n) => n.title == savedTitle)
          .toList();
      expect(found, isNotEmpty, reason: 'notifikasi tersimpan di disk');
      expect(found.first.studentName, isNotNull,
          reason: 'nama siswa ikut tersimpan');
      reloaded.dispose();
    });
  });
}
