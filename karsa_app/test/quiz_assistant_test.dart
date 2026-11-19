import 'package:flutter_test/flutter_test.dart';
import 'package:karsa_app/core/services/quiz_draft_service.dart';
import 'package:karsa_app/models/quiz_question.dart';
import 'package:karsa_app/models/task_item.dart';
import 'package:karsa_app/models/user_role.dart';
import 'package:karsa_app/providers/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bahan ajar contoh: sebelas kalimat supaya asisten punya cukup butir soal.
const String _bahan = '''
Fotosintesis adalah proses tumbuhan membuat makanan sendiri.
Tumbuhan menyerap air dan mineral melalui akar di dalam tanah.
Daun menangkap cahaya matahari menggunakan klorofil hijau.
Hasil fotosintesis berupa glukosa dan oksigen yang dilepas ke udara.
Proses ini penting karena menjadi sumber makanan bagi makhluk hidup lain.
Klorofil memberi warna hijau pada daun tumbuhan.
Stomata membuka dan menutup untuk mengatur pertukaran gas.
Air diangkut dari akar menuju daun melalui xilem.
Glukosa diangkut dari daun menuju seluruh tubuh tumbuhan melalui floem.
Respirasi tumbuhan memakai oksigen untuk menghasilkan energi.
Karbondioksida masuk melalui stomata saat proses fotosintesis berlangsung.
''';

