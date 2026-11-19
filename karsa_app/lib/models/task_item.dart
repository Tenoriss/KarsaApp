import 'attachment_file.dart';
import 'quiz_question.dart';

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

  /// Soal yang dihasilkan asisten untuk tugas ini.
  ///
  /// Kosong berarti tugas memakai bank soal contoh sesuai mata pelajaran
  /// (`CurriculumData.questionsFor`). Diisi hanya kalau guru/wali memakai
  /// simulasi asisten pada form tambah tugas.
  final List<QuizQuestion> questions;

  /// Asal soal: `'example'` (bank soal contoh) atau `'assistant'`.
  final String? questionsSource;

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
    this.questions = const <QuizQuestion>[],
    this.questionsSource,
  });

  bool get isFileTask => kind == 'file';

  /// Tugas punya soal sendiri dari simulasi asisten.
  bool get hasOwnQuestions => questions.isNotEmpty;

  /// Apakah soal berasal dari simulasi asisten (bukan bank soal contoh).
  bool get questionsFromAssistant => questionsSource == 'assistant';

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
    List<QuizQuestion>? questions,
    String? questionsSource,
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
      questions: questions ?? this.questions,
      questionsSource: questionsSource ?? this.questionsSource,
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
      questions: json['questions'] is List
          ? <QuizQuestion>[
              for (final q in json['questions'] as List)
                if (q is Map)
                  QuizQuestion.fromJson(
                    q.map((k, v) => MapEntry(k.toString(), v)),
                  ),
            ]
          : const <QuizQuestion>[],
      questionsSource: json['questionsSource']?.toString(),
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
    if (questions.isNotEmpty) {
      map['questions'] = <Map<String, dynamic>>[
        for (final q in questions) q.toJson(),
      ];
    }
    if (questionsSource != null) map['questionsSource'] = questionsSource;
    return map;
  }
}
