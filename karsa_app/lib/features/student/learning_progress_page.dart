import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../providers/app_state.dart';

class LearningProgressPage extends StatelessWidget {
  const LearningProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final totalStars = state.data.results.length + state.donePracticeCount;
    final mood = state.data.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Perjalanan belajar',
          sub: '${state.data.studentName} · ${state.data.childClass}',
          onBack: () => state.setScreen('main'),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(24),
          decoration: ClayStyles.soft(
            color: const Color(0xFFF9EDF0),
            isDark: c.isDark,
            radius: 22,
          ),
          child: Column(
            children: <Widget>[
              const Text('🌟', style: TextStyle(fontSize: 44)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '$totalStars bintang belajar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: c.ink,
                  ),
                ),
              ),
              Text(
                'Satu bintang untuk setiap tugas atau latihan yang selesai. Hebat!',
                textAlign: TextAlign.center,
                style: theme.text.muted,
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: StatCard(
                icon: KarsaIcons.checkmarkCircle,
                label: 'Tugas selesai',
                value: '${state.data.results.length}',
                desc: 'Terus semangat',
                color: c.blue,
                onTap: state.openHistoryShortcut,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: KarsaIcons.grid,
                label: 'Latihan selesai',
                value: '${state.donePracticeCount}',
                desc: 'Ayo berlatih',
                color: c.pink,
                onTap: () => state.changeTab('Latihan'),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 10),
          child: Text('Bagaimana perasaanmu hari ini?', style: theme.text.section),
        ),
        Text(
          'Pilih satu untuk bercerita. Jawaban hanya tersimpan di perangkat ini.',
          style: theme.text.muted,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 10),
          child: Row(
            children: <Widget>[
              for (int i = 0; i < AppConstants.moodOptions.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final emoji = AppConstants.moodOptions[i][0];
                      final label = AppConstants.moodOptions[i][1];
                      final selected = mood == label;
                      return MotionPressable(
                        semanticsLabel: label,
                        onTap: () => state.setMood(label),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: ClayStyles.soft(
                            color: selected
                                ? const Color(0xFFFBEAEC)
                                : Colors.white,
                            isDark: c.isDark,
                            radius: 16,
                            borderColor: selected ? c.rose : c.line,
                            borderWidth: 1,
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(emoji, style: const TextStyle(fontSize: 27)),
                              const SizedBox(height: 4),
                              Text(label, style: theme.text.smallMuted),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        if (mood != null && mood.isNotEmpty)
          NoticeCard(
            title: 'Terima kasih sudah bercerita 💗',
            body: (mood == 'Sedih' || mood == 'Lelah')
                ? 'Tidak apa-apa beristirahat dan bercerita kepada orang dewasa yang kamu percaya.'
                : 'Semoga harimu menyenangkan. Yuk, belajar bersama!',
          ),
        KarsaButton(
          title: 'Mulai latihan',
          onTap: () => state.changeTab('Latihan'),
        ),
      ],
    );
  }
}
