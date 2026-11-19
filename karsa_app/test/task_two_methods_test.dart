import 'package:flutter_test/flutter_test.dart';
import 'package:karsa_app/core/services/quiz_draft_service.dart';
import 'package:karsa_app/models/task_result.dart';
import 'package:karsa_app/models/user_role.dart';
import 'package:karsa_app/providers/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Setiap tugas dan latihan punya dua metode: pilihan ganda (dinilai
/// otomatis) dan esai (jawaban disimpan, tidak dinilai otomatis). Tes ini
/// memastikan keduanya tersedia untuk siswa dan guru mapel, dan bahwa satu
/// metode tidak menghapus hasil metode lainnya.
void main() {
  Future<AppState> loggedIn(UserRole role, String nip, String pass) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final state = AppState(autoLoad: false);
    await state.loadFromStorage();
    state.selectRoleForLogin(role);
    expect(state.authenticate(nip, pass), isTrue);
    return state;
  }

  group('Dua metode pengerjaan tugas', () {
    test('tugas menyediakan bank pilihan ganda dan bank esai', () async {
      final state = await loggedIn(UserRole.siswa, '10050001', 'siswa123');
      final task = state.data.tasks.firstWhere((t) => !t.isFileTask);
      state.openTask(task);

      expect(state.currentQuizBank, isNotEmpty,
          reason: 'metode 1: pilihan ganda tersedia');
      expect(state.currentEssayBank, isNotEmpty,
          reason: 'metode 2: esai tersedia');
      state.dispose();
    });

    test('esai tugas memakai mapel tugas, bukan mapel terakhir', () async {
      final state = await loggedIn(UserRole.siswa, '10050001', 'siswa123');
      final task = state.data.tasks.firstWhere(
        (t) => !t.isFileTask && t.subject == 'Matematika',
      );
      state.openTask(task);
      state.startTaskEssay();

      expect(state.essayForTask, isTrue);
      // Soal esai berasal dari mapel tugas tersebut.
      expect(state.currentEssayBank.first.prompt, isNotEmpty);
      state.dispose();
    });

    test('jawaban esai tersimpan per tugas setelah dikirim', () async {
      final state = await loggedIn(UserRole.siswa, '10050001', 'siswa123');
      final task = state.data.tasks.firstWhere((t) => !t.isFileTask);
      state.openTask(task);
      state.startTaskEssay();

      state.updateEssay('Ini jawaban esai pertama.');
      state.submitTaskEssay();

      final saved = state.data.results[task.id];
      expect(saved, isNotNull);
      expect(saved!.essayAnswers, isNotEmpty);
      expect(saved.essayAnswers.first, contains('jawaban esai pertama'));
      expect(saved.hasEssay, isTrue);
      expect(state.screen, 'result');
      state.dispose();
    });

    test('esai kosong ditolak, bukan tersimpan sebagai jawaban', () async {
      final state = await loggedIn(UserRole.siswa, '10050001', 'siswa123');
      final task = state.data.tasks.firstWhere((t) => !t.isFileTask);
      state.openTask(task);
      state.startTaskEssay();

      state.submitTaskEssay();
      expect(state.error, contains('minimal satu jawaban esai'));
      expect(state.data.results[task.id]?.hasEssay ?? false, isFalse);
      state.dispose();
    });

    test('mengerjakan esai tidak menghapus skor pilihan ganda', () async {
      final state = await loggedIn(UserRole.siswa, '10050001', 'siswa123');
      final task = state.data.tasks.firstWhere((t) => !t.isFileTask);
      state.openTask(task);

      // Simulasikan hasil pilihan ganda yang sudah ada.
      final before = state.data.results[task.id];
      expect(before, isNull,
          reason: 'prasyarat: tugas ini belum punya hasil');

      state.startQuiz();
      // Jawab semua soal dengan benar supaya ada skor nyata.
      final bank = state.currentQuizBank;
      for (var i = 0; i < bank.length; i++) {
        state.selectQuizChoice(bank[i].answerIndex);
        state.checkOrAdvanceQuiz(); // tandai sudah diperiksa
        state.checkOrAdvanceQuiz(); // catat jawaban & maju
      }
      final scored = state.data.results[task.id];
      expect(scored, isNotNull);
      expect(scored!.score, bank.length);

      // Kerjakan bagian esai untuk tugas yang sama.
      state.openTask(task);
      state.startTaskEssay();
      state.updateEssay('Jawaban esai setelah kuis.');
      state.submitTaskEssay();

      final both = state.data.results[task.id]!;
      expect(both.score, bank.length,
          reason: 'skor pilihan ganda harus tetap ada');
      expect(both.essayAnswers.any((a) => a.trim().isNotEmpty), isTrue,
          reason: 'jawaban esai harus tersimpan');
      state.dispose();
    });

    test('guru mapel melihat kedua metode pada tugasnya', () async {
      final state = await loggedIn(UserRole.guru, '19870002', 'guru123');
      final task = state.data.tasks.firstWhere(
        (t) => !t.isFileTask && t.subject == state.data.teacherSubject,
      );
      state.openTask(task);

      expect(state.screen, 'teacherTask');
      expect(state.currentQuizBank, isNotEmpty);
      expect(state.currentEssayBank, isNotEmpty);
      state.dispose();
    });

    test('TaskResult menyimpan jawaban esai lewat JSON', () {
      const result = TaskResult(
        score: 7,
        total: 10,
        answers: <int>[1, 2, 3],
        essayAnswers: <String>['Jawaban satu', 'Jawaban dua'],
        essayAt: '2026-01-01T00:00:00Z',
      );
      final round = TaskResult.fromJson(result.toJson());
      expect(round.score, 7);
      expect(round.essayAnswers.length, 2);
      expect(round.essayAt, '2026-01-01T00:00:00Z');
      expect(round.hasEssay, isTrue);
    });

    test('jawaban esai soal hasil asisten tetap bisa disimpan', () async {
      // Tugas dengan soal dari asisten tetap punya bagian esai dari mapelnya.
      final state = await loggedIn(UserRole.wali, '19870001', 'wali123');
      state.openForm('taskForm');
      state.setDraftTitle('Fotosintesis');
      state.setAssistantSource(
        'Fotosintesis adalah proses tumbuhan membuat makanan sendiri. '
        'Tumbuhan menyerap air dan mineral melalui akar di dalam tanah. '
        'Daun menangkap cahaya matahari menggunakan klorofil hijau. '
        'Hasil fotosintesis berupa glukosa dan oksigen yang dilepas ke udara. '
        'Proses ini penting karena menjadi sumber makanan bagi makhluk hidup lain.',
      );
      state.generateQuestionsFromMaterial();
      state.setDraftMinutes('30');
      state.setDraftDue('2099-12-31');
      state.saveTask();

      final task = state.data.tasks.last;
      expect(task.questions.length, QuizDraftService.questionsPerTask);
      state.openTask(task);
      expect(state.currentQuizBank.length, task.questions.length);
      expect(state.currentEssayBank, isNotEmpty);
      state.dispose();
    });
  });
}
