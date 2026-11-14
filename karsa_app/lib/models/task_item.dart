import 'attachment_file.dart';

class TaskItem {
  final String id;
  final String subject;
  final String title;
  final String className;
  final String minutes;
  final String? kind; // 'file' | 'quiz' | null (defaults to quiz)
  final AttachmentFile? file;
  final String? teacher;
  final String? dueAt;
  final bool demo;
  final bool demoHistory;

  const TaskItem({
    required this.id,
    required this.subject,
    required this.title,
    required this.className,
    required this.minutes,
    this.kind,
    this.file,
    this.teacher,
    this.dueAt,
    this.demo = false,
    this.demoHistory = false,
  });

  bool get isFileTask => kind == 'file';

  TaskItem copyWith({
    String? id,
    String? subject,
    String? title,
    String? className,
    String? minutes,
    String? kind,
    AttachmentFile? file,
    String? teacher,
    String? dueAt,
    bool? demo,
    bool? demoHistory,
  }) {
    return TaskItem(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      title: title ?? this.title,
      className: className ?? this.className,
      minutes: minutes ?? this.minutes,
      kind: kind ?? this.kind,
      file: file ?? this.file,
      teacher: teacher ?? this.teacher,
      dueAt: dueAt ?? this.dueAt,
      demo: demo ?? this.demo,
      demoHistory: demoHistory ?? this.demoHistory,
    );
  }

  factory TaskItem.fromJson(Map<String, dynamic> json, {String Function(String?)? normalizeSubject}) {
    final rawSubj = json['subject']?.toString();
    final subj = normalizeSubject != null ? normalizeSubject(rawSubj) : (rawSubj ?? 'Matematika');
    return TaskItem(
      id: (json['id'] ?? '').toString(),
      subject: subj,
      title: (json['title'] ?? '').toString(),
      className: (json['className'] ?? 'Kelas 1').toString(),
      minutes: (json['minutes'] ?? '30').toString(),
      kind: json['kind']?.toString(),
      file: json['file'] is Map<String, dynamic>
          ? AttachmentFile.fromJson(json['file'] as Map<String, dynamic>)
          : null,
      teacher: json['teacher']?.toString(),
      dueAt: json['dueAt']?.toString(),
      demo: json['demo'] == true,
      demoHistory: json['demoHistory'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'subject': subject,
      'title': title,
      'className': className,
      'minutes': minutes,
    };
    if (kind != null) map['kind'] = kind;
    if (file != null) map['file'] = file!.toJson();
    if (teacher != null) map['teacher'] = teacher;
    if (dueAt != null) map['dueAt'] = dueAt;
    if (demo) map['demo'] = true;
    if (demoHistory) map['demoHistory'] = true;
    return map;
  }
}