void main() {
  group('Simulasi asisten penyusun soal', () {
    test('memecah bahan menjadi kalimat dan kata kunci', () {
      final lines = QuizDraftService.sentences(_bahan);
      expect(lines.length, greaterThanOrEqualTo(4));

      final keys = QuizDraftService.keywords(lines.first);
      expect(keys, isNotEmpty);
      // Kata umum seperti "adalah"/"yang" tidak dijadikan jawaban.
      expect(keys, isNot(contains('adalah')));
      expect(keys, isNot(contains('yang')));
    });

    test('membuat soal pilihan ganda dengan jawaban sah', () {
      final questions = const QuizDraftService().draftQuestions(_bahan);
      // Satu soal per kalimat lengkap, dibatasi sepuluh.
      expect(questions.length, QuizDraftService.questionsPerTask);
      expect(QuizDraftService.sentences(_bahan).length,
          greaterThanOrEqualTo(QuizDraftService.questionsPerTask));

      for (final q in questions) {
        expect(q.choices.length, 4, reason: 'setiap soal punya 4 pilihan');
        expect(q.answerIndex, inInclusiveRange(0, 3));
        expect(q.choices[q.answerIndex], isNotEmpty);
        expect(q.question, contains('kata kunci'));
        // Pilihan tidak boleh berulang.
        expect(q.choices.toSet().length, 4);
      }
    });

    test('jawaban tidak selalu di posisi yang sama', () {
      final questions = const QuizDraftService().draftQuestions(_bahan);
      final positions = questions.map((q) => q.answerIndex).toSet();
      expect(positions.length, greaterThan(1),
          reason: 'posisi jawaban harus bervariasi');
    });

    test('bahan terlalu pendek tidak mengarang soal', () {
      expect(const QuizDraftService().draftQuestions('Pendek.'), isEmpty);
      expect(const QuizDraftService().draftQuestions(''), isEmpty);
      // Kalimat panjang tapi tanpa kata kunci yang layak juga ditolak.
      expect(
        const QuizDraftService().draftQuestions('Ini itu dan atau yang.'),
        isEmpty,
      );
    });

    test('bahan pendek menghasilkan lebih sedikit soal, bukan soal isian', () {
      const short = '''
Fotosintesis adalah proses tumbuhan membuat makanan sendiri.
Daun menangkap cahaya matahari menggunakan klorofil hijau.
Hasil fotosintesis berupa glukosa dan oksigen yang dilepas ke udara.
''';
      final questions = const QuizDraftService().draftQuestions(short);
      expect(questions.length, 3);
      expect(questions.length, lessThan(QuizDraftService.questionsPerTask));
    });

    test('membuat latihan esai dari bahan', () {
      final exercises = const QuizDraftService().draftExercises(_bahan);
      expect(exercises.length, QuizDraftService.exercisesPerTask);
      expect(exercises.first.prompt, contains('Jelaskan'));
      expect(exercises.first.sampleAnswer, isNotEmpty);
    });
  });

  group('AppState asisten & soal per tugas', () {
    Future<AppState> loggedInWali() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final state = AppState(autoLoad: false);
      await state.loadFromStorage();
      state.selectRoleForLogin(UserRole.wali);
      expect(state.authenticate('19870001', 'wali123'), isTrue);
      return state;
    }

    test('wali bisa membuka form tugas (bug: sebelumnya tidak ada jalan)', () async {
      final state = await loggedInWali();
      state.openForm('taskForm');
      expect(state.screen, 'taskForm');
      expect(state.draftSubject, isNotEmpty);
      expect(state.draftClass, 'Kelas 1');
      state.dispose();
    });

    test('asisten menolak bahan kosong dengan pesan yang jelas', () async {
      final state = await loggedInWali();
      state.openForm('taskForm');
      state.generateQuestionsFromMaterial();
      expect(state.assistantReady, isFalse);
      expect(state.error, contains('Tempel teks bahan ajar dulu'));
      // PDF disebut terang-terangan, tidak disembunyikan.
      expect(state.error, contains('PDF belum bisa dibaca'));
      state.dispose();
    });

    test('asisten membuat soal dari teks tempelan', () async {
      final state = await loggedInWali();
      state.openForm('taskForm');
      state.setAssistantSource(_bahan);
      state.generateQuestionsFromMaterial();

      expect(state.assistantReady, isTrue);
      expect(state.assistantQuestions.length, QuizDraftService.questionsPerTask);
      expect(state.error, isEmpty);
      expect(state.notice, contains('bukan AI'));
      state.dispose();
    });

    test('bahan terlalu pendek jatuh dengan pesan, bukan soal palsu', () async {
      final state = await loggedInWali();
      state.openForm('taskForm');
      state.setAssistantSource('Terlalu pendek.');
      state.generateQuestionsFromMaterial();
      expect(state.assistantReady, isFalse);
      expect(state.error, contains('terlalu pendek'));
      // Judul tidak ikut diisi saat soal gagal dibuat.
      expect(state.draftTitle.trim(), isEmpty);
      state.dispose();
    });

    test('tugas menyimpan soal asisten dan memakainya saat kuis', () async {
      final state = await loggedInWali();
      state.openForm('taskForm');
      state.setDraftTitle('Fotosintesis');
      state.setAssistantSource(_bahan);
      state.generateQuestionsFromMaterial();
      state.setDraftMinutes('30');
      state.setDraftDue('2099-12-31');

      final before = state.data.tasks.length;
      state.saveTask();
      expect(state.error, isEmpty);
      expect(state.data.tasks.length, before + 1);

      final task = state.data.tasks.last;
      expect(task.title, 'Fotosintesis');
      expect(task.hasOwnQuestions, isTrue);
      expect(task.questionsFromAssistant, isTrue);
      expect(task.questions.length, QuizDraftService.questionsPerTask);

      // Wali tidak punya tab 'Tugas'; form tidak boleh mendarat di tab kosong.
      expect(state.tab, isIn(<String>['Beranda', 'Tugas']));
      expect(state.screen, 'main');

      // Kuis memakai soal milik tugas, bukan bank soal contoh mapel.
      state.openTask(task);
      expect(state.currentQuizBank.length, task.questions.length);
      expect(state.currentQuizBank.first.question, task.questions.first.question);
      state.dispose();
    });

    test('soal asisten ikut tersimpan setelah dimuat ulang', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final first = AppState(autoLoad: false);
      await first.loadFromStorage();
      first.selectRoleForLogin(UserRole.wali);
      first.authenticate('19870001', 'wali123');
      first.openForm('taskForm');
      first.setDraftTitle('Fotosintesis');
      first.setAssistantSource(_bahan);
      first.generateQuestionsFromMaterial();
      first.setDraftMinutes('30');
      first.setDraftDue('2099-12-31');
      first.saveTask();

      // Tunggu penulisan async selesai.
      final prefs = await SharedPreferences.getInstance();
      for (var i = 0; i < 50 && !prefs.containsKey('@karsa-demo-v1'); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      first.dispose();

      final reopened = AppState(autoLoad: false);
      await reopened.loadFromStorage();
      final saved = reopened.data.tasks.where((t) => t.title == 'Fotosintesis');
      expect(saved, isNotEmpty);
      expect(saved.last.questions.length, QuizDraftService.questionsPerTask);
      expect(saved.last.questionsSource, 'assistant');
      reopened.dispose();
    });

    test('kuis contoh membuang soal asisten supaya tidak tercampur', () async {
      final state = await loggedInWali();
      state.openForm('taskForm');
      state.setAssistantSource(_bahan);
      state.generateQuestionsFromMaterial();
      expect(state.assistantReady, isTrue);

      state.useExampleQuizForTask();
      expect(state.assistantReady, isFalse);
      expect(state.assistantQuestions, isEmpty);
      state.dispose();
    });

    test('tugas lama tanpa soal tetap memakai bank soal contoh', () async {
      final state = await loggedInWali();
      final legacy = state.data.tasks.firstWhere((t) => t.questions.isEmpty);
      state.openTask(legacy);
      expect(state.currentQuizBank, isNotEmpty);
      state.dispose();
    });

    test('TaskItem menyimpan soal lewat JSON dengan aman', () {
      final task = TaskItem(
        id: 't1',
        subject: 'Matematika',
        title: 'Tes',
        className: 'Kelas 1',
        minutes: '30',
        questions: const <QuizQuestion>[
          QuizQuestion(
            question: 'Satu tambah satu?',
            choices: <String>['2', '3', '4', '5'],
            answerIndex: 0,
            explanation: 'Karena 1+1=2.',
          ),
        ],
        questionsSource: 'assistant',
      );
      final round = TaskItem.fromJson(task.toJson());
      expect(round.questions.length, 1);
      expect(round.questions.first.choices.length, 4);
      expect(round.questionsSource, 'assistant');
    });
  });
}
