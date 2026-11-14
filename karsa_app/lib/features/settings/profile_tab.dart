import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/dark_color_mapper.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../models/demo_account.dart';
import '../../models/user_role.dart';
import '../../providers/app_state.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  IconData _settingIcon(String label) {
    switch (label) {
      case 'Informasi pribadi':
        return KarsaIcons.personOutline;
      case 'Mata pelajaran':
        return KarsaIcons.bookOutline;
      case 'Tampilan':
        return KarsaIcons.moonOutline;
      case 'Notifikasi':
        return KarsaIcons.notificationsOutline;
      case 'Privasi dan keamanan':
        return KarsaIcons.shieldCheckmarkOutline;
      default:
        return KarsaIcons.helpCircleOutline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final role = state.role ?? UserRole.siswa;

    if (role == UserRole.wali) {
      return _buildWaliProfile(context, state, theme, c);
    }

    final isTeacher = role.isTeacher;
    final isStudent = role.isStudent;
    final activeTasks = state.activeTasks;
    final educatorTasks = state.educatorTasks;
    final needReviewCount = educatorTasks
        .where(
          (t) =>
              state.data.results.containsKey(t.id) &&
              !state.data.reviewed.contains(t.id),
        )
        .length;

    final settingsItems = <String>[
      'Informasi pribadi',
      if (role == UserRole.guru) 'Mata pelajaran',
      'Tampilan',
      'Notifikasi',
      'Privasi dan keamanan',
      'Pusat bantuan',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: isTeacher ? 'Profil Guru' : 'Profil Anak',
          sub: 'Senang bertemu denganmu!',
        ),
        if (!isTeacher)
          NoticeCard(
            title: '🌟 Semangat belajar, ${state.data.studentName}!',
            body: activeTasks.isNotEmpty
                ? 'Ada ${activeTasks.length} tugas yang belum dikumpulkan.'
                : 'Semua tugas sudah selesai. Hebat!',
          ),
        _ProfileAvatarHero(
          emoji: isTeacher ? '👩🏻‍🏫' : '👦🏻',
          name: isTeacher ? state.data.teacherName : state.data.studentName,
          subtitle: isTeacher
              ? 'Guru ${state.data.teacherSubject} · SD Karitas Purwokerto'
              : '${state.data.childClass} · SD Karitas Purwokerto',
          badgeText: isTeacher ? 'Guru aktif' : 'Siswa aktif',
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            isTeacher
                ? 'Informasi Guru'
                : (isStudent ? 'Aktivitas Tugas' : 'Perjalanan Belajarku'),
            style: theme.text.section,
          ),
        ),
        ClayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                isTeacher
                    ? 'Mata Pelajaran'
                    : (isStudent
                        ? 'Semangat mengerjakan tugas!'
                        : 'Terus bertumbuh! 🌱'),
                style: theme.text.itemTitle,
              ),
              const SizedBox(height: 4),
              Text(
                isTeacher
                    ? state.data.teacherSubject
                    : (isStudent
                        ? '${state.data.tasks.where((t) => t.className == state.data.childClass && state.data.results.containsKey(t.id)).length} tugas selesai.'
                        : '${state.data.results.length} tugas dan ${state.donePracticeCount} latihan selesai.'),
                style: theme.text.muted,
              ),
            ],
          ),
        ),
        if (isTeacher) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 10),
            child: Text('Informasi Guru', style: theme.text.section),
          ),
          ClayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Kelas diampu', style: theme.text.smallMuted),
                Text('Kelas 1 sampai Kelas 6', style: theme.text.itemTitle),
                const SizedBox(height: 10),
                Text('NIP demo', style: theme.text.smallMuted),
                Text(DemoAccount.forRole(role).id, style: theme.text.itemTitle),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('Ringkasan Aktivitas', style: theme.text.section),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: StatCard(
                  icon: KarsaIcons.checkmark,
                  label: 'Tugas Aktif',
                  value:
                      '${educatorTasks.where((t) => !state.data.results.containsKey(t.id)).length}',
                  desc: 'Lihat tugas',
                  color: c.blue,
                  onTap: () => state.changeTab('Tugas'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: KarsaIcons.albums,
                  label: 'Kuis Dibuat',
                  value: '${educatorTasks.length}',
                  desc: 'Data demo',
                  color: c.pink,
                  onTap: () => state.changeTab('Tugas'),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: StatCard(
                  icon: KarsaIcons.people,
                  label: 'Siswa',
                  value: '3',
                  desc: 'Data contoh',
                  color: AppColors.purpleStat,
                  onTap: () => state.setScreen('students'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: KarsaIcons.checkmarkDone,
                  label: 'Perlu Diperiksa',
                  value: '$needReviewCount',
                  desc: 'Hasil baru',
                  color: AppColors.greenStat,
                  onTap: () => state.changeTab('Tugas'),
                ),
              ),
            ],
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text('Pengaturan', style: theme.text.section),
        ),
        for (final item in settingsItems)
          ClayCard(
            onTap: () => state.openSetting(item),
            child: Row(
              children: <Widget>[
                Icon(_settingIcon(item), color: c.rose, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(item, style: theme.text.itemTitle)),
                Icon(KarsaIcons.chevronForward, size: 17, color: c.muted),
              ],
            ),
          ),
        Center(
          child: MotionPressable(
            onTap: state.logout,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Keluar dari akun demo', style: theme.text.link),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaliProfile(
    BuildContext context,
    AppState state,
    KarsaThemeScope theme,
    AppColors c,
  ) {
    const settingsItems = <String>[
      'Informasi pribadi',
      'Tampilan',
      'Notifikasi',
      'Privasi dan keamanan',
      'Pusat bantuan',
    ];
    final members = state.classMembers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PageHeader(
          title: 'Profil Wali Kelas',
          sub: 'Senang bertemu denganmu!',
        ),
        _ProfileAvatarHero(
          emoji: '👩🏻‍🏫',
          name: state.data.waliName,
          subtitle: 'Wali ${AppConstants.waliClass} · SD Karitas Purwokerto',
          badgeText: 'Wali kelas aktif',
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('Informasi Wali Kelas', style: theme.text.section),
        ),
        ClayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Kelas diampu', style: theme.text.smallMuted),
              Text(AppConstants.waliClass, style: theme.text.itemTitle),
              const SizedBox(height: 10),
              Text('NIP demo', style: theme.text.smallMuted),
              Text(
                DemoAccount.forRole(UserRole.wali).id,
                style: theme.text.itemTitle,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('Ringkasan Aktivitas', style: theme.text.section),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: StatCard(
                icon: KarsaIcons.people,
                label: 'Anggota',
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
                value:
                    '${state.recordsForTodayStatus("Hadir")}/${members.length}',
                desc: 'Rekap kehadiran',
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
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Text('Pengaturan', style: theme.text.section),
        ),
        for (final item in settingsItems)
          ClayCard(
            onTap: () => state.openSetting(item),
            child: Row(
              children: <Widget>[
                Icon(_settingIcon(item), color: c.rose, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(item, style: theme.text.itemTitle)),
                Icon(KarsaIcons.chevronForward, size: 17, color: c.muted),
              ],
            ),
          ),
        Center(
          child: MotionPressable(
            onTap: state.logout,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Keluar dari akun demo', style: theme.text.link),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatarHero extends StatelessWidget {
  final String emoji;
  final String name;
  final String subtitle;
  final String badgeText;

  const _ProfileAvatarHero({
    required this.emoji,
    required this.name,
    required this.subtitle,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        children: <Widget>[
          Container(
            width: 84,
            height: 84,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: ClayStyles.soft(
              color: const Color(0xFFF4E4E7),
              isDark: c.isDark,
              radius: 42,
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 42)),
          ),
          Text(name, style: theme.text.name),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.text.muted),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: DarkColorMapper.surface(
                const Color(0xFFF9E6EA),
                isDark: c.isDark,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: c.rose,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
