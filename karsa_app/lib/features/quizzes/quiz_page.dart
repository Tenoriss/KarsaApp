import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/dark_color_mapper.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  static const List<String> _letters = <String>['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final task = state.selectedTask;
    final bank = state.currentQuizBank;

    if (task == null || bank.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PageHeader(title: 'Kuis', onBack: () => state.setScreen('main')),
        ],
      );
    }

    final qIdx = state.questionIndex.clamp(0, bank.length - 1);
    final item = bank[qIdx];
    final choice = state.choiceIndex;
    final checked = state.checked;
    final ratio = (qIdx + 1) / bank.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: '${task.subject} · ${task.title}',
          sub: 'Soal ${qIdx + 1} dari ${bank.length}',
          onBack: () => state.setScreen('taskDetail'),
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
          child: Text(item.question, style: theme.text.question),
        ),
        for (int i = 0; i < item.choices.length; i++)
          Builder(
            builder: (context) {
              final isSelected = choice == i;
              final isCorrectChoice = checked && i == item.answerIndex;
              final isWrongSelected = checked && isSelected && i != item.answerIndex;

              Color bgColor = Colors.white;
              Color borderColor = Colors.white;
              if (isCorrectChoice) {
                bgColor = const Color(0xFFEDF8F1);
                borderColor = const Color(0xFF7CBA99);
              } else if (isSelected) {
                bgColor = const Color(0xFFFFF2F4);
                borderColor = c.rose;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MotionPressable(
                  onTap: checked ? null : () => state.selectQuizChoice(i),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: ClayStyles.soft(
                      color: bgColor,
                      isDark: c.isDark,
                      radius: 19,
                      borderColor: borderColor,
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: DarkColorMapper.surface(
                              const Color(0xFFF4EFED),
                              isDark: c.isDark,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _letters[i % _letters.length],
                            style: TextStyle(
                              color: c.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(item.choices[i], style: theme.text.itemTitle),
                        ),
                        if (isCorrectChoice)
                          const Text(
                            'Benar ✓',
                            style: TextStyle(
                              color: Color(0xFF408C67),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          )
                        else if (isWrongSelected)
                          const Text(
                            'Salah ×',
                            style: TextStyle(
                              color: Color(0xFFB93643),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          )
                        else if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: DarkColorMapper.surface(
                                const Color(0xFFF9E8ED),
                                isDark: c.isDark,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('Dipilih ✓', style: theme.text.badge),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        NoticeCard(
          title: checked
              ? (choice == item.answerIndex
                  ? '✓ Tepat!'
                  : 'Belum tepat. Tetap semangat!')
              : '💡 Petunjuk',
          body: checked
              ? '${item.explanation} Jawaban benar: ${item.choices[item.answerIndex]}.'
              : (choice == null
                  ? 'Pilih satu jawaban dulu.'
                  : 'Pilihanmu: ${item.choices[choice]}. Sudah yakin?'),
        ),
        KarsaButton(
          title: checked
              ? (qIdx == bank.length - 1 ? 'Lihat hasil' : 'Soal berikutnya')
              : 'Periksa jawaban',
          disabled: choice == null,
          onTap: state.checkOrAdvanceQuiz,
        ),
      ],
    );
  }
}
