import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/dark_color_mapper.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/stat_card.dart';
import '../../models/class_event.dart';
import '../../models/media_asset.dart';
import '../../models/operator_profile.dart';
import '../../providers/app_state.dart';
import 'operator_collapsible_card.dart';

/// Beranda operator sekolah: ringkasan seluruh isi aplikasi, pintasan yang
/// bisa dilipat, dan section profil operator.
///
/// Tata letak ini menggantikan versi sebelumnya yang memakai banner
/// "Semangat mengajar!" (banner siswa/guru, tidak relevan untuk operator) dan
/// menumpuk lima kartu pintasan berukuran penuh. Sekarang:
/// 1. sapaan singkat langsung di bawah judul layar,
/// 2. empat statistik ringkas,
/// 3. lima pintasan yang **bisa dilipat sendiri-sendiri**,
/// 4. section profil operator lengkap (read-only) dengan tombol Ubah.
class OperatorHomeTab extends StatefulWidget {
  const OperatorHomeTab({super.key});

  @override
  State<OperatorHomeTab> createState() => _OperatorHomeTabState();
}

class _OperatorHomeTabState extends State<OperatorHomeTab> {
  /// Kunci kartu yang sedang terbuka. Kosong = semua terlipat, sehingga
  /// beranda operator tampil ringkas saat pertama dibuka.
  final Set<String> _open = <String>{};  // dibuat di sini, bukan lewat ctor

  void _toggle(String key) {
    setState(() {
      if (!_open.remove(key)) _open.add(key);
    });
  }

  /// Judul tiga pengumuman terbaru untuk rincian kartu pengumuman.
  List<String> _announcementDetails(AppState state) {
    final items = state.data.announcements;
    if (items.isEmpty) return const <String>['Belum ada pengumuman tersimpan.'];
    return items
        .take(3)
        .map((a) => a.title.isEmpty ? a.body : a.title)
        .toList();
  }

  /// Judul tiga agenda terdekat, diurutkan berdasarkan tanggal.
  List<String> _eventDetails(AppState state) {
    final events = List<ClassEvent>.of(state.data.classEvents)
      ..sort((a, b) => a.date.compareTo(b.date));
    if (events.isEmpty) return const <String>['Belum ada agenda tersimpan.'];
    return events
        .take(3)
        .map((e) => '${e.title} · ${KarsaDateUtils.formatDayMonthYearFromKey(e.date)}')
        .toList();
  }

