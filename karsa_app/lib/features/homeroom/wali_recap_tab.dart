import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/dark_color_mapper.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/chart_row.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/karsa_segment_tabs.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class WaliRecapTab extends StatelessWidget {
  const WaliRecapTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final members = state.classMembers;
    final dayAtt = state.dayAttendance;
    final scores = state.data.classScores;
    final avg = state.scoreAverage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PageHeader(
          title: 'Rekap Kelas',
          sub: '${AppConstants.waliClass} · data lokal',
        ),
        KarsaSegmentTabs(
          options: const <String>['Kehadiran', 'Nilai'],
          value: state.recapTab,
          onChanged: state.setRecapTab,
        ),
        if (state.recapTab == 'Kehadiran') ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                MotionPressable(
                  semanticsLabel: 'Tanggal sebelumnya',
                  onTap: () => state.moveRecapDate(-1),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(KarsaIcons.chevronBack, color: c.ink, size: 20),
                  ),
                ),
                Text(
                  KarsaDateUtils.formatDayMonthYearFromKey(state.recapDate),
                  style: theme.text.itemTitle,
                ),
                MotionPressable(
                  semanticsLabel: 'Tanggal berikutnya',
                  onTap: () => state.moveRecapDate(1),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(KarsaIcons.chevronForward, color: c.ink, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              'Pilih satu status untuk setiap siswa. Perubahan tersimpan otomatis.',
              style: theme.text.muted,
            ),
          ),
          for (final m in members)
            ClayCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(m.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(m.name, style: theme.text.itemTitle),
                            Text(
                              dayAtt[m.id] ?? 'Belum dicatat',
                              style: theme.text.smallMuted,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      for (int i = 0; i < AppConstants.attendanceStatuses.length; i++) ...<Widget>[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final st = AppConstants.attendanceStatuses[i];
                              final selected = dayAtt[m.id] == st;
                              return MotionPressable(
                                semanticsLabel: '${m.name}: $st',
                                onTap: () => state.setAttendance(m.id, st),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? c.rose
                                        : DarkColorMapper.surface(
                                            const Color(0xFFF7EEED),
                                            isDark: c.isDark,
                                          ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    st,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: selected ? Colors.white : c.ink,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (dayAtt.containsKey(m.id))
                    Align(
                      alignment: Alignment.centerRight,
                      child: MotionPressable(
                        semanticsLabel: 'Hapus kehadiran ${m.name}',
                        onTap: () => state.clearAttendance(m.id),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Hapus catatan', style: theme.text.link),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ] else ...<Widget>[
          ClayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Rata-rata kelas: ${avg == null ? "—" : avg}',
                  style: theme.text.itemTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  'Rata-rata dari ${state.scoredMembers.length} nilai ringkas yang diisi manual, skala 0–100.',
                  style: theme.text.smallMuted,
                ),
                for (final m in members)
                  Builder(
                    builder: (context) {
                      final val = scores[m.id];
                      final shown = val == null
                          ? '—'
                          : (val == val.roundToDouble()
                              ? val.toInt().toString()
                              : val.toString());
                      return ChartRow(
                        label: m.name.split(' ').first,
                        count: val ?? 0,
                        display: shown,
                        total: 100,
                        color: c.pink,
                      );
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Ketuk siswa untuk menambah atau mengubah nilai.',
              style: theme.text.muted,
            ),
          ),
          for (final m in members)
            Builder(
              builder: (context) {
                final val = scores[m.id];
                final badge = val == null
                    ? 'Belum diisi'
                    : (val == val.roundToDouble()
                        ? val.toInt().toString()
                        : val.toString());
                return ListItemCard(
                  iconEmoji: m.icon,
                  tileColor: const Color(0xFFE4EEF7),
                  title: m.name,
                  meta: 'Nilai ringkas · data lokal',
                  status: badge,
                  onTap: () => state.editMember(m),
                );
              },
            ),
        ],
      ],
    );
  }
}
