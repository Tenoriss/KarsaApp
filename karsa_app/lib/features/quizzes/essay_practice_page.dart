import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/dark_color_mapper.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class EssayPracticePage extends StatelessWidget {
  const EssayPracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final practice = state.selectedPractice;
    final bank = state.currentEssayBank;

    if (practice == null || bank.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PageHeader(title: 'Latihan', onBack: () => state.setScreen('main')),
        ],
      );
    }

    final idx = state.questionIndex.clamp(0, bank.length - 1);
    final pair = bank[idx];
    final ratio = (idx + 1) / bank.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: '${practice.subject} · Latihan',
          sub: 'Soal ${idx + 1} dari ${bank.length} · tanpa batas waktu',
          onBack: () => state.setScreen(
            state.isTeacher ? 'practicePreview' : 'practiceDetail',
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 7,
            color: DarkColorMapper.surface(
              const Color(0xFFF1E4E1),
              isDark: c.isDark,
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: ratio,
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  color: c.rose,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Text(pair.prompt, style: theme.text.question),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Jawabanmu', style: theme.text.label),
        ),
        KarsaInput(
          value: state.essay,
          onChanged: state.updateEssay,
          placeholder: 'Tulis jawabanmu di sini...',
          multiline: true,
          minHeight: 140,
        ),
        if (state.showExample)
          NoticeCard(
            title: '💡 Contoh jawaban',
            body: pair.sampleAnswer,
          ),
        KarsaButton(
          title: state.showExample
              ? (idx == bank.length - 1 ? 'Selesai latihan' : 'Soal berikutnya')
              : 'Lihat contoh jawaban',
          disabled: state.essay.trim().isEmpty,
          onTap: state.checkOrAdvanceEssay,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Text(
            'Latihan ini tidak dinilai; status selesai tercatat di perangkat ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
