import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:karsa_app/models/practice_item.dart';
import 'package:karsa_app/models/task_result.dart';
import 'package:karsa_app/providers/app_state.dart';
import 'package:karsa_app/data/curriculum_data.dart';
import 'package:karsa_app/models/user_role.dart';

/// Latihan punya dua metode, sama seperti tugas:
///   - pilihan ganda -> dinilai otomatis, skor disimpan
///   - esai          -> tidak dinilai otomatis, hanya status selesai
/// Siswa boleh mengerjakan salah satu atau keduanya.
void main() {
  group('Latihan dua metode (pilihan ganda + esai)', () {
    late AppState state;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      state = AppState(autoLoad: false);
      await state.loadFromStorage();
      state.selectRoleForLogin(UserRole.siswa);
      expect(state.authenticate('10050001', 'siswa123'), isTrue);
    });

    tearDown(() => state.dispose());

    PracticeItem firstPractice() => state.visiblePractices.first;

    /// Menyelesaikan seluruh soal esai: tiap soal butuh dua ketukan
    /// (lihat contoh, lalu lanjut). Mengembalikan jumlah ketukan.
    int finishEssay() {
      final bank = state.currentEssayBank;
      var taps = 0;
      for (var i = 0; i < bank.length; i++) {
        state.updateEssay('Jawaban esai nomor ${i + 1}.');
        state.checkOrAdvanceEssay(); // tampilkan contoh
        taps++;
        state.checkOrAdvanceEssay(); // lanjut / selesai
        taps++;
      }
      return taps;
    }

    /// Menjawab seluruh soal PG.
    void finishQuiz({required bool alwaysCorrect}) {
      final bank = state.currentQuizBank;
      for (var i = 0; i < bank.length; i++) {
        final answer = alwaysCorrect
            ? bank[i].answerIndex
            : (bank[i].answerIndex + 1) % bank[i].choices.length;
        state.selectQuizChoice(answer);
        state.checkOrAdvanceQuiz();
        state.checkOrAdvanceQuiz();
      }
    }

    test('latihan menyediakan dua metode: bank PG dan bank esai', () {
      final practice = firstPractice();
      state.openPractice(practice);

      final pg = CurriculumData.questionsFor(practice.subject, state.data.religion);
      final esai =
          CurriculumData.exercisesFor(practice.subject, state.data.religion);

      expect(pg, isNotEmpty, reason: 'latihan harus punya soal pilihan ganda');
      expect(esai, isNotEmpty, reason: 'latihan harus punya soal esai');
      expect(pg.length, greaterThanOrEqualTo(4),
          reason: 'pilihan ganda perlu minimal 4 soal agar layak dinilai');
    });

    test('pilihan ganda latihan memakai mapel latihan, bukan mapel tugas', () {
      final practice = firstPractice();
      state.openPractice(practice);
      state.startPracticeQuiz();

      expect(state.screen, 'quiz');
      expect(state.quizForPractice, isTrue);

      final expected =
          CurriculumData.questionsFor(practice.subject, state.data.religion);
      expect(state.currentQuizBank.length, expected.length);
      expect(state.currentQuizBank.first.question, expected.first.question);
    });

    test('skor pilihan ganda tersimpan setelah soal terakhir', () {
      final practice = firstPractice();
      state.openPractice(practice);
      state.startPracticeQuiz();
      final total = state.currentQuizBank.length;

      finishQuiz(alwaysCorrect: true);

      expect(state.screen, 'practiceResult');
      final result = state.selectedPracticeResult;
      expect(result, isNotNull, reason: 'skor latihan harus tersimpan');
      expect(result!.score, total, reason: 'semua benar harus bernilai penuh');
      expect(result.total, total);
      expect(state.data.practiceResults.containsKey(practice.id), isTrue);
    });

    test('jawaban salah tidak dihitung sebagai benar', () {
      final practice = firstPractice();
      state.openPractice(practice);
      state.startPracticeQuiz();
      final total = state.currentQuizBank.length;

      finishQuiz(alwaysCorrect: false);

      final result = state.selectedPracticeResult!;
      expect(result.total, total);
      expect(result.score, lessThan(total),
          reason: 'jawaban di luar kunci tidak boleh dianggap benar');
      expect(result.score, greaterThanOrEqualTo(0));
    });

    test('skor latihan tidak masuk ke nilai tugas', () {
      final resultsBefore = state.data.results.length;
      final practice = firstPractice();
      state.openPractice(practice);
      state.startPracticeQuiz();
      finishQuiz(alwaysCorrect: true);

      expect(state.data.results.length, resultsBefore,
          reason: 'skor latihan tidak boleh menambah hasil tugas');
      expect(state.data.practiceResults.containsKey(practice.id), isTrue);
    });

    test('esai latihan tersimpan sebagai selesai, tanpa skor', () {
      final practice = firstPractice();
      state.openPractice(practice);
      state.startPractice();

      expect(state.screen, 'essay');
      expect(state.essayForTask, isFalse, reason: 'esai latihan bukan esai tugas');

      state.updateEssay('Jawaban esai latihan yang cukup panjang.');
      state.checkOrAdvanceEssay();
      expect(state.showExample, isTrue, reason: 'contoh jawaban muncul dulu');

      // Sisakan soal terakhir lewat jalur normal (contoh lalu lanjut).
      state.checkOrAdvanceEssay();
      for (var i = 1; i < state.currentEssayBank.length; i++) {
        state.updateEssay('Jawaban nomor ${i + 1} cukup panjang.');
        state.checkOrAdvanceEssay();
        state.checkOrAdvanceEssay();
      }

      expect(state.screen, 'practiceResult');
      expect(state.data.practiceDone[practice.id], isTrue,
          reason: 'latihan esai menandai selesai');
      expect(state.selectedPracticeResult, isNull,
          reason: 'esai tidak dinilai otomatis, jadi tidak ada skor');
    });

    test('esai kosong tidak menandai latihan selesai', () {
      final practice = firstPractice();
      state.openPractice(practice);
      state.startPractice();

      state.updateEssay('   ');
      state.checkOrAdvanceEssay();

      expect(state.screen, 'essay', reason: 'tetap di layar esai');
      expect(state.data.practiceDone[practice.id], isNull);
    });

    test('mengerjakan PG tidak menghapus status selesai esai', () {
      final practice = firstPractice();

      state.openPractice(practice);
      state.startPractice();
      finishEssay();
      expect(state.data.practiceDone[practice.id], isTrue);

      state.openPractice(practice);
      state.startPracticeQuiz();
      finishQuiz(alwaysCorrect: true);

      expect(state.data.practiceDone[practice.id], isTrue,
          reason: 'status esai tidak boleh hilang');
      expect(state.selectedPracticeResult?.score, isNotNull);
    });

    test('membuka tugas setelah latihan tidak memakai soal latihan', () {
      final practice = firstPractice();
      state.openPractice(practice);
      state.startPracticeQuiz();
      expect(state.quizForPractice, isTrue);

      state.setScreen('practiceDetail');
      expect(state.quizForPractice, isFalse,
          reason: 'konteks latihan harus berakhir saat keluar kuis');

      final task = state.activeTasks.first;
      state.openTask(task);
      state.startQuiz();

      expect(state.quizForPractice, isFalse);
      final expected =
          CurriculumData.questionsFor(task.subject, state.data.religion);
      expect(state.currentQuizBank.first.question, expected.first.question,
          reason: 'kuis tugas tidak boleh meminjam soal latihan');
    });

    test('skor latihan bertahan setelah data dimuat ulang', () async {
      final practice = firstPractice();
      state.openPractice(practice);
      state.startPracticeQuiz();
      finishQuiz(alwaysCorrect: true);
      final savedScore = state.selectedPracticeResult!.score;

      final reloaded = AppState(autoLoad: false);
      await reloaded.loadFromStorage();
      reloaded.selectRoleForLogin(UserRole.siswa);
      reloaded.authenticate('10050001', 'siswa123');

      final restored = reloaded.data.practiceResults[practice.id];
      expect(restored, isNotNull, reason: 'skor latihan harus tersimpan di disk');
      expect(restored!.score, savedScore);
      expect(reloaded.data.practiceDone[practice.id], isTrue);
      reloaded.dispose();
    });

    test('contoh jawaban muncul lagi di setiap soal esai', () {
      // Bug: `_showExample` tidak pernah di-reset setelah pindah soal, jadi
      // "Lihat contoh jawaban" hanya muncul di soal pertama.
      final practice = firstPractice();
      state.openPractice(practice);
      state.startPractice();
      final bank = state.currentEssayBank;

      for (var i = 0; i < bank.length; i++) {
        expect(state.showExample, isFalse,
            reason: 'soal ${i + 1} harus mulai tanpa contoh');

        state.updateEssay('Jawaban soal ${i + 1}.');
        state.checkOrAdvanceEssay();
        expect(state.showExample, isTrue,
            reason: 'soal ${i + 1} harus bisa menampilkan contoh');
        state.checkOrAdvanceEssay();
      }

      expect(state.screen, 'practiceResult');
    });

    test('jawaban esai tiap soal tidak saling menimpa', () {
      // Bug: latihan hanya menyimpan satu `_essay`, jadi jawaban soal
      // sebelumnya hilang saat siswa pindah soal.
      final practice = firstPractice();
      state.openPractice(practice);
      state.startPractice();
      final bank = state.currentEssayBank;

      final written = <String>[];
      for (var i = 0; i < bank.length; i++) {
        final answer = 'Jawaban nomor ${i + 1} dengan isi berbeda.';
        written.add(answer);
        state.updateEssay(answer);
        // Jawaban yang sedang diketik harus persis yang terakhir ditulis.
        expect(state.essay, answer);
        state.checkOrAdvanceEssay();
        state.checkOrAdvanceEssay();
      }

      expect(written.length, bank.length);
      expect(state.screen, 'practiceResult');
      // Jumlah soal yang dikerjakan cocok dengan bank yang disediakan.
      expect(written.toSet().length, bank.length,
          reason: 'setiap soal punya jawaban sendiri, tidak tertimpa');
    });

    test('TaskResult latihan bolak-balik lewat JSON tanpa kehilangan data', () {
      const result = TaskResult(
        score: 7,
        total: 10,
        answers: <int>[0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        className: 'Kelas 5',
        studentName: 'Dimas Nugroho',
      );
      final restored = TaskResult.fromJson(result.toJson());
      expect(restored.score, 7);
      expect(restored.total, 10);
      expect(restored.answers, result.answers);
      expect(restored.className, 'Kelas 5');
    });
  });
}
