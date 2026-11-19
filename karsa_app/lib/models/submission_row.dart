/// Satu baris pada rekap pengumpulan tugas milik guru.
///
/// `score` null berarti siswa belum mengumpulkan (atau esainya belum dinilai,
/// karena esai tidak dinilai otomatis).
class SubmissionRow {
  final String id;
  final String name;
  final String className;
  final int? score;
  final int? total;
  final List<String> essayAnswers;

  const SubmissionRow({
    required this.id,
    required this.name,
    required this.className,
    this.score,
    this.total,
    this.essayAnswers = const <String>[],
  });

  bool get submitted => score != null;

  /// Teks nilai ringkas, mis. "9/10".
  String get scoreLabel => submitted ? '$score/${total ?? 10}' : 'Belum';

  /// Sudah mengirim jawaban esai (tidak dinilai otomatis).
  bool get hasEssay => essayAnswers.any((a) => a.trim().isNotEmpty);

  /// Kategori sederhana untuk badge di daftar.
  String get status => !submitted
      ? 'Belum'
      : (score! >= 8 ? 'Baik' : 'Perlu latihan');
}
