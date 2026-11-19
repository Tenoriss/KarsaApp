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
        const PageHeader(
          title: 'Operator Sekolah',
          sub: 'Kelola seluruh isi KARSA',
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
        Text('Profil operator', style: theme.text.section),
        const SizedBox(height: 10),
        _OperatorProfileSection(
          profile: profile,
          onEdit: () => state.openSetting('Informasi pribadi'),
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

/// Section profil operator: enam kolom profil ditampilkan lengkap
/// (read-only) dengan tombol Ubah yang membuka form "Informasi pribadi".
class _OperatorProfileSection extends StatelessWidget {
  const _OperatorProfileSection({required this.profile, required this.onEdit});

  final OperatorProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final filled = profile.filledFields;
    final contactHint = [
      if (profile.email.isEmpty) 'surel',
      if (profile.phone.isEmpty) 'telepon',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ClayStyles.soft(color: c.card, isDark: c.isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: ClayStyles.soft(
                  color: const Color(0xFFFBEAEC),
                  isDark: c.isDark,
                  customRadius: BorderRadius.circular(27),
                ),
                child: Text(
                  profile.initials,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: c.rose,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      profile.name.isEmpty ? 'Operator Sekolah' : profile.name,
                      style: theme.text.itemTitle,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.unit.isEmpty ? 'Unit kerja belum diisi' : profile.unit,
                      style: theme.text.smallMuted,
                    ),
                  ],
                ),
              ),
              MotionPressable(
                semanticsLabel: 'Ubah profil operator',
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: ClayStyles.soft(
                    color: const Color(0xFFF9E8ED),
                    isDark: c.isDark,
                    radius: 13,
                    borderWidth: 1,
                  ),
                  child: Text(
                    'Ubah',
                    style: theme.text.badge.copyWith(
                      color: c.rose,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileField(label: 'Nama lengkap', value: profile.name),
          _ProfileField(label: 'NIP', value: profile.nip),
          _ProfileField(label: 'Jabatan', value: profile.role),
          _ProfileField(label: 'Unit kerja', value: profile.unit),
          _ProfileField(label: 'Surel', value: profile.email),
          _ProfileField(label: 'Telepon', value: profile.phone, isLast: true),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: ClayStyles.inset(
              color: DarkColorMapper.surface(
                const Color(0xFFFBF3F4),
                isDark: c.isDark,
              ),
              isDark: c.isDark,
              radius: 13,
              borderColor: const Color(0xFFF1E5E2),
              borderWidth: 1,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  filled < OperatorProfile.totalFields
                      ? KarsaIcons.helpCircleOutline
                      : KarsaIcons.checkmarkCircle,
                  size: 17,
                  color: filled < OperatorProfile.totalFields ? c.rose : c.blue,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    filled < OperatorProfile.totalFields
                        ? 'Lengkapi ${contactHint.isEmpty ? 'data pribadi' : contactHint.join(' & ')} '
                            '($filled/${OperatorProfile.totalFields} kolom terisi)'
                        : 'Data pribadi sudah lengkap',
                    style: theme.text.smallMuted.copyWith(
                      color: c.rose,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu baris label–nilai pada section profil operator.
class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final empty = value.trim().isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: c.line, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 104,
            child: Text(label, style: theme.text.smallMuted),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              empty ? 'Belum diisi' : value,
              style: TextStyle(
                fontSize: 13,
                height: 18 / 13,
                fontWeight: empty ? FontWeight.w500 : FontWeight.w700,
                color: empty ? c.muted : c.ink,
                fontStyle: empty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
