class ClassEvent {
  final String id;
  final String title;
  final String body;
  final String date;
  final String className;
  final String teacher;

  const ClassEvent({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.className,
    required this.teacher,
  });

  factory ClassEvent.fromJson(Map<String, dynamic> json) {
    return ClassEvent(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      className: (json['className'] ?? 'Kelas 1').toString(),
      teacher: (json['teacher'] ?? 'Ibu Sari').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'date': date,
        'className': className,
        'teacher': teacher,
      };
}
