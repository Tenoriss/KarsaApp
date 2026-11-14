import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final items = state.visibleAnnouncements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Pengumuman',
          sub: 'Info penting untuk keluarga',
          onBack: () => state.setScreen('main'),
        ),
        if (state.isTeacher)
          KarsaButton(
            title: '+ Buat pengumuman',
            onTap: () => state.openForm('announcementForm'),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Ikuti kabar terbaru dan agenda kegiatan sekolah.',
            style: theme.text.muted,
          ),
        ),
        for (final a in items)
          ClayCard(
            padding: const EdgeInsets.all(20),
            onTap: () => state.openAnnouncement(a),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${a.category}${!state.data.readAnnouncements.contains(a.id) ? " · BARU" : ""}',
                  style: theme.text.overline,
                ),
                const SizedBox(height: 6),
                Text(a.title, style: theme.text.section),
                if (a.detail.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(a.detail, style: theme.text.link),
                ],
                const SizedBox(height: 8),
                Text(
                  a.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.text.muted.copyWith(height: 21 / 13),
                ),
                const SizedBox(height: 12),
                Text('Baca detail ›', style: theme.text.link),
              ],
            ),
          ),
      ],
    );
  }
}
