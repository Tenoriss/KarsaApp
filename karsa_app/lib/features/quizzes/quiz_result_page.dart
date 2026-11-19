import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class QuizResultPage extends StatelessWidget {
  const QuizResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final task = state.selectedTask;
    final result = task != null ? state.data.results[task.id] : null;
    final bank = state.currentQuizBank;

    if (task == null || result == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PageHeader(title: 'Hasil kuis', onBack: () => state.setScreen('main')),
        ],
      );
    }

    final total = result.total ?? bank.length;
    final essayBank = state.currentEssayBank;
    final essayAnswers = result.essayAnswers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Hasil kuis',
          sub:
              '${task.subject} · ${task.title}${result.demo ? " · Contoh" : ""}',
          onBack: () => state.setScreen('main'),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(45),
          decoration: ClayStyles.soft(
            color: const Color(0xFFFFFDFB),
            isDark: c.isDark,
            radius: 26,
          ),
          child: Column(
            children: <Widget>[
              const Text('🌟', style: TextStyle(fontSize: 45)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  '${result.score ?? 0} / $total',
                  style: theme.text.resultNumber,
                ),
              ),
              Text('Bagus! Terus berlatih ya.', style: theme.text.section),
            ],
          ),
        ),
        if (total != bank.length)
          Text(
            'Rincian soal lama tidak tersedia setelah pembaruan bank soal; nilai tetap tersimpan.',
            style: theme.text.smallMuted,
          )
        else
          for (int i = 0; i < total; i++)
            ClayCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${(i < result.answers.length && result.answers[i] == bank[i].answerIndex) ? "✓" : "✕"} ${i + 1}. ${bank[i].question}',
                    style: theme.text.itemTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jawaban benar: ${bank[i].choices[bank[i].answerIndex]}',
                    style: theme.text.smallMuted,
                  ),
                ],
              ),
            ),
        if (essayAnswers.any((a) => a.trim().isNotEmpty)) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text('Jawaban esai', style: theme.text.section),
          ),
          ClayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Esai tidak dinilai otomatis. Berikut jawaban yang kamu kirim; '
                  'guru dapat memeriksanya.',
                  style: theme.text.smallMuted,
                ),
                for (int i = 0; i < essayAnswers.length; i++)
                  if (essayAnswers[i].trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${i + 1}. '
                            '${i < essayBank.length ? essayBank[i].prompt : 'Soal esai'}',
                            style: theme.text.itemTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(essayAnswers[i], style: theme.text.muted),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Text(
            'Hasil tersimpan di perangkat ini, belum dikirim ke guru.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted, fontSize: 12),
          ),
        ),
        KarsaButton(
          title: 'Kembali ke tugas',
          onTap: state.openHistoryShortcut,
        ),
      ],
    );
  }
}
