class TaskResult {
  final int? score;
  final int? total;
  final List<int> answers;
  final bool demo;
  final bool submittedOnly;
  final String? religion;
  final String? studentName;
  final String? className;

  const TaskResult({
    this.score,
    this.total,
    this.answers = const <int>[],
    this.demo = false,
    this.submittedOnly = false,
    this.religion,
    this.studentName,
    this.className,
  });

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
    return map;
  }
}
