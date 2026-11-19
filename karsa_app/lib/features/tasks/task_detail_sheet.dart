import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

class TaskDetailSheet extends StatelessWidget {
  const TaskDetailSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final task = state.selectedTask;

    if (task == null) return const SizedBox.shrink();

    final result = state.data.results[task.id];
    final meta = CurriculumData.metaFor(task.subject);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: task.title,
          sub: '${task.subject} · ${task.className}',
          onBack: () => state.setScreen('main'),
        ),
        Container(
          height: 150,
          margin: const EdgeInsets.only(bottom: 25),
          decoration: ClayStyles.soft(
            color: const Color(0xFFF9E9EB),
            isDark: c.isDark,
            radius: 24,
          ),
          alignment: Alignment.center,
          child: Text(meta.icon, style: const TextStyle(fontSize: 48)),
        ),
        Text('Siap mengerjakan tugas?', style: theme.text.section),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            task.isFileTask
                ? 'Buka file tugas. Setelah mengerjakan, tandai selesai di perangkat ini. Jawaban tidak dikirim otomatis.'
                : task.questionsFromAssistant
                    ? '${task.questions.length} soal pilihan ganda disusun asisten dari bahan yang diunggah guru (simulasi offline, bukan AI sungguhan). Pilih jawaban lalu lihat hasil setelah selesai.'
                    : '10 soal pilihan ganda. Pilih jawaban lalu lihat hasil setelah selesai. Waktu hanya informasi dalam demo.',
            style: theme.text.muted.copyWith(height: 23 / 13),
          ),
        ),
        if (result?.demo == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Ini adalah riwayat contoh, bukan nilai siswa sebenarnya.',
              style: theme.text.smallMuted,
            ),
          ),
        if (result != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              result.submittedOnly
                  ? 'Tugas ditandai selesai'
                  : 'Hasil terakhir: ${result.score} / ${result.total}',
              style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
            ),
          ),
        ClayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Tenggat: ${KarsaDateUtils.formatDueLabel(task.dueAt)}',
                style: theme.text.itemTitle,
              ),
              const SizedBox(height: 2),
              Text(
                '${KarsaDateUtils.deadlineCountdown(task.dueAt, state.now)} · tugas tidak dikunci otomatis',
                style: theme.text.smallMuted,
              ),
            ],
          ),
        ),
        if (task.isFileTask) ...<Widget>[
          KarsaButton(
            title: 'Buka file tugas',
            onTap: () => state.openAttachment(task.file),
          ),
          if (result == null)
            KarsaButton(
              title: 'Tandai sudah dikerjakan',
              onTap: state.submitFileTask,
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Penanda ini tidak mengirim jawaban atau membuktikan pengumpulan.',
              style: theme.text.smallMuted,
            ),
          ),
        ] else ...<Widget>[
          // Dua metode pengerjaan, seperti rancangan: pilihan ganda dan esai.
          // Siswa boleh mengerjakan keduanya; keduanya tersimpan per tugas.
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 10),
            child: Text('Pilih metode pengerjaan', style: theme.text.section),
          ),
          _MethodCard(
            icon: '🔠',
            title: 'Pilihan ganda',
            meta: '${state.currentQuizBank.length} soal · dinilai otomatis',
            badge: result?.score != null
                ? 'Nilai ${result!.score}/${result.total}'
                : null,
            actionLabel: result?.score != null ? 'Kerjakan lagi' : 'Mulai',
            onTap: state.startQuiz,
          ),
          const SizedBox(height: 10),
          _MethodCard(
            icon: '✍️',
            title: 'Esai',
            meta: '${state.currentEssayBank.length} soal · jawabanmu disimpan',
            badge: state.taskEssayDone ? 'Sudah dikirim' : null,
            actionLabel: state.taskEssayDone ? 'Lihat jawaban' : 'Mulai',
            onTap: state.startTaskEssay,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              state.taskEssayDone
                  ? 'Kedua metode sudah dikerjakan. Kamu bisa mengulanginya kapan saja.'
                  : 'Kamu boleh mengerjakan salah satu atau keduanya. Esai tidak dinilai otomatis.',
              style: theme.text.smallMuted,
            ),
          ),
        ],
        if (state.error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.error,
              style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }
}

/// Kartu pemilih metode pengerjaan pada detail tugas: pilihan ganda atau esai.
/// Sengaja memakai tampilan yang sama agar kedua metode setara, bukan salah
/// satu terlihat sebagai opsi tambahan.
class _MethodCard extends StatelessWidget {
  final String icon;
  final String title;
  final String meta;
  final String? badge;
  final String actionLabel;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.title,
    required this.meta,
    required this.actionLabel,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    return MotionPressable(
      semanticsLabel: '$title, $actionLabel',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: ClayStyles.soft(
          color: c.card,
          isDark: c.isDark,
          radius: 18,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: ClayStyles.raised(
                color: c.rose,
                isDark: c.isDark,
                radius: 21,
              ),
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(title, style: theme.text.itemTitle),
                      if (badge != null) ...<Widget>[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            badge!,
                            style: TextStyle(
                              color: c.rose,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(meta, style: theme.text.smallMuted),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              actionLabel,
              style: TextStyle(
                color: c.rose,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            Icon(KarsaIcons.chevronForward, size: 16, color: c.rose),
          ],
        ),
      ),
    );
  }
}
