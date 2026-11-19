import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/method_card.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

class PracticeDetailSheet extends StatelessWidget {
  const PracticeDetailSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final practice = state.selectedPractice;

    if (practice == null) return const SizedBox.shrink();

    final meta = CurriculumData.metaFor(practice.subject);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: practice.title,
          sub: '${practice.subject} · ${practice.className ?? "Latihan"}',
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
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 10),
          child: Text('Pilih metode latihan', style: theme.text.section),
        ),
        // Dua metode seperti tugas: pilihan ganda (dinilai) dan esai
        // (tidak dinilai otomatis). Siswa boleh mengerjakan keduanya.
        MethodCard(
          icon: '🔠',
          title: 'Pilihan ganda',
          meta: '${CurriculumData.questionsFor(practice.subject, state.religion).length} soal · dinilai otomatis',
          badge: state.selectedPracticeResult?.score != null
              ? 'Nilai ${state.selectedPracticeResult!.score}/${state.selectedPracticeResult!.total}'
              : null,
          actionLabel: state.selectedPracticeResult?.score != null
              ? 'Kerjakan lagi'
              : 'Mulai',
          onTap: state.startPracticeQuiz,
        ),
        const SizedBox(height: 10),
        MethodCard(
          icon: '✍️',
          title: 'Esai',
          meta: '${CurriculumData.exercisesFor(practice.subject, state.religion).length} soal · tidak dinilai otomatis',
          badge: state.data.practiceDone[practice.id] == true ? 'Selesai' : null,
          actionLabel: 'Mulai',
          onTap: state.startPractice,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Kamu boleh mengerjakan salah satu atau keduanya. '
            'Esai tidak dinilai otomatis; pilihan ganda langsung dapat nilai.',
            style: theme.text.smallMuted,
          ),
        ),
      ],
    );
  }
}
