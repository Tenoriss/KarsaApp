import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/chart_row.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/school_identity.dart';
import '../../core/widgets/stat_card.dart';
import '../../providers/app_state.dart';
import '../../shared/widgets/greeting_header.dart';

class WaliHomeTab extends StatelessWidget {
  const WaliHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final members = state.classMembers;
    final todayMap = state.todayAttendance;
    final recordedCount = members.where((m) => todayMap.containsKey(m.id)).length;
    final notRecorded = members.length - recordedCount;
    final scored = state.scoredMembers;
    final avg = state.scoreAverage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SchoolIdentity(compact: true),
        GreetingHeader(
          avatarText: '👩🏻‍🏫',
          eyebrow: 'Selamat datang, Wali Kelas',
          userName: state.data.waliName,
          subtitle: '${AppConstants.waliClass} · SD Karitas Purwokerto',
          isDark: c.isDark,
          badgeCount: state.totalBadgeCount,
          onToggleTheme: state.toggleDarkMode,
          onOpenNotifications: () => state.setScreen('notifications'),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: ClayStyles.soft(
            color: const Color(0xFFF9EBEE),
            isDark: c.isDark,
            radius: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('RUANG WALI KELAS', style: theme.text.overline),
              const SizedBox(height: 8),
              Text(
                'Tumbuh bersama, ${AppConstants.waliClass} 🌱',
                style: TextStyle(
                  color: c.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pantau kehadiran dan perkembangan belajar siswa dalam satu tempat.',
                style: theme.text.muted,
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: StatCard(
                icon: KarsaIcons.people,
                label: 'Anggota kelas',
                value: '${members.length}',
                desc: 'Data contoh',
                color: c.blue,
                onTap: () => state.changeTab('Anggota'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: KarsaIcons.checkmarkCircle,
                label: 'Hadir hari ini',
                value: '${state.recordsForTodayStatus("Hadir")}/${members.length}',
                desc: '$notRecorded belum dicatat',
                color: c.pink,
                onTap: () => state.openWaliRecapShortcut(
                  tabName: 'Kehadiran',
                  resetToToday: true,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Kehadiran hari ini', style: theme.text.section),
              MotionPressable(
                onTap: () => state.openWaliRecapShortcut(
                  tabName: 'Kehadiran',
                  resetToToday: true,
                ),
                child: Text('Isi kehadiran ›', style: theme.text.link),
              ),
            ],
          ),
        ),
        ClayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${KarsaDateUtils.formatFullDateId(DateTime.now())} · data dicatat manual',
                style: theme.text.smallMuted,
              ),
              ChartRow(
                label: 'Hadir',
                count: state.recordsForTodayStatus('Hadir').toDouble(),
                total: members.length.toDouble(),
                color: AppColors.attendanceHadir,
              ),
              ChartRow(
                label: 'Izin',
                count: state.recordsForTodayStatus('Izin').toDouble(),
                total: members.length.toDouble(),
                color: AppColors.attendanceIzin,
              ),
              ChartRow(
                label: 'Sakit',
                count: state.recordsForTodayStatus('Sakit').toDouble(),
                total: members.length.toDouble(),
                color: AppColors.attendanceSakit,
              ),
              ChartRow(
                label: 'Alpa',
                count: state.recordsForTodayStatus('Alpa').toDouble(),
                total: members.length.toDouble(),
                color: AppColors.attendanceAlpa,
              ),
              const SizedBox(height: 12),
              Text(
                '$notRecorded dari ${members.length} siswa belum dicatat.',
                style: theme.text.smallMuted,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Gambaran nilai', style: theme.text.section),
              MotionPressable(
                onTap: () => state.openWaliRecapShortcut(tabName: 'Nilai'),
                child: Text('Lihat rekap ›', style: theme.text.link),
              ),
            ],
          ),
        ),
        ClayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: ClayStyles.raised(
                      color: c.card,
                      isDark: c.isDark,
                      radius: 20,
                    ),
                    alignment: Alignment.center,
                    child: const Text('📊', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Rata-rata kelas', style: theme.text.itemTitle),
                        Text(
                          'Dari ${scored.length} siswa yang sudah diisi',
                          style: theme.text.smallMuted,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    avg == null ? '—' : '$avg',
                    style: theme.text.statNumber,
                  ),
                ],
              ),
              if (scored.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Belum ada nilai. Isi rekap nilai untuk melihat grafik.',
                    style: theme.text.smallMuted,
                  ),
                )
              else
                for (final m in scored)
                  ChartRow(
                    label: m.name.split(' ').first,
                    count: state.data.classScores[m.id] ?? 0,
                    total: 100,
                    color: c.blue,
                  ),
            ],
          ),
        ),
        MotionPressable(
          onTap: () => state.changeTab('Agenda'),
          child: Container(
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.all(16),
            decoration: ClayStyles.soft(
              color: c.card,
              isDark: c.isDark,
              radius: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('📅 Agenda kelas', style: theme.text.itemTitle),
                Text('Lihat agenda ›', style: theme.text.link),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Text(
            'Data contoh disimpan di perangkat ini, bukan data sekolah sebenarnya.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
