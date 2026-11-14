class LocalNotification {
  final String id;
  final String target; // 'teachers' | 'learners'
  final String subject;
  final String className;
  final String title;
  final String kind; // 'task' | 'practice' | 'material' | 'agenda'
  final String contentId;
  final String createdAt;

  const LocalNotification({
    required this.id,
    required this.target,
    required this.subject,
    required this.className,
    required this.title,
    required this.kind,
    required this.contentId,
    required this.createdAt,
  });

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
      };
}
