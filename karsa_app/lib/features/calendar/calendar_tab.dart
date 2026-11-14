import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/month_calendar.dart';
import '../../core/widgets/page_header.dart';
import '../../data/seed_data.dart';
import '../../providers/app_state.dart';

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final isNov2026Event = state.year == 2026 &&
        state.month1Based == 11 &&
        (state.day == 6 || state.day == 7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PageHeader(
          title: 'Kalender',
          sub: 'Agenda dan kegiatan sekolah',
        ),
        MonthCalendar(
          year: state.year,
          month1Based: state.month1Based,
          selectedDay: state.day,
          onPreviousMonth: () => state.moveCalendarMonth(-1),
          onNextMonth: () => state.moveCalendarMonth(1),
          onSelectDay: state.selectCalendarDay,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Agenda · ${state.day} ${KarsaDateUtils.formatMonthYearId(state.year, state.month1Based)}',
            style: theme.text.section,
          ),
        ),
        if (isNov2026Event)
          ListItemCard(
            iconEmoji: '📣',
            tileColor: const Color(0xFFF8EBEC),
            title: state.day == 6
                ? 'Hari Literasi KARSA'
                : 'Pertemuan Wali Murid',
            meta: 'Kegiatan sekolah',
            onTap: () {
              final targetId = state.day == 6 ? 'a1' : 'a2';
              final found = state.data.announcements
                  .where((a) => a.id == targetId)
                  .toList();
              final item = found.isNotEmpty
                  ? found.first
                  : SeedData.initialAnnouncements[state.day == 6 ? 0 : 1];
              state.openAnnouncement(item);
            },
          )
        else
          Text(
            'Tidak ada agenda pada tanggal ini.',
            style: theme.text.muted,
          ),
      ],
    );
  }
}
