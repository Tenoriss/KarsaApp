import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final list = state.relevantNotifications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Notifikasi',
          sub: 'Pembaruan pembelajaran di perangkat ini',
          onBack: () => state.setScreen('main'),
        ),
        if (state.notice.isNotEmpty) NoticeCard(body: state.notice),
        for (final n in list)
          ListItemCard(
            iconEmoji: n.target == 'teachers'
                ? '✅'
                : (n.kind == 'material' ? '📚' : '📝'),
            tileColor: const Color(0xFFF8EBEC),
            title: n.title,
            meta:
                '${n.subject} · ${n.className} · ${KarsaDateUtils.formatCreatedAtId(n.createdAt)}',
            status: state.isNotificationRead(n.id) ? 'Dibaca' : 'Baru',
            onTap: () => state.markNotification(n),
          ),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 35, bottom: 20),
            child: Text(
              'Belum ada pemberitahuan baru.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted),
            ),
          ),
        KarsaButton(
          title: 'Pengumuman sekolah (${state.unreadAnnouncementsCount})',
          onTap: () => state.setScreen('announcements'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Text(
            'Notifikasi demo hanya muncul pada perangkat/browser yang sama, bukan push notification.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
