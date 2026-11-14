class GradeReportRow {
  final String name;
  final String task;
  final double? grade;
  final String note;

  const GradeReportRow({
    required this.name,
    required this.task,
    required this.grade,
    required this.note,
  });

  String get formattedGrade {
    if (grade == null) return '—';
    if (grade! == grade!.roundToDouble()) {
      return grade!.toInt().toString();
    }
    return grade!.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class GradeReportPayload {
  final String className;
  final String subject;
  final String teacher;
  final List<GradeReportRow> rows;

  const GradeReportPayload({
    required this.className,
    required this.subject,
    required this.teacher,
    required this.rows,
  });
}
