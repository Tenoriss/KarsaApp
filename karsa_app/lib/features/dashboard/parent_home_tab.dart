import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/school_identity.dart';
import '../../core/widgets/stat_card.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';
import '../../shared/widgets/greeting_header.dart';

class ParentHomeTab extends StatelessWidget {
  const ParentHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final activeTasks = state.activeTasks;
    final remainingPractices = state.visiblePractices.length - state.donePracticeCount;
    final classMaterials = state.data.materials
        .where((m) => m.className == state.data.childClass)
        .length;
    final previewTasks = activeTasks.length > 2
        ? activeTasks.sublist(activeTasks.length - 2)
        : activeTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SchoolIdentity(compact: true),
        GreetingHeader(
          avatarText: 'D',
          avatarIsLetter: true,
          eyebrow: 'Orang tua dari',
          userName: state.data.studentName,
          subtitle: '${state.data.childClass} · SD Karitas Purwokerto',
          isDark: c.isDark,
          badgeCount: state.totalBadgeCount,
          onToggleTheme: state.toggleDarkMode,
          onOpenNotifications: () => state.setScreen('notifications'),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 125,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Image.asset(
            AppConstants.assetStudentBanner,
            width: double.infinity,
            height: 125,
            fit: BoxFit.fill,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: StatCard(
                icon: KarsaIcons.pencil,
                label: 'Tugas Aktif',
                value: '${activeTasks.length}',
                desc: 'Belum dikumpulkan',
                color: c.blue,
                onTap: () => state.changeTab('Tugas'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: KarsaIcons.grid,
                label: 'Latihan',
                value: '$remainingPractices',
                desc: 'Belum dikerjakan',
                color: c.pink,
                onTap: () => state.changeTab('Latihan'),
              ),
            ),
          ],
        ),
        WideStatCard(
          icon: KarsaIcons.megaphone,
          label: 'Pengumuman',
          value: '${state.unreadAnnouncementsCount}',
          desc: 'Belum dibaca',
          color: AppColors.purpleStat,
          onTap: () => state.setScreen('announcements'),
        ),
        ClayCard(
          onTap: () => state.setScreen('progress'),
          backgroundColor: const Color(0xFFF8EDF0),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 3, bottom: 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('RUANG TUMBUH', style: theme.text.overline),
                    const SizedBox(height: 2),
                    Text('Perjalanan belajar ✨', style: theme.text.itemTitle),
                    Text(
                      'Lihat bintang dan semangat belajarmu',
                      style: theme.text.smallMuted,
                    ),
                  ],
                ),
              ),
              const Text('🌟', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Icon(KarsaIcons.chevronForward, color: c.rose, size: 20),
            ],
          ),
        ),
        WideStatCard(
          icon: KarsaIcons.book,
          label: 'Materi',
          value: '$classMaterials',
          desc: 'Lihat materi untuk kelasmu',
          color: c.blue,
          onTap: () => state.setScreen('materials'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Tugas untukmu', style: theme.text.section),
              MotionPressable(
                onTap: () => state.changeTab('Tugas'),
                child: Text('Lihat semua ›', style: theme.text.link),
              ),
            ],
          ),
        ),
        for (final t in previewTasks)
          ListItemCard(
            iconEmoji: CurriculumData.metaFor(t.subject).icon,
            tileColor: CurriculumData.metaFor(t.subject).color,
            title: t.title,
            meta:
                '${t.subject} · ${t.className} · ${t.minutes} menit${t.demo ? " · contoh" : ""} · ${KarsaDateUtils.deadlineCountdown(t.dueAt, state.now)}',
            status: state.data.results.containsKey(t.id) ? 'Selesai' : 'Aktif',
            onTap: () => state.openTask(t),
          ),
        if (activeTasks.isEmpty)
          Text(
            'Semua tugas sudah selesai. Hebat!',
            style: theme.text.muted,
          ),
      ],
    );
  }
}
