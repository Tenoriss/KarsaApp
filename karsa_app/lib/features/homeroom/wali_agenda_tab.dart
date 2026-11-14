import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/month_calendar.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class WaliAgendaTab extends StatelessWidget {
  const WaliAgendaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final selectedDateKey = KarsaDateUtils.formatDateKey(
      DateTime(state.year, state.month1Based, state.day),
    );
    final events = state.data.classEvents
        .where(
          (e) =>
              e.className == AppConstants.waliClass && e.date == selectedDateKey,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PageHeader(
          title: 'Agenda Kelas',
          sub: '${AppConstants.waliClass} · kegiatan dan pengingat',
        ),
        KarsaButton(
          title: '+ Tambah agenda',
          onTap: state.openEventForm,
        ),
        const SizedBox(height: 20),
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
        for (final e in events)
          ListItemCard(
            iconEmoji: '📅',
            tileColor: const Color(0xFFF8EBEC),
            title: e.title,
            meta: '${AppConstants.waliClass} · ${e.date}',
            status: 'Lihat',
            onTap: () => state.openAgendaDetail(e),
          ),
        if (events.isEmpty)
          Text(
            'Belum ada agenda kelas pada tanggal ini.',
            style: theme.text.muted,
          ),
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Text(
            'Agenda disimpan lokal. Notifikasi hanya terlihat di perangkat yang sama.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colors.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
