import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class AgendaDetailPage extends StatelessWidget {
  const AgendaDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final event = state.selectedEvent;

    if (event == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PageHeader(
            title: 'Agenda',
            onBack: () => state.changeTab(state.isWali ? 'Agenda' : 'Beranda'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: event.title,
          sub: '${event.className} · ${event.date}',
          onBack: () => state.changeTab(state.isWali ? 'Agenda' : 'Beranda'),
        ),
        ClayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('📅 ${event.date}', style: theme.text.itemTitle),
              const SizedBox(height: 10),
              Text(
                event.body.isEmpty ? 'Tidak ada catatan tambahan.' : event.body,
                style: theme.text.muted,
              ),
              const SizedBox(height: 10),
              Text(
                'Dibuat oleh ${event.teacher}',
                style: theme.text.smallMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
