/// Ringkasan nilai satu mata pelajaran pada kelas tertentu.
///
/// Dihitung dari hasil kuis yang benar-benar dikerjakan siswa pada perangkat
/// ini (lihat `AppState.classGradeSummaries`). Nilai kosong berarti belum
/// ada tugas yang dinilai, bukan nol.
class ClassGradeSummary {
  final String subject;
  final int gradedTasks; // tugas yang sudah selesai dan dinilai
  final int totalTasks; // seluruh tugas mata pelajaran ini di kelas tersebut
  final double average; // rata-rata 0-100 dari tugas yang dinilai

  const ClassGradeSummary({
    required this.subject,
    required this.gradedTasks,
    required this.totalTasks,
    required this.average,
  });

  double get completionRatio =>
      totalTasks > 0 ? (gradedTasks / totalTasks).clamp(0.0, 1.0) : 0.0;

  String get averageLabel {
    if (gradedTasks == 0) return '—';
    if (average == average.roundToDouble()) return average.round().toString();
    return average.toStringAsFixed(1);
  }

  String get statusLabel {
    if (gradedTasks == 0) return 'Belum ada nilai';
    if (average >= 85) return 'Sangat baik';
    if (average >= 70) return 'Baik';
    if (average >= 60) return 'Perlu latihan';
    return 'Perlu pendampingan';
  }
}
