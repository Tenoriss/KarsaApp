import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

/// Daftar seluruh tugas sekolah. Operator sekolah bisa menambah, mengubah,
/// dan menghapus tugas milik guru maupun wali kelas.
class OperatorTasksPage extends StatelessWidget {
  const OperatorTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    final filter = state.filter == 'Semua kelas' ? 'Semua kelas' : state.filter;
    final all = state.data.tasks;
    final tasks = filter == 'Semua kelas'
        ? all
        : all.where((t) => t.className == filter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Tugas Sekolah',
          sub: '${all.length} tugas dari semua guru',
          onBack: () => state.setScreen('main'),
        ),
        KarsaChips(
          options: <String>['Semua kelas', ...state.operatorClassOptions],
          value: filter,
          onChanged: state.setFilter,
        ),
        const SizedBox(height: 6),
        if (tasks.isEmpty)
          const NoticeCard(body: 'Belum ada tugas untuk kelas ini.')
        else
          for (final task in tasks)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ListItemCard(
                    iconEmoji: CurriculumData.metaFor(task.subject).icon,
                    tileColor: CurriculumData.metaFor(task.subject).color,
                    title: task.title,
                    meta: '${task.subject} · ${task.className}'
                        '${task.teacher == null || task.teacher!.isEmpty ? '' : ' · ${task.teacher}'}',
                    status: '${task.minutes} menit',
                    onTap: () => state.openOperatorTaskForm(task.id),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => state.openOperatorTaskForm(task.id),
                        child: Text('Ubah', style: theme.text.link),
                      ),
                      TextButton(
                        onPressed: () => state.deleteTask(task.id),
                        child: Text('Hapus', style: theme.text.link),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        KarsaButton(
          title: '+ Tambah tugas',
          onTap: () => state.openOperatorTaskForm(),
        ),
        Text(
          'Operator sekolah boleh menambah, mengubah, dan menghapus tugas milik role lain.',
          style: theme.text.smallMuted.copyWith(color: c.muted),
        ),
      ],
    );
  }
}

/// Form tambah / ubah tugas sekolah.
class OperatorTaskFormPage extends StatelessWidget {
  const OperatorTaskFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final isEdit = state.draftTaskId.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: isEdit ? 'Ubah Tugas' : 'Tambah Tugas',
          sub: 'Tersimpan di perangkat ini',
          onBack: () => state.setScreen('operatorTasks'),
        ),
        Text('Judul', style: theme.text.label),
        KarsaInput(
          value: state.draftTitle,
          onChanged: state.setDraftTitle,
          placeholder: 'Mis. Pecahan sederhana',
          semanticsLabel: 'Judul tugas',
        ),
        Text('Mata pelajaran', style: theme.text.label),
        KarsaChips(
          options: CurriculumData.subjects,
          value: state.draftSubject,
          onChanged: state.setDraftSubject,
        ),
        Text('Untuk kelas', style: theme.text.label),
        KarsaChips(
          options: state.operatorClassOptions,
          value: state.draftClass,
          onChanged: state.setDraftClass,
        ),
        Text('Durasi pengerjaan (menit)', style: theme.text.label),
        KarsaInput(
          value: state.draftMinutes,
          onChanged: state.setDraftMinutes,
          keyboardType: TextInputType.number,
          semanticsLabel: 'Durasi pengerjaan',
        ),
        Text('Tenggat pengumpulan (YYYY-MM-DD)', style: theme.text.label),
        KarsaInput(
          value: state.draftDue,
          onChanged: state.setDraftDue,
          placeholder: '2026-12-31',
          semanticsLabel: 'Tenggat pengumpulan',
        ),
        if (state.error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              state.error,
              style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
            ),
          ),
        KarsaButton(
          title: 'Simpan tugas',
          onTap: state.saveOperatorTask,
        ),
        if (isEdit)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                state.deleteTask(state.draftTaskId);
                state.setScreen('operatorTasks');
              },
              child: Text('Hapus tugas ini', style: theme.text.link),
            ),
          ),
      ],
    );
  }
}
