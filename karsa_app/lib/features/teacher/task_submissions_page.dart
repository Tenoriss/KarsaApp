import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../models/submission_row.dart';
import '../../providers/app_state.dart';

/// Rekap pengumpulan satu tugas untuk guru.
///
/// Guru tidak mengerjakan tugas, jadi notifikasi pengumpulan membuka layar ini:
/// siapa saja yang sudah mengumpulkan dan berapa nilainya.
class TaskSubmissionsPage extends StatelessWidget {
  const TaskSubmissionsPage({super.key});

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
          PageHeader(
            title: 'Pengumpulan',
            onBack: () => state.setScreen('main'),
          ),
        ],
      );
    }

    final rows = state.submissionsFor(task);
    final done = rows.where((r) => r.submitted).toList();
    final average = state.averageSubmissionScore(task);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Pengumpulan tugas',
          sub: '${task.subject} · ${task.className}',
          onBack: () => state.setScreen('main'),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: _SummaryTile(
                label: 'Sudah kumpul',
                value: '${done.length}',
                desc: 'dari ${rows.length} siswa',
                accent: c.rose,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryTile(
                label: 'Rata-rata',
                value: average == null
                    ? '—'
                    : (average == average.roundToDouble()
                        ? '${average.toInt()}'
                        : average.toStringAsFixed(1)),
                desc: average == null ? 'belum ada nilai' : 'dari 10',
                accent: c.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (rows.isEmpty)
          NoticeCard(
            title: 'Belum ada siswa',
            body: 'Kelas ini belum punya daftar siswa.',
          ),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListItemCard(
              iconEmoji: row.submitted ? '✅' : '⏳',
              tileColor: row.submitted
                  ? const Color(0xFFD1F4D8)
                  : const Color(0xFFF8EBEC),
              title: row.name,
              meta: row.submitted
                  ? '${row.className} · Nilai ${row.scoreLabel}'
                      '${row.hasEssay ? " · esai terkirim" : ""}'
                  : '${row.className} · Belum mengumpulkan',
              status: row.status,
              onTap: row.submitted
                  ? () => _openDetail(context, row, task.subject)
                  : null,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            'Nilai pilihan ganda dihitung otomatis. Esai tidak dinilai '
            'otomatis sehingga tidak mengubah angka di atas.',
            style: theme.text.smallMuted,
          ),
        ),
      ],
    );
  }

  void _openDetail(BuildContext context, SubmissionRow row, String subject) {
    final theme = KarsaThemeScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(18),
        decoration: ClayStyles.soft(
          color: theme.colors.card,
          isDark: theme.colors.isDark,
          radius: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(row.name, style: theme.text.section),
            const SizedBox(height: 2),
            Text('$subject · ${row.className}', style: theme.text.smallMuted),
            const SizedBox(height: 12),
            Text('Nilai pilihan ganda', style: theme.text.overline),
            Text(
              row.scoreLabel,
              style: TextStyle(
                color: theme.colors.ink,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Text('Jawaban esai', style: theme.text.section),
            const SizedBox(height: 6),
            if (row.hasEssay)
              for (int i = 0; i < row.essayAnswers.length; i++)
                if (row.essayAnswers[i].trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Soal ${i + 1}: ${row.essayAnswers[i]}',
                      style: theme.text.muted,
                    ),
                  )
            else
              Text(
                'Siswa belum mengirim jawaban esai untuk tugas ini.',
                style: theme.text.muted,
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final String desc;
  final Color accent;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.desc,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ClayStyles.soft(
        color: theme.colors.card,
        isDark: theme.colors.isDark,
        radius: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: theme.text.smallMuted),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(desc, style: theme.text.smallMuted),
        ],
      ),
    );
  }
}
