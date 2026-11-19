class LocalNotification {
  final String id;
  final String target; // 'teachers' | 'learners'
  final String subject;
  final String className;
  final String title;
  final String kind; // 'task' | 'practice' | 'material' | 'agenda' | 'submission'
  final String contentId;
  final String createdAt;

  /// Nama siswa yang mengumpulkan. Hanya diisi untuk `kind == 'submission'`,
  /// supaya guru langsung tahu SIAPA yang mengumpulkan.
  final String? studentName;

  /// Nilai pilihan ganda siswa pada pengumpulan itu (null bila belum dinilai).
  final int? score;
  final int? total;

  const LocalNotification({
    required this.id,
    required this.target,
    required this.subject,
    required this.className,
    required this.title,
    required this.kind,
    required this.contentId,
    required this.createdAt,
    this.studentName,
    this.score,
    this.total,
  });

  /// Notifikasi ini berasal dari pengumpulan tugas siswa.
  bool get isSubmission => kind == 'submission';

  /// Teks nilai ringkas, mis. "9/10" atau "Belum dinilai".
  String get scoreLabel =>
      (score == null) ? 'Belum dinilai' : '$score/${total ?? 10}';

  factory LocalNotification.fromJson(
    Map<String, dynamic> json, {
    String Function(String?)? normalizeSubject,
  }) {
    final rawSubj = json['subject']?.toString() ?? 'Matematika';
    final normalized =
        (rawSubj == 'Agenda' || normalizeSubject == null) ? rawSubj : normalizeSubject(rawSubj);
    return LocalNotification(
      id: (json['id'] ?? '').toString(),
      target: (json['target'] ?? 'learners').toString(),
      subject: normalized,
      className: (json['className'] ?? 'Kelas 1').toString(),
      title: (json['title'] ?? '').toString(),
      kind: (json['kind'] ?? 'task').toString(),
      contentId: (json['contentId'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      studentName: json['studentName']?.toString(),
      score: json['score'] is num ? (json['score'] as num).toInt() : null,
      total: json['total'] is num ? (json['total'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'target': target,
        'subject': subject,
        'className': className,
        'title': title,
        'kind': kind,
        'contentId': contentId,
        'createdAt': createdAt,
        if (studentName != null) 'studentName': studentName,
        if (score != null) 'score': score,
        if (total != null) 'total': total,
      };
}
