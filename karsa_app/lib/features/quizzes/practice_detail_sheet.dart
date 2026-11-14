import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
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
        Text('Belajar dengan santai ✨', style: theme.text.section),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            '5 soal esai. Tulis jawabanmu, lalu bandingkan dengan contoh. Latihan tidak dinilai; status selesai tercatat lokal.',
            style: theme.text.muted.copyWith(height: 23 / 13),
          ),
        ),
        KarsaButton(
          title: 'Mulai latihan',
          onTap: state.startPractice,
        ),
      ],
    );
  }
}
