import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/dark_color_mapper.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/school_identity.dart';
import '../../core/widgets/stat_card.dart';
import '../../data/curriculum_data.dart';
import '../../data/seed_data.dart';
import '../../providers/app_state.dart';
import '../../shared/widgets/greeting_header.dart';

class StudentHomeTab extends StatelessWidget {
  const StudentHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final childClass = state.data.childClass;
    final classTasks = state.data.tasks.where((t) => t.className == childClass).toList();
    final completedTasks =
        classTasks.where((t) => state.data.results.containsKey(t.id)).toList();
    final activeTasks = state.activeTasks;
    final ratio = classTasks.isNotEmpty
        ? (completedTasks.length / classTasks.length).clamp(0.0, 1.0)
        : 0.0;
    final classMaterialsCount =
        state.data.materials.where((m) => m.className == childClass).length;
    final classSubjects = CurriculumData.subjectsForClass(childClass);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SchoolIdentity(compact: true),
        GreetingHeader(
          avatarText: '👦🏻',
          eyebrow: 'Halo, selamat belajar!',
          userName: state.data.studentName,
          subtitle: '$childClass · SD Karitas Purwokerto',
          isDark: c.isDark,
          badgeCount: state.totalBadgeCount,
          onToggleTheme: state.toggleDarkMode,
          onOpenNotifications: () => state.setScreen('notifications'),
        ),
        // StudentHero
        Container(
          constraints: const BoxConstraints(minHeight: 160),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: ClayStyles.soft(
            color: const Color(0xFFF9E5E9),
            isDark: c.isDark,
            radius: 26,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -30,
                top: -42,
                child: Container(
                  width: 135,
                  height: 135,
                  decoration: BoxDecoration(
                    color: DarkColorMapper.surface(
                      const Color(0xFFFCEEF0),
                      isDark: c.isDark,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: -60,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: DarkColorMapper.surface(
                      const Color(0xFFE4EFF7),
                      isDark: c.isDark,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '✦ RUANG BELAJAR',
                            style: TextStyle(
                              color: c.rose,
                              letterSpacing: 1.2,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Semangat\nbelajar!',
                            style: TextStyle(
                              fontSize: 25,
                              height: 29 / 25,
                              color: c.ink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 205),
                            child: Text(
                              'Satu langkah kecil hari ini, selangkah lebih dekat ke mimpimu.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 16 / 11,
                                color: DarkColorMapper.text(
                                  const Color(0xFF71899B),
                                  isDark: c.isDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Container(
                          width: 92,
                          height: 92,
                          decoration: ClayStyles.soft(
                            color: const Color(0xFFFDF8F5),
                            isDark: c.isDark,
                            radius: 32,
                          ),
                          alignment: Alignment.center,
                          child: const Text('📚', style: TextStyle(fontSize: 44)),
                        ),
                        const Positioned(
                          right: -7,
                          top: -8,
                          child: Text('✨', style: TextStyle(fontSize: 23)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // MissionCard
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(15),
          decoration: ClayStyles.soft(
            color: const Color(0xFFFFFDFB),
            isDark: c.isDark,
            radius: 23,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: ClayStyles.soft(
                      color: const Color(0xFFF9E8EC),
                      isDark: c.isDark,
                      radius: 14,
                    ),
                    alignment: Alignment.center,
                    child: const Text('🎯', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Misi belajarmu', style: theme.text.itemTitle),
                        Text(
                          'Selesaikan tugas di $childClass',
                          style: theme.text.smallMuted,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${completedTasks.length}/${classTasks.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: c.rose,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 8,
                  color: DarkColorMapper.surface(
                    const Color(0xFFF3E8E6),
                    isDark: c.isDark,
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: c.pink,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                activeTasks.isNotEmpty
                    ? 'Sedikit demi sedikit, kamu pasti bisa!'
                    : 'Hebat! Semua tugas sudah selesai.',
                style: theme.text.smallMuted,
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: StatCard(
                icon: KarsaIcons.pencil,
                label: 'Tugas aktif',
                value: '${activeTasks.length}',
                desc: 'Menunggu dikerjakan',
                color: c.pink,
                onTap: () => state.changeTab('Tugas'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: KarsaIcons.checkmarkCircle,
                label: 'Selesai',
                value: '${completedTasks.length}',
                desc: 'Lihat riwayat',
                color: c.blue,
                onTap: state.openHistoryShortcut,
              ),
            ),
          ],
        ),
        WideStatCard(
          icon: KarsaIcons.book,
          label: 'Materi kelas',
          value: '$classMaterialsCount',
          desc: 'Buka ringkasan dan materi',
          color: c.blue,
          onTap: () => state.setScreen('materials'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Tugas per mata pelajaran', style: theme.text.section),
              MotionPressable(
                onTap: () => state.changeTab('Tugas'),
                child: Text('Lihat semua ›', style: theme.text.link),
              ),
            ],
          ),
        ),
        for (final subject in classSubjects)
          Builder(
            builder: (context) {
              final subjList = activeTasks
                  .where((t) => t.subject == subject)
                  .toList()
                ..sort((a, b) {
                  final da = DateTime.tryParse(a.dueAt ?? '')?.millisecondsSinceEpoch ??
                      9007199254740991;
                  final db = DateTime.tryParse(b.dueAt ?? '')?.millisecondsSinceEpoch ??
                      9007199254740991;
                  return da.compareTo(db);
                });
              final next = subjList.isNotEmpty ? subjList.first : null;
              final meta = CurriculumData.metaFor(subject);
              return ListItemCard(
                iconEmoji: meta.icon,
                tileColor: meta.color,
                title: subject,
                meta: next != null
                    ? '${next.title} · ${KarsaDateUtils.deadlineCountdown(next.dueAt, state.now)}'
                    : 'Tidak ada tugas aktif',
                status: next != null ? '${subjList.length} tugas' : 'Lihat',
                onTap: () => state.openStudentSubjectShortcut(subject),
              );
            },
          ),
        MotionPressable(
          semanticsLabel: 'Lihat tips belajar berikutnya',
          onTap: state.nextStudyTip,
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: ClayStyles.soft(
              color: const Color(0xFFEEF5F9),
              isDark: c.isDark,
              radius: 22,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 45,
                  height: 45,
                  decoration: ClayStyles.soft(
                    color: const Color(0xFFFFF6E5),
                    isDark: c.isDark,
                    radius: 15,
                  ),
                  alignment: Alignment.center,
                  child: const Text('💡', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Tips belajar', style: theme.text.itemTitle),
                      Text(
                        SeedData.studyTips[state.tipIndex],
                        style: theme.text.smallMuted,
                      ),
                    ],
                  ),
                ),
                Icon(KarsaIcons.refreshOutline, color: c.rose, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
