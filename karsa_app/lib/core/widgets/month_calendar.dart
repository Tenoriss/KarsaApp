import 'package:flutter/material.dart';
import '../theme/karsa_theme.dart';
import '../utils/date_utils.dart';
import 'karsa_icons.dart';
import 'motion_pressable.dart';

class MonthCalendar extends StatelessWidget {
  final int year;
  final int month1Based;
  final int selectedDay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<int> onSelectDay;

  const MonthCalendar({
    super.key,
    required this.year,
    required this.month1Based,
    required this.selectedDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final firstOfMonth = DateTime(year, month1Based, 1);
    final leadingBlanks = firstOfMonth.weekday - 1; // Senin = 0 .. Minggu = 6
    final daysInMonth = DateTime(year, month1Based + 1, 0).day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              MotionPressable(
                semanticsLabel: 'Bulan sebelumnya',
                onTap: onPreviousMonth,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(KarsaIcons.chevronBack, size: 20, color: c.ink),
                ),
              ),
              Text(
                KarsaDateUtils.formatMonthYearId(year, month1Based),
                style: theme.text.section,
              ),
              MotionPressable(
                semanticsLabel: 'Bulan berikutnya',
                onTap: onNextMonth,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(KarsaIcons.chevronForward, size: 20, color: c.ink),
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = constraints.maxWidth / 7;
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Wrap(
                children: <Widget>[
                  for (final label in KarsaDateUtils.shortWeekdayLabels)
                    SizedBox(
                      width: cellWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: c.muted, fontSize: 12),
                        ),
                      ),
                    ),
                  for (int i = 0; i < leadingBlanks; i++)
                    SizedBox(width: cellWidth, height: 42),
                  for (int d = 1; d <= daysInMonth; d++)
                    SizedBox(
                      width: cellWidth,
                      child: MotionPressable(
                        onTap: () => onSelectDay(d),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          margin: const EdgeInsets.all(2),
                          decoration: selectedDay == d
                              ? BoxDecoration(
                                  color: c.rose,
                                  borderRadius: BorderRadius.circular(20),
                                )
                              : null,
                          child: Text(
                            '$d',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedDay == d ? Colors.white : c.ink,
                              fontWeight: selectedDay == d
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
