import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/karsa_segment_tabs.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final query = state.search.trim().toLowerCase();
    final childSubjects = CurriculumData.subjectsForClass(state.data.childClass);

    final filteredTasks = state.data.tasks
        .where(
          (t) =>
              !state.isStudent ||
              state.subjectFilter == 'Semua' ||
              t.subject == state.subjectFilter,
        )
        .where((t) {
          if (query.isEmpty) return true;
          final hay = '${t.title} ${t.subject} ${t.className}'.toLowerCase();
          return hay.contains(query);
        })
        .where((t) {
          if (state.isTeacher) {
            final classOk =
                state.filter == 'Semua kelas' || t.className == state.filter;
            final subjOk = !state.isGuru || t.subject == state.data.teacherSubject;
            final done = state.data.results.containsKey(t.id);
            final statusOk = state.taskFilter == 'Semua' ||
                (state.taskFilter == 'Selesai' ? done : !done);
            return classOk && subjOk && statusOk;
          } else {
            final classOk = t.className == state.data.childClass &&
                childSubjects.contains(t.subject);
            final done = state.data.results.containsKey(t.id);
            final statusOk = state.taskFilter == 'Riwayat' ? done : !done;
            return classOk && statusOk;
          }
        })
        .toList();

    final headerTitle = (state.isStudent && state.subjectFilter != 'Semua')
        ? state.subjectFilter
        : (state.isTeacher ? 'Daftar Tugas' : 'Tugas');
    final headerSub = state.isTeacher
        ? 'Aktivitas kelas'
        : '${state.data.studentName} · ${state.data.childClass}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(title: headerTitle, sub: headerSub),
        if (state.isStudent) ...<Widget>[
          KarsaChips(
            options: <String>['Semua', ...childSubjects],
            value: state.subjectFilter,
            onChanged: state.setSubjectFilter,
          ),
          if (state.subjectFilter != 'Semua')
            KarsaSegmentTabs(
              options: const <String>['Tugas', 'Latihan'],
              value: state.learnerSubjectTab,
              onChanged: state.setLearnerSubjectTab,
            ),
        ],
        if (state.isStudent && state.learnerSubjectTab == 'Latihan') ...<Widget>[
          for (final p in state.visiblePractices
              .where((p) => p.subject == state.subjectFilter))
            ListItemCard(
              iconEmoji: CurriculumData.metaFor(p.subject).icon,
              tileColor: CurriculumData.metaFor(p.subject).color,
              title: p.title,
              meta: '5 soal esai · tanpa batas waktu',
              status:
                  state.data.practiceDone[p.id] == true ? 'Selesai' : 'Kerjakan',
              onTap: () => state.openPractice(p),
            ),
        ] else ...<Widget>[
          if (state.isTeacher)
            KarsaInput(
              value: state.search,
              onChanged: state.setSearch,
              placeholder: 'Cari tugas atau mata pelajaran...',
              semanticsLabel: 'Cari tugas',
            ),
          KarsaSegmentTabs(
            options: state.isTeacher
                ? const <String>['Semua', 'Berjalan', 'Selesai']
                : const <String>['Aktif', 'Riwayat'],
            value: state.taskFilter,
            onChanged: state.setTaskFilter,
          ),
          if (state.isTeacher)
            KarsaButton(
              title: '+ Tambah tugas',
              onTap: () => state.openForm('taskForm'),
            ),
          if (state.isGuru)
            KarsaButton(
              title: 'Rekap nilai per kelas',
              onTap: () => state.openGradeRecap(
                state.filter == 'Semua kelas' ? 'Kelas 1' : state.filter,
                'main',
              ),
            ),
          const NoticeCard(
            title: '📚 Semangat belajar!',
            body: 'Kerjakan tugas sedikit demi sedikit setiap hari.',
          ),
          for (final t in filteredTasks)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    '${CurriculumData.metaFor(t.subject).icon} ${t.subject.toUpperCase()}',
                    style: theme.text.overline,
                  ),
                ),
                ListItemCard(
                  iconEmoji: CurriculumData.metaFor(t.subject).icon,
                  tileColor: CurriculumData.metaFor(t.subject).color,
                  title: t.title,
                  meta:
                      '${t.subject} · ${t.className} · ${t.minutes} menit${t.demo ? " · contoh" : ""} · ${KarsaDateUtils.deadlineCountdown(t.dueAt, state.now)}',
                  status: state.data.results.containsKey(t.id)
                      ? 'Selesai'
                      : (state.isTeacher ? 'Aktif' : 'Kerjakan'),
                  onTap: () => state.openTask(t),
                ),
              ],
            ),
          if (filteredTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 35),
              child: Text(
                'Belum ada tugas di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted),
              ),
            ),
        ],
      ],
    );
  }
}
