import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class StudentDetailPage extends StatelessWidget {
  const StudentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final sel = state.selectedStudentDetail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: sel?.title ?? 'Siswa',
          sub: 'Profil siswa',
          onBack: () => state.setScreen('students'),
        ),
        ClayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Perkembangan belajar', style: theme.text.itemTitle),
              const SizedBox(height: 6),
              Text(sel?.body ?? 'Data siswa contoh.', style: theme.text.muted),
            ],
          ),
        ),
      ],
    );
  }
}
