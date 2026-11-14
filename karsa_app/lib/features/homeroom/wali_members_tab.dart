import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class WaliMembersTab extends StatelessWidget {
  const WaliMembersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final members = state.classMembers;
    final scores = state.data.classScores;
    final todayAtt = state.todayAttendance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Anggota Kelas',
          sub: '${AppConstants.waliClass} · ${members.length} siswa contoh',
        ),
        Text(
          'Ketuk nama siswa untuk melihat dan mengisi nilai ringkas.',
          style: theme.text.muted,
        ),
        const SizedBox(height: 12),
        for (final m in members)
          Builder(
            builder: (context) {
              final s = scores[m.id];
              final scoreLabel = s == null
                  ? 'Nilai belum diisi'
                  : 'Nilai ringkas ${s == s.roundToDouble() ? s.toInt() : s} · data lokal';
              return ListItemCard(
                iconEmoji: m.icon,
                tileColor: const Color(0xFFF8EBEC),
                title: m.name,
                meta: scoreLabel,
                status: todayAtt[m.id] ?? 'Belum absen',
                onTap: () => state.editMember(m),
              );
            },
          ),
        KarsaButton(
          title: 'Isi kehadiran',
          onTap: () => state.openWaliRecapShortcut(
            tabName: 'Kehadiran',
            resetToToday: true,
          ),
        ),
      ],
    );
  }
}
