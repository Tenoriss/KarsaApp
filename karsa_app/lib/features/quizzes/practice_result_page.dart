import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class PracticeResultPage extends StatelessWidget {
  const PracticeResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final practice = state.selectedPractice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Latihan selesai!',
          sub: practice?.title ?? 'Latihan',
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
              const Text('🌱', style: TextStyle(fontSize: 55)),
              const SizedBox(height: 12),
              Text('Hebat, kamu sudah berlatih!', style: theme.text.section),
              const SizedBox(height: 8),
              Text(
                'Terus belajar sedikit demi sedikit, ya.',
                style: theme.text.muted,
              ),
            ],
          ),
        ),
        KarsaButton(
          title: state.isTeacher
              ? 'Kembali ke mata pelajaran'
              : 'Kembali ke latihan',
          onTap: () {
            if (state.isTeacher) {
              state.setScreen('subject');
            } else {
              state.changeTab(state.isStudent ? 'Tugas' : 'Latihan');
            }
          },
        ),
      ],
    );
  }
}
