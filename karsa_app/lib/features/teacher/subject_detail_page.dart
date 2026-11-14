import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/karsa_segment_tabs.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

class SubjectDetailPage extends StatelessWidget {
  const SubjectDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final subjectClass = state.filter == 'Semua kelas' ? 'Kelas 1' : state.filter;
    final subject = state.draftSubject;
    final subjectTasks = state.data.tasks
        .where((t) => t.subject == subject && t.className == subjectClass)
        .toList();
    final subjectPractices = state.allPractices
        .where(
          (p) =>
              p.subject == subject &&
              (p.className == null || p.className == subjectClass),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: subject,
          sub: '$subjectClass · Mata pelajaran',
          onBack: () => state.setScreen('main'),
        ),
        KarsaSegmentTabs(
          options: const <String>['Tugas', 'Latihan'],
          value: state.subjectTab,
          onChanged: state.setSubjectTab,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              state.subjectTab == 'Tugas'
                  ? '${subjectTasks.length} tugas'
                  : '${subjectPractices.length} latihan',
              style: theme.text.muted,
            ),
            MotionPressable(
              onTap: () => state.openForm(
                state.subjectTab == 'Tugas' ? 'taskForm' : 'practiceForm',
                overrideSubject: subject,
                overrideClass: subjectClass,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: c.rose,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '＋ Tambah',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.subjectTab == 'Tugas') ...<Widget>[
          for (final t in subjectTasks)
            ListItemCard(
              iconEmoji: CurriculumData.metaFor(t.subject).icon,
              tileColor: CurriculumData.metaFor(t.subject).color,
              title: t.title,
              meta:
                  '${t.subject} · ${t.className} · ${t.minutes} menit${t.demo ? " · contoh" : ""} · ${KarsaDateUtils.deadlineCountdown(t.dueAt, state.now)}',
              status: state.data.results.containsKey(t.id) ? 'Selesai' : 'Aktif',
              onTap: () => state.openTask(t),
            ),
          if (subjectTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 35),
              child: Text(
                'Belum ada tugas untuk kelas ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted),
              ),
            ),
        ] else ...<Widget>[
          for (final p in subjectPractices)
            ListItemCard(
              iconEmoji: CurriculumData.metaFor(p.subject).icon,
              tileColor: CurriculumData.metaFor(p.subject).color,
              title: p.title,
              meta: '5 soal esai · tanpa batas waktu',
              status: 'Latihan',
              onTap: () => state.openPractice(
                p,
                previewForTeacher: true,
                from: 'subject',
              ),
            ),
          if (subjectPractices.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 35),
              child: Text(
                'Belum ada latihan untuk kelas ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted),
              ),
            ),
        ],
      ],
    );
  }
}
