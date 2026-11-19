import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

class TeacherTaskDetailPage extends StatelessWidget {
  const TeacherTaskDetailPage({super.key});

  String _formatGrade(double? grade) {
    if (grade == null) return '—';
    if (grade == grade.roundToDouble()) return grade.toInt().toString();
    return grade.toString();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final task = state.selectedTask;

    if (task == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PageHeader(title: 'Tugas', onBack: () => state.setScreen('main')),
        ],
      );
    }

    final roster = state.gradeRoster(task.className, task);
    final bankLen = state.currentQuizBank.length;
    final essayBank = CurriculumData.exercisesFor(
      task.subject,
      state.data.religion,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: task.title,
          sub: '${task.subject} · ${task.className}',
          onBack: () => state.setScreen('main'),
        ),
        ClayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Durasi: ${task.minutes} menit', style: theme.text.itemTitle),
              const SizedBox(height: 4),
              Text(
                task.isFileTask
                    ? 'File tugas: ${task.file?.name ?? "tidak tersedia"}'
                    : 'Soal contoh untuk ${task.subject}',
                style: theme.text.muted,
              ),
              if (!task.isFileTask) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'Metode 1 · Pilihan ganda: $bankLen soal (dinilai otomatis)',
                  style: theme.text.muted,
                ),
                Text(
                  'Metode 2 · Esai: ${essayBank.length} soal (jawaban siswa diperiksa manual)',
                  style: theme.text.muted,
                ),
              ],
              if (task.isFileTask && task.file != null)
                KarsaButton(
                  title: 'Buka file tugas',
                  onTap: () => state.openAttachment(task.file),
                ),
            ],
          ),
        ),
        if (state.error.isNotEmpty)
          Text(
            state.error,
            style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Nilai siswa · ${task.className}',
            style: theme.text.section,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Daftar contoh. Nilai kuis dihitung dari hasil lokal; tanda — berarti belum ada nilai, bukan nol.',
            style: theme.text.muted,
          ),
        ),
        for (final member in roster)
          ListItemCard(
            iconEmoji: '🙂',
            tileColor: const Color(0xFFE4EEF7),
            title: member.name,
            meta: state.gradeNote(task, member) +
                (member.example ? ' · siswa contoh' : ''),
            status: _formatGrade(state.gradeFor(task, member)),
          ),
        if (!task.isFileTask) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Text('Soal esai', style: theme.text.section),
          ),
          ClayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Siswa menjawab esai di perangkatnya. Jawaban tersimpan lokal '
                  'dan tidak dikirim otomatis, jadi guru belum bisa membacanya '
                  'di demo ini.',
                  style: theme.text.smallMuted,
                ),
                for (int i = 0; i < essayBank.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      '${i + 1}. ${essayBank[i].prompt}',
                      style: theme.text.muted,
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (state.isGuru)
          KarsaButton(
            title: 'Rekap nilai per kelas',
            onTap: () => state.openGradeRecap(task.className, 'teacherTask'),
          ),
        KarsaButton(
          title: 'Kembali ke tugas',
          onTap: () => state.changeTab('Tugas'),
        ),
      ],
    );
  }
}