  /// Ringkasan mapel dan kelas dari tugas aktif.
  List<String> _taskDetails(AppState state) {
    final tasks = state.data.tasks;
    if (tasks.isEmpty) return const <String>['Belum ada tugas tersimpan.'];
    final subjects = <String>[];
    for (final t in tasks) {
      if (!subjects.contains(t.subject)) subjects.add(t.subject);
    }
    final classes = <String>[];
    for (final t in tasks) {
      if (!classes.contains(t.className)) classes.add(t.className);
    }
    return <String>[
      '${subjects.length} mata pelajaran · ${classes.length} kelas',
      if (subjects.isNotEmpty) subjects.take(4).join(', '),
    ];
  }

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
    final customGraphics = state.mediaAssets.length;
    final profile = state.operatorProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Operator Sekolah',
          sub: 'Kelola seluruh isi KARSA',
          // Beranda operator tidak memakai GreetingHeader, jadi tombol mode
          // gelap dipasang di sini seperti role lain.
          trailing: RoundIconButton(
            icon: c.isDark ? KarsaIcons.sunnyOutline : KarsaIcons.moonOutline,
            semanticsLabel:
                c.isDark ? 'Aktifkan mode terang' : 'Aktifkan mode gelap',
            onTap: state.toggleDarkMode,
          ),
        ),
        _OperatorWelcomeLine(name: profile.name, theme: theme),
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
                value: '$customGraphics/3',
                desc: 'grafis aktif',
                color: c.rose,
                onTap: () => state.changeTab('Media'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('Kelola sekolah', style: theme.text.section),
        ),
        OperatorCollapsibleCard(
          iconEmoji: '📝',
          title: 'Tugas sekolah',
          meta: '${tasks.length} tugas aktif lintas kelas',
          status: 'Kelola',
          details: _taskDetails(state),
          expanded: _open.contains('tasks'),
          onToggle: () => _toggle('tasks'),
          onManage: () => state.setScreen('operatorTasks'),
        ),
        OperatorCollapsibleCard(
          iconEmoji: '📣',
          title: 'Pengumuman sekolah',
          meta: '${announcements.length} pengumuman aktif',
          status: 'Kelola',
          details: _announcementDetails(state),
          expanded: _open.contains('announcements'),
          onToggle: () => _toggle('announcements'),
          onManage: () => state.setScreen('operatorAnnouncements'),
        ),
        OperatorCollapsibleCard(
          iconEmoji: '📅',
          title: 'Agenda sekolah',
          meta: '${events.length} agenda tersimpan',
          status: 'Kelola',
          details: _eventDetails(state),
          expanded: _open.contains('agenda'),
          onToggle: () => _toggle('agenda'),
          onManage: () => state.setScreen('operatorAgenda'),
        ),
        OperatorCollapsibleCard(
          iconEmoji: '📊',
          title: 'Nilai kelas',
          meta: 'Isi, ubah, dan hapus nilai ringkas siswa',
          status: 'Kelola',
          details: const <String>[
            'Nilai ringkas per kelas dipakai untuk rekap di beranda wali kelas.',
            'Nilai di luar 0–100 ditolak.',
          ],
          expanded: _open.contains('grades'),
          onToggle: () => _toggle('grades'),
          onManage: () => state.setScreen('operatorGrades'),
        ),
        OperatorCollapsibleCard(
          iconEmoji: '🗂️',
          title: 'Logo & banner sekolah',
          meta: customGraphics == 0
              ? 'Masih memakai aset bawaan aplikasi'
              : '$customGraphics grafis memakai gambar pilihan operator',
          status: 'Ubah',
          details: <String>[
            for (final slot in MediaAssetSlot.slots)
              '${slot.label} — ${state.mediaAssets.containsKey(slot.key) ? 'gambar pilihan operator' : 'aset bawaan'}',
          ],
          expanded: _open.contains('media'),
          onToggle: () => _toggle('media'),
          onManage: () => state.changeTab('Media'),
        ),
        const SizedBox(height: 8),
        // Profil operator punya tab sendiri (tab keenam, di sebelah Media),
        // jadi tidak lagi menumpuk di ujung beranda.
        _ProfileShortcut(
          initials: profile.initials,
          name: profile.name,
          onTap: () => state.changeTab('Profil'),
        ),
      ],
    );
  }
}

/// Sapaan satu baris di bawah judul layar — pengganti banner "Semangat
/// mengajar!" yang tidak relevan untuk operator.
class _OperatorWelcomeLine extends StatelessWidget {
  const _OperatorWelcomeLine({required this.name, required this.theme});

  final String name;
  final KarsaThemeScope theme;

  @override
  Widget build(BuildContext context) {
    final c = theme.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Selamat datang, $name',
            style: TextStyle(
              fontSize: 20,
              height: 26 / 20,
              fontWeight: FontWeight.w800,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Semua data siswa, kelas, materi, dan aset sekolah bisa diubah dari sini.',
            style: theme.text.muted,
          ),
        ],
      ),
    );
  }
}

/// Pintasan ringkas ke tab Profil: section profil lengkap sudah pindah ke
/// sana supaya beranda operator tetap ringkas.
class _ProfileShortcut extends StatelessWidget {
  const _ProfileShortcut({
    required this.initials,
    required this.name,
    required this.onTap,
  });

  final String initials;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    return MotionPressable(
      semanticsLabel: 'Buka tab Profil operator',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: ClayStyles.soft(
          color: const Color(0xFFFBEAEC),
          isDark: c.isDark,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: ClayStyles.soft(
                color: Colors.white,
                isDark: c.isDark,
                customRadius: BorderRadius.circular(21),
              ),
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: c.rose,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name.isEmpty ? 'Operator Sekolah' : name,
                    style: theme.text.itemTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Identitas kerja dan pengaturan ada di tab Profil',
                    style: theme.text.smallMuted,
                  ),
                ],
              ),
            ),
            Icon(KarsaIcons.chevronForward, size: 18, color: c.rose),
          ],
        ),
      ),
    );
  }
}
