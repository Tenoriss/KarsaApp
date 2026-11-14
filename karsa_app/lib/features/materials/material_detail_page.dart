import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class MaterialDetailPage extends StatelessWidget {
  const MaterialDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final m = state.selectedMaterial;

    if (m == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PageHeader(
            title: 'Materi',
            onBack: () => state.setScreen('materials'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: m.title,
          sub: '${m.subject} · ${m.className} · ${m.teacher}',
          onBack: () => state.setScreen('materials'),
        ),
        if (m.file != null)
          ClayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('📎 ${m.file!.name}', style: theme.text.itemTitle),
                const SizedBox(height: 2),
                Text('File materi lokal', style: theme.text.smallMuted),
                KarsaButton(
                  title: 'Buka file materi',
                  onTap: () => state.openAttachment(m.file),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('Ringkasan materi', style: theme.text.section),
        ),
        ClayCard(
          child: Text(
            m.summary.isEmpty ? 'Belum ada ringkasan.' : m.summary,
            style: theme.text.muted.copyWith(height: 23 / 13),
          ),
        ),
        if (state.error.isNotEmpty)
          Text(
            state.error,
            style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Text(
            'Ringkasan dipilih atau ditulis oleh guru, bukan AI otomatis.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
