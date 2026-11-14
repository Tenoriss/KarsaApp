import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

class PracticeListTab extends StatelessWidget {
  const PracticeListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final practices = state.visiblePractices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Latihan',
          sub: '${state.donePracticeCount} dari ${practices.length} selesai · soal esai',
        ),
        for (final p in practices)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '${CurriculumData.metaFor(p.subject).icon} ${p.subject.toUpperCase()}',
                  style: theme.text.overline,
                ),
              ),
              ListItemCard(
                iconEmoji: CurriculumData.metaFor(p.subject).icon,
                tileColor: CurriculumData.metaFor(p.subject).color,
                title: p.title,
                meta: '5 soal esai · tanpa batas waktu',
                status:
                    state.data.practiceDone[p.id] == true ? 'Selesai' : 'Kerjakan',
                onTap: () => state.openPractice(p),
              ),
            ],
          ),
      ],
    );
  }
}
