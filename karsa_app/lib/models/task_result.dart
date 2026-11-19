class TaskResult {
  final int? score;
  final int? total;
  final List<int> answers;
  final bool demo;
  final bool submittedOnly;
  final String? religion;
  final String? studentName;
  final String? className;

  /// Jawaban esai siswa untuk tugas ini, satu entri per soal esai.
  /// Kosong berarti bagian esai belum dikerjakan.
  final List<String> essayAnswers;

  /// Waktu esai terakhir dikirim (ISO-8601), dipakai layar hasil.
  final String? essayAt;

  const TaskResult({
    this.score,
    this.total,
    this.answers = const <int>[],
    this.demo = false,
    this.submittedOnly = false,
    this.religion,
    this.studentName,
    this.className,
    this.essayAnswers = const <String>[],
    this.essayAt,
  });

  /// Bagian esai sudah diisi siswa.
  bool get hasEssay => essayAnswers.any((a) => a.trim().isNotEmpty);

  factory TaskResult.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    final parsedAnswers = rawAnswers is List
        ? rawAnswers.map((e) => (e is num) ? e.toInt() : 0).toList()
        : <int>[];
    return TaskResult(
      score: json['score'] is num ? (json['score'] as num).toInt() : null,
      total: json['total'] is num ? (json['total'] as num).toInt() : null,
      answers: parsedAnswers,
      demo: json['demo'] == true,
      submittedOnly: json['submittedOnly'] == true,
      religion: json['religion']?.toString(),
      studentName: json['studentName']?.toString(),
      className: json['className']?.toString(),
      essayAnswers: json['essayAnswers'] is List
          ? (json['essayAnswers'] as List).map((e) => e.toString()).toList()
          : const <String>[],
      essayAt: json['essayAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (score != null) map['score'] = score;
    if (total != null) map['total'] = total;
    if (answers.isNotEmpty) map['answers'] = answers;
    if (demo) map['demo'] = true;
    if (submittedOnly) map['submittedOnly'] = true;
    if (religion != null) map['religion'] = religion;
    if (studentName != null) map['studentName'] = studentName;
    if (className != null) map['className'] = className;
    if (essayAnswers.isNotEmpty) map['essayAnswers'] = essayAnswers;
    if (essayAt != null) map['essayAt'] = essayAt;
    return map;
  }
}
