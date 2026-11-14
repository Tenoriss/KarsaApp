import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class AnnouncementDetailPage extends StatelessWidget {
  const AnnouncementDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final a = state.selectedAnnouncement;

    if (a == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PageHeader(
            title: 'Pengumuman',
            onBack: () => state.setScreen('announcements'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: a.title,
          sub: a.category,
          onBack: () => state.setScreen('announcements'),
        ),
        if (a.detail.isNotEmpty) Text(a.detail, style: theme.text.link),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            a.body,
            style: theme.text.muted.copyWith(fontSize: 15, height: 25 / 15),
          ),
        ),
        Text('Untuk: ${a.className}', style: theme.text.smallMuted),
        KarsaButton(
          title: 'Kembali ke pengumuman',
          onTap: () => state.setScreen('announcements'),
        ),
      ],
    );
  }
}
