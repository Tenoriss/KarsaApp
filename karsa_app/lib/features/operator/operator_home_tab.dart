import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../providers/app_state.dart';
import '../../shared/widgets/media_image.dart';

/// Beranda operator sekolah: ringkasan seluruh isi aplikasi dan pintasan
/// ke bagian yang bisa dikelola.
class OperatorHomeTab extends StatelessWidget {
  const OperatorHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    final roster = state.roster;
    final tasks = state.data.tasks;
    final materials = state.data.materials;
    final announcements = state.data.announcements;
    final events = state.data.classEvents;
    final customGrafiss = state.mediaAssets.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PageHeader(
          title: 'Operator Sekolah',
          sub: 'Kelola seluruh isi KARSA',
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 118,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
          ),
          child: MediaImage(
            slotKey: SchoolMedia.teacherBannerSlot,
            fallbackAsset: AppConstants.assetTeacherBanner,
            width: double.infinity,
            height: 118,
            fit: BoxFit.fill,
          ),
        ),
        NoticeCard(
          title: 'Selamat datang, Operator',
          body:
              'Anda mengelola data siswa, kelas, materi, dan aset sekolah. Semua perubahan tersimpan di perangkat ini pada kunci "@karsa-demo-v1".',
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: StatCard(
                icon: KarsaIcons.person,
                label: 'Siswa',
                value: '${roster.length}',
                desc: '${state.activeStudentCount} aktif',
                color: c.rose,
                onTap: () => state.changeTab('Siswa'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: KarsaIcons.people,
                label: 'Kelas',
                value: '${state.schoolClasses.length}',
                desc: 'kelas aktif',
                color: c.blue,
                onTap: () => state.changeTab('Kelas'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: StatCard(
                icon: KarsaIcons.bookOutline,
                label: 'Materi',
                value: '${materials.length}',
                desc: 'semua guru',
                color: c.blue,
                onTap: () => state.changeTab('Materi'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: KarsaIcons.albums,
                label: 'Aset',
                value: '$customGrafiss/3',
                desc: 'grafis aktif',
                color: c.rose,
                onTap: () => state.changeTab('Media'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ListItemCard(
          iconEmoji: '📝',
          tileColor: const Color(0xFFF8EBEC),
          title: 'Tugas sekolah',
          meta: '${tasks.length} tugas aktif lintas kelas',
          status: 'Kelola',
          onTap: () => state.setScreen('operatorTasks'),
        ),
        ListItemCard(
          iconEmoji: '📣',
          tileColor: const Color(0xFFF8EBEC),
          title: 'Pengumuman sekolah',
          meta: '${announcements.length} pengumuman aktif',
          status: 'Kelola',
          onTap: () => state.setScreen('operatorAnnouncements'),
        ),
        ListItemCard(
          iconEmoji: '📅',
          tileColor: const Color(0xFFF8EBEC),
          title: 'Agenda sekolah',
          meta: '${events.length} agenda tersimpan',
          status: 'Kelola',
          onTap: () => state.setScreen('operatorAgenda'),
        ),
        ListItemCard(
          iconEmoji: '📊',
          tileColor: const Color(0xFFF8EBEC),
          title: 'Nilai kelas',
          meta: 'Isi, ubah, dan hapus nilai ringkas siswa',
          status: 'Kelola',
          onTap: () => state.setScreen('operatorGrades'),
        ),
        ListItemCard(
          iconEmoji: '🗂️',
          tileColor: const Color(0xFFF8EBEC),
          title: 'Logo & banner sekolah',
          meta: customGrafiss == 0
              ? 'Masih memakai aset bawaan aplikasi'
              : '$customGrafiss grafis memakai gambar pilihan operator',
          status: 'Ubah',
          onTap: () => state.changeTab('Media'),
        ),
        const SizedBox(height: 4),
        MotionPressable(
          semanticsLabel: 'Ubah data operator',
          onTap: () => state.openSetting('Informasi pribadi'),
          child: Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(vertical: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.line),
            ),
            child: Text(
              'Ubah data operator',
              style: theme.text.itemTitle,
            ),
          ),
        ),
      ],
    );
  }
}
