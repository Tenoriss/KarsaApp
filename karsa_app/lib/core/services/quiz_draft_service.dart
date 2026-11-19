import '../../models/quiz_question.dart';

/// Simulasi asisten AI **offline** untuk mengubah bahan ajar menjadi soal.
///
/// Ini **bukan** model AI: tidak ada jaringan, tidak ada API, dan tidak ada
/// PDF yang benar-benar dibaca. Yang dilakukan:
///
/// 1. Teks bahan (hasil tempel manual, atau isi file `.txt`) dipecah menjadi
///    kalimat.
/// 2. Kalimat yang mengandung kata kunci "belajar" dipilih jadi butir soal.
/// 3. Pilihan jawaban diambil dari **kata kunci** kalimat lain, supaya
///    pengecohnya tetap relevan dengan materi — bukan acak.
///
/// Karena itu hasilnya deterministik dan bisa diuji. Kalau tidak ada teks yang
/// bisa dipakai, pemanggil harus jatuh ke bank soal contoh
/// (`CurriculumData.questionsFor`), bukan mengarang soal.
class QuizDraftService {
  const QuizDraftService();

  /// Jumlah soal yang dihasilkan untuk satu tugas.
  static const int questionsPerTask = 10;

  /// Jumlah soal latihan esai.
  static const int exercisesPerTask = 5;

  /// Kata yang terlalu umum untuk dijadikan jawaban.
  static const Set<String> _stopWords = <String>{
    'yang',
    'dengan',
    'untuk',
    'dari',
    'dalam',
    'pada',
    'adalah',
    'akan',
    'dapat',
    'juga',
    'kita',
    'mereka',
    'siswa',
    'kelas',
    'materi',
    'belajar',
    'tugas',
    'soal',
    'ini',
    'itu',
    'dan',
    'atau',
    'agar',
    'karena',
    'saat',
    'setelah',
    'sebelum',
    'lebih',
    'sangat',
    'contoh',
    'mengenai',
    'tentang',
  };

  /// Memecah teks menjadi kalimat yang cukup panjang untuk dijadikan soal.
  static List<String> sentences(String text) {
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return const <String>[];
    final parts = cleaned.split(RegExp(r'(?<=[.!?])\s+'));
    return parts
        .map((s) => s.trim())
        .where((s) => s.length >= 24)
        .toList();
  }

  /// Kata kunci bermakna dari sebuah kalimat, diurutkan sesuai kemunculan.
  static List<String> keywords(String sentence, {int limit = 6}) {
    final words = sentence
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 4 && !_stopWords.contains(w))
        .toList();
    final unique = <String>[];
    for (final w in words) {
      if (!unique.contains(w)) unique.add(w);
      if (unique.length >= limit) break;
    }
    return unique;
  }

  /// Membuat soal pilihan ganda dari [text].
  ///
  /// Mengembalikan daftar kosong bila teks tidak memuat cukup kalimat — dalam
  /// kondisi itu pemanggil harus memakai bank soal contoh.
  List<QuizQuestion> draftQuestions(
    String text, {
    int count = questionsPerTask,
  }) {
    final lines = sentences(text);
    if (lines.length < 2) return const <QuizQuestion>[];

    // Kumpulan kata kunci seluruh bahan, dipakai sebagai pengecoh.
    final pool = <String>[];
    for (final line in lines) {
      for (final k in keywords(line)) {
        if (!pool.contains(k)) pool.add(k);
      }
    }
    if (pool.length < 4) return const <QuizQuestion>[];

    final questions = <QuizQuestion>[];
    for (var i = 0; i < lines.length && questions.length < count; i++) {
      final line = lines[i];
      final answer = keywords(line).isEmpty ? null : keywords(line).first;
      if (answer == null) continue;

      // Tiga pengecoh dari kata kunci kalimat lain, tidak boleh sama.
      final distractors = <String>[];
      for (var offset = 1; offset < lines.length + 1; offset++) {
        final other = lines[(i + offset) % lines.length];
        for (final k in keywords(other)) {
          if (k != answer && !distractors.contains(k)) distractors.add(k);
          if (distractors.length >= 3) break;
        }
        if (distractors.length >= 3) break;
      }
      if (distractors.length < 3) continue;

      // Putar posisi jawaban supaya tidak selalu pilihan pertama.
      final answerIndex = questions.length % 4;
      final choices = <String>[
        ...distractors.take(3),
      ];
      choices.insert(answerIndex.clamp(0, 3), answer);

      questions.add(
        QuizQuestion(
          question: 'Berdasarkan bahan bacaan, kata kunci pada kalimat '
              '"${_shorten(line)}" adalah ...',
          choices: choices,
          answerIndex: answerIndex.clamp(0, 3),
          explanation: 'Kata kunci kalimat itu adalah "$answer".',
        ),
      );
    }
    return questions;
  }

  /// Membuat soal esai singkat dari [text].
  List<EssayPrompt> draftExercises(String text, {int count = exercisesPerTask}) {
    final lines = sentences(text);
    if (lines.isEmpty) return const <EssayPrompt>[];
    final result = <EssayPrompt>[];
    for (var i = 0; i < lines.length && result.length < count; i++) {
      final line = lines[i];
      final key = keywords(line).isEmpty ? null : keywords(line).first;
      if (key == null) continue;
      result.add(
        EssayPrompt(
          prompt: 'Jelaskan dengan kata-katamu sendiri: ${_shorten(line)}',
          sampleAnswer:
              'Jawaban dapat beragam. Poin pentingnya berkaitan dengan "$key".',
        ),
      );
    }
    return result;
  }

  /// Kalimat panjang dipotong supaya pertanyaan tetap terbaca di kartu.
  static String _shorten(String line, {int max = 110}) {
    if (line.length <= max) return line;
    return '${line.substring(0, max).trimRight()}…';
  }
}
