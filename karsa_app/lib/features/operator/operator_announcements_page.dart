import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

/// Daftar seluruh pengumuman sekolah. Operator sekolah bisa menambah,
/// mengubah, dan menghapus pengumuman milik role lain.
class OperatorAnnouncementsPage extends StatelessWidget {
  const OperatorAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);

    final filter = state.filter == 'Semua kelas' ? 'Semua kelas' : state.filter;
    final all = state.data.announcements;
    final items = filter == 'Semua kelas'
        ? all
        : all
            .where(
              (a) => a.className == filter || a.className == 'Semua kelas',
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Pengumuman Sekolah',
          sub: '${all.length} pengumuman aktif',
          onBack: () => state.setScreen('main'),
        ),
        KarsaChips(
          options: <String>['Semua kelas', ...state.operatorClassOptions],
          value: filter,
          onChanged: state.setFilter,
        ),
        const SizedBox(height: 6),
        if (items.isEmpty)
          const NoticeCard(body: 'Belum ada pengumuman untuk kelas ini.')
        else
          for (final announcement in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ListItemCard(
                    iconEmoji: '📣',
                    tileColor: const Color(0xFFF8EBEC),
                    title: announcement.title,
                    meta: '${announcement.className} · ${announcement.body}',
                    status: 'Ubah',
                    onTap: () => state.openOperatorAnnouncementForm(announcement.id),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () =>
                            state.openOperatorAnnouncementForm(announcement.id),
                        child: Text('Ubah', style: theme.text.link),
                      ),
                      TextButton(
                        onPressed: () =>
                            state.deleteAnnouncement(announcement.id),
                        child: Text('Hapus', style: theme.text.link),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        KarsaButton(
          title: '+ Tambah pengumuman',
          onTap: () => state.openOperatorAnnouncementForm(),
        ),
        Text(
          'Pengumuman sekolah muncul di beranda siswa, orang tua, dan guru.',
          style: theme.text.smallMuted,
        ),
      ],
    );
  }
}

/// Form tambah / ubah pengumuman sekolah.
class OperatorAnnouncementFormPage extends StatelessWidget {
  const OperatorAnnouncementFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final isEdit = state.draftAnnouncementId.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: isEdit ? 'Ubah Pengumuman' : 'Buat Pengumuman',
          sub: 'Tersimpan di perangkat ini',
          onBack: () => state.setScreen('operatorAnnouncements'),
        ),
        Text('Judul', style: theme.text.label),
        KarsaInput(
          value: state.draftTitle,
          onChanged: state.setDraftTitle,
          placeholder: 'Mis. Libur sekolah',
          semanticsLabel: 'Judul pengumuman',
        ),
        Text('Isi pengumuman', style: theme.text.label),
        KarsaInput(
          value: state.draftBody,
          onChanged: state.setDraftBody,
          placeholder: 'Tulis pengumuman...',
          multiline: true,
          minHeight: 120,
          semanticsLabel: 'Isi pengumuman',
        ),
        Text('Untuk kelas', style: theme.text.label),
        KarsaChips(
          options: <String>['Semua kelas', ...state.operatorClassOptions],
          value: state.draftClass,
          onChanged: state.setDraftClass,
        ),
        if (state.error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              state.error,
              style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
            ),
          ),
        KarsaButton(
          title: 'Simpan pengumuman',
          onTap: state.saveOperatorAnnouncement,
        ),
        if (isEdit)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                state.deleteAnnouncement(state.draftAnnouncementId);
                state.setScreen('operatorAnnouncements');
              },
              child: Text('Hapus pengumuman ini', style: theme.text.link),
            ),
          ),
      ],
    );
  }
}
