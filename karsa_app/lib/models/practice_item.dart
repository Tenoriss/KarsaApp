class PracticeItem {
  final String id;
  final String subject;
  final String title;
  final String? className;

  const PracticeItem({
    required this.id,
    required this.subject,
    required this.title,
    this.className,
  });

  factory PracticeItem.fromJson(
    Map<String, dynamic> json, {
    String Function(String?)? normalizeSubject,
  }) {
    final rawSubj = json['subject']?.toString();
    return PracticeItem(
      id: (json['id'] ?? '').toString(),
      subject: normalizeSubject != null ? normalizeSubject(rawSubj) : (rawSubj ?? 'Matematika'),
      title: (json['title'] ?? '').toString(),
      className: json['className']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'subject': subject,
      'title': title,
    };
    if (className != null) map['className'] = className;
    return map;
  }
}
