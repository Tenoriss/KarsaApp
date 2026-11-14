class KarsaDateUtils {
  KarsaDateUtils._();

  static const List<String> monthNamesId = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> shortMonthNamesId = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> weekdayNamesId = <String>[
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> shortWeekdayLabels = <String>[
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static String formatDateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static DateTime? parseDateKey(String raw) {
    final trimmed = raw.trim();
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(trimmed);
    if (match == null) return null;
    final y = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final d = int.parse(match.group(3)!);
    final dt = DateTime(y, m, d);
    return formatDateKey(dt) == trimmed ? dt : null;
  }

  static DateTime? parseDueEndOfDay(String raw) {
    final base = parseDateKey(raw);
    if (base == null) return null;
    return DateTime(base.year, base.month, base.day, 23, 59, 59, 999);
  }

  static String formatFullDateId(DateTime d) {
    final wd = weekdayNamesId[d.weekday - 1];
    final month = monthNamesId[d.month - 1];
    return '$wd, ${d.day} $month ${d.year}';
  }

  static String formatDayMonthYearId(DateTime d) {
    return '${d.day} ${monthNamesId[d.month - 1]} ${d.year}';
  }

  static String formatDayMonthYearFromKey(String dateKey) {
    final parsed = parseDateKey(dateKey) ?? DateTime.now();
    return formatDayMonthYearId(parsed);
  }

  static String formatMonthYearId(int year, int month1Based) {
    return '${monthNamesId[month1Based - 1]} $year';
  }

  static String formatDueLabel(String? dueAtIso) {
    if (dueAtIso == null || dueAtIso.isEmpty) return 'Belum diatur';
    final parsed = DateTime.tryParse(dueAtIso)?.toLocal();
    if (parsed == null) return 'Belum diatur';
    final hh = parsed.hour.toString().padLeft(2, '0');
    final mm = parsed.minute.toString().padLeft(2, '0');
    return '${parsed.day} ${shortMonthNamesId[parsed.month - 1]} ${parsed.year}, $hh.$mm';
  }

  static String deadlineCountdown(String? dueAtIso, DateTime now) {
    if (dueAtIso == null || dueAtIso.isEmpty) return 'Belum ada tenggat';
    final parsed = DateTime.tryParse(dueAtIso);
    if (parsed == null) return 'Tenggat tidak valid';
    final diffMs = parsed.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
    if (diffMs <= 0) return 'Tenggat terlewat';
    final days = diffMs ~/ 86400000;
    final hours = (diffMs % 86400000) ~/ 3600000;
    if (days > 0) {
      return '$days hari $hours jam lagi';
    }
    final clampedHours = hours < 1 ? 1 : hours;
    return '$clampedHours jam lagi';
  }

  static String formatCreatedAtId(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $hh.$mm';
  }
}
