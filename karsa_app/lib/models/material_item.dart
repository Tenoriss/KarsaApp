import 'attachment_file.dart';

class MaterialItem {
  final String id;
  final String title;
  final String subject;
  final String className;
  final AttachmentFile? file;
  final String summary;
  final String teacher;

  const MaterialItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.className,
    this.file,
    required this.summary,
    required this.teacher,
  });

  factory MaterialItem.fromJson(
    Map<String, dynamic> json, {
    String Function(String?)? normalizeSubject,
  }) {
    final rawSubj = json['subject']?.toString();
    return MaterialItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subject: normalizeSubject != null ? normalizeSubject(rawSubj) : (rawSubj ?? 'Matematika'),
      className: (json['className'] ?? 'Kelas 1').toString(),
      file: json['file'] is Map<String, dynamic>
          ? AttachmentFile.fromJson(json['file'] as Map<String, dynamic>)
          : null,
      summary: (json['summary'] ?? '').toString(),
      teacher: (json['teacher'] ?? 'Ibu Sari').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'subject': subject,
        'className': className,
        'file': file?.toJson(),
        'summary': summary,
        'teacher': teacher,
      };
}
