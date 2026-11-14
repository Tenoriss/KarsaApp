import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

class PracticePreviewPage extends StatelessWidget {
  const PracticePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final practice = state.selectedPractice;

    if (practice == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PageHeader(
            title: 'Latihan',
            onBack: () => state.setScreen(state.returnScreen),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: practice.title,
          sub: '${practice.subject} · ${practice.className ?? "Semua kelas"}',
          onBack: () => state.setScreen(state.returnScreen),
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
          child: Text(
            CurriculumData.metaFor(practice.subject).icon,
            style: const TextStyle(fontSize: 48),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('Latihan esai', style: theme.text.section),
        ),
        Text(
          '5 soal contoh sesuai mata pelajaran. Latihan dipakai untuk belajar dan tidak dinilai.',
          style: theme.text.muted,
        ),
        KarsaButton(
          title: 'Lihat latihan',
          onTap: state.startPractice,
        ),
      ],
    );
  }
}
