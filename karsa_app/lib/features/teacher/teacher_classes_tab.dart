import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

class TeacherClassesTab extends StatelessWidget {
  const TeacherClassesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    final currentClass = state.filter == 'Semua kelas' ? 'Kelas 1' : state.filter;
    final classTasks =
        state.educatorTasks.where((t) => t.className == currentClass).toList();
    final classPractices = state.allPractices
        .where(
          (p) =>
              (p.className == null || p.className == currentClass) &&
              (!state.isGuru || p.subject == state.data.teacherSubject),
        )
        .toList();
    final completed =
        classTasks.where((t) => state.data.results.containsKey(t.id)).length;
    final percentage = classTasks.isNotEmpty
        ? ((completed / classTasks.length) * 100).round()
        : 0;

    final studentNames = <String>[
      state.data.studentName,
      'Sari Putri',
      'Rafi Pratama',
    ];

    final visibleSubjects = (state.isGuru
            ? <String>[state.data.teacherSubject]
            : CurriculumData.subjects)
        .where((s) => CurriculumData.subjectsForClass(currentClass).contains(s))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PageHeader(title: 'Kelas Saya', sub: 'Ruang belajar'),
        KarsaChips(
          options: AppConstants.classes,
          value: currentClass,
          onChanged: state.setFilter,
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 130),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: ClayStyles.soft(
            color: const Color(0xFFE5F0F8),
            isDark: c.isDark,
            radius: 22,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      currentClass,
                      style: TextStyle(
                        fontSize: 24,
                        color: c.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text('Belajar seru, tumbuh bersama.', style: theme.text.muted),
                    Text('Tahun ajaran 2026/2027', style: theme.text.smallMuted),
                  ],
                ),
              ),
              const Text('🏫', style: TextStyle(fontSize: 68)),
            ],
          ),
        ),
        // 2x2 Tiles Grid
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ClassMetricTile(
                      label: 'Jumlah siswa',
                      number: '3',
                      sub: 'Data contoh',
                      bgColor: c.isDark
                          ? const Color(0xFF583D47)
                          : const Color(0xFFFBD5D7),
                      onTap: () => state.setScreen('students'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ClassMetricTile(
                      label: 'Materi latihan',
                      number: '${classPractices.length}',
                      sub: 'Lihat latihan',
                      bgColor: c.isDark
                          ? const Color(0xFF354B41)
                          : const Color(0xFFD1F4D8),
                      onTap: () => state.openSubjectPage(
                        state.data.teacherSubject,
                        initialTab: 'Latihan',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ClassMetricTile(
                      label: 'Tugas berjalan',
                      number: '${classTasks.length - completed}',
                      sub: 'Lihat tugas',
                      bgColor: c.isDark
                          ? const Color(0xFF493B50)
                          : const Color(0xFFEDD7EF),
                      onTap: () => state.changeTab('Tugas'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ClassMetricTile(
                      label: 'Tugas selesai',
                      number: '$percentage%',
                      sub: 'Data demo',
                      bgColor: c.isDark
                          ? const Color(0xFF504639)
                          : const Color(0xFFF7EDDD),
                      onTap: () => state.changeTab('Tugas'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Daftar Siswa', style: theme.text.section),
              MotionPressable(
                onTap: () => state.setScreen('students'),
                child: Text('Lihat semua ›', style: theme.text.link),
              ),
            ],
          ),
        ),
        for (int i = 0; i < studentNames.length; i++)
          ListItemCard(
            iconEmoji: i == 2 ? '👦🏻' : '🙂',
            tileColor: const Color(0xFFF8EBEC),
            title: studentNames[i],
            meta: i == 0
                ? '${state.data.results.length} tugas selesai'
                : 'Siswa aktif · data contoh',
            status: 'Aktif',
            onTap: () => state.openStudentDetail(studentNames[i], i),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('Mata Pelajaran', style: theme.text.section),
        ),
        for (final subject in visibleSubjects)
          ListItemCard(
            iconEmoji: CurriculumData.metaFor(subject).icon,
            tileColor: CurriculumData.metaFor(subject).color,
            title: subject,
            meta: '$currentClass · Lihat tugas dan latihan',
            onTap: () => state.openSubjectPage(subject, initialTab: 'Tugas'),
          ),
      ],
    );
  }
}

class _ClassMetricTile extends StatelessWidget {
  final String label;
  final String number;
  final String sub;
  final Color bgColor;
  final VoidCallback onTap;

  const _ClassMetricTile({
    required this.label,
    required this.number,
    required this.sub,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    return MotionPressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        padding: const EdgeInsets.all(17),
        decoration: ClayStyles.soft(
          color: bgColor,
          isDark: c.isDark,
          radius: 23,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(label, style: TextStyle(color: c.ink, fontSize: 12)),
            Text(
              number,
              style: TextStyle(
                color: c.ink,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(sub, style: theme.text.smallMuted),
          ],
        ),
      ),
    );
  }
}
