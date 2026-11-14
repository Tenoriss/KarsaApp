import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/school_identity.dart';
import '../../core/widgets/stat_card.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';
import '../../shared/widgets/greeting_header.dart';

class TeacherHomeTab extends StatelessWidget {
  const TeacherHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final educatorTasks = state.educatorTasks;
    final activeEducatorCount =
        educatorTasks.where((t) => !state.data.results.containsKey(t.id)).length;
    final practiceCount = state.allPractices
        .where((p) => !state.isGuru || p.subject == state.data.teacherSubject)
        .length;
    final recentTasks = educatorTasks.length > 2
        ? educatorTasks.sublist(educatorTasks.length - 2)
        : educatorTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SchoolIdentity(compact: true),
        GreetingHeader(
          avatarText: '👩🏻‍🏫',
          eyebrow: 'Selamat datang,',
          userName: state.data.teacherName,
          subtitle: 'Guru ${state.data.teacherSubject} · SD Karitas Purwokerto',
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
            AppConstants.assetTeacherBanner,
            width: double.infinity,
            height: 125,
            fit: BoxFit.fill,
          ),
        ),
        KarsaChips(
          options: const <String>['Semua kelas', ...AppConstants.classes],
          value: state.filter,
          onChanged: state.setFilter,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: StatCard(
                icon: KarsaIcons.people,
                label: 'Kelas',
                value: state.filter == 'Semua kelas' ? '6' : '1',
                desc: 'Lihat kelas',
                color: c.blue,
                onTap: () => state.changeTab('Kelas'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: KarsaIcons.pencil,
                label: 'Tugas Aktif',
                value: '$activeEducatorCount',
                desc: 'Kelola tugas',
                color: c.pink,
                onTap: () => state.changeTab('Tugas'),
              ),
            ),
          ],
        ),
        WideStatCard(
          icon: KarsaIcons.grid,
          label: 'Latihan',
          value: '$practiceCount',
          desc: 'Kelola latihan di kelas',
          color: AppColors.purpleStat,
          onTap: () => state.changeTab('Kelas'),
        ),
        WideStatCard(
          icon: KarsaIcons.megaphone,
          label: 'Pengumuman',
          value: '${state.unreadAnnouncementsCount}',
          desc: 'Belum dibaca',
          color: AppColors.purpleStat,
          onTap: () => state.setScreen('announcements'),
        ),
        WideStatCard(
          icon: KarsaIcons.book,
          label: 'Materi',
          value: '${state.data.materials.length}',
          desc: 'Kelola materi pembelajaran',
          color: c.blue,
          onTap: () => state.setScreen('materials'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Tugas Terbaru', style: theme.text.section),
              MotionPressable(
                onTap: () => state.changeTab('Tugas'),
                child: Text('Lihat semua ›', style: theme.text.link),
              ),
            ],
          ),
        ),
        for (final t in recentTasks)
          ListItemCard(
            iconEmoji: CurriculumData.metaFor(t.subject).icon,
            tileColor: CurriculumData.metaFor(t.subject).color,
            title: t.title,
            meta:
                '${t.subject} · ${t.className} · ${t.minutes} menit${t.demo ? " · contoh" : ""} · ${KarsaDateUtils.deadlineCountdown(t.dueAt, state.now)}',
            status: state.data.results.containsKey(t.id) ? 'Selesai' : 'Aktif',
            onTap: () => state.openTask(t),
          ),
      ],
    );
  }
}
