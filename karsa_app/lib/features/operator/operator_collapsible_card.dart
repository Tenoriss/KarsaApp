import 'package:flutter/material.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/dark_color_mapper.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/motion_pressable.dart';

/// Kartu pintasan operator yang bisa **dilipat sendiri-sendiri**.
///
/// Beranda operator sebelumnya menumpuk lima kartu pintasan berukuran penuh
/// (tugas, pengumuman, agenda, nilai, logo & banner) sehingga daftar menjadi
/// panjang dan isi sekolah yang sebenarnya tidak pernah terlihat. Kartu ini
/// menampilkan baris ringkas saat tertutup — cukup untuk tahu isinya — dan
/// membuka rinciannya hanya saat diketuk.
///
/// Setiap kartu punya status buka/tutup sendiri, jadi operator bisa membuka
/// hanya bagian yang dibutuhkan tanpa membuka semuanya.
class OperatorCollapsibleCard extends StatelessWidget {
  const OperatorCollapsibleCard({
    super.key,
    required this.iconEmoji,
    required this.title,
    required this.meta,
    required this.status,
    required this.details,
    required this.expanded,
    required this.onToggle,
    required this.onManage,
    this.tileColor = const Color(0xFFF8EBEC),
  });

  /// Emoji yang tampil di kotak ikon, mis. `📣`.
  final String iconEmoji;

  /// Judul kartu, mis. `Pengumuman sekolah`.
  final String title;

  /// Ringkasan satu baris saat kartu tertutup, mis. `3 pengumuman aktif`.
  final String meta;

  /// Label tombol di kanan, mis. `Kelola`.
  final String status;

  /// Isi rincian yang muncul saat kartu dibuka. Kosong berarti kartu hanya
  /// menampilkan ringkasan dan tetap bisa diketuk untuk membuka halaman.
  final List<String> details;

  /// Status buka/tutup kartu ini.
  final bool expanded;

  /// Dipanggil saat baris ringkas diketuk.
  final VoidCallback onToggle;

  /// Dipanggil saat tombol [status] diketuk; tidak menutup kartu.
  final VoidCallback onManage;

  /// Warna kotak ikon.
  final Color tileColor;

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final detailBg = DarkColorMapper.surface(
      const Color(0xFFFBF3F4),
      isDark: c.isDark,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ClayStyles.soft(color: c.card, isDark: c.isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MotionPressable(
            semanticsLabel: expanded
                ? 'Tutup rincian $title'
                : 'Buka rincian $title',
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: ClayStyles.soft(
                      color: tileColor,
                      isDark: c.isDark,
                      radius: 14,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      iconEmoji,
                      style: const TextStyle(fontSize: 23),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(title, style: theme.text.itemTitle),
                        const SizedBox(height: 2),
                        Text(meta, style: theme.text.smallMuted),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  MotionPressable(
                    semanticsLabel: '$status $title',
                    onTap: onManage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: ClayStyles.soft(
                        color: const Color(0xFFF9E8ED),
                        isDark: c.isDark,
                        radius: 12,
                        borderWidth: 1,
                      ),
                      child: Text(
                        status,
                        style: theme.text.badge.copyWith(color: c.rose),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Panah sebagai penanda buka/tutup: berputar 90° saat terbuka.
                  AnimatedRotation(
                    turns: expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: Icon(
                      KarsaIcons.chevronForward,
                      size: 17,
                      color: c.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded && details.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              decoration: ClayStyles.inset(
                color: detailBg,
                isDark: c.isDark,
                radius: 14,
                borderColor: const Color(0xFFF1E5E2),
                borderWidth: 1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (var i = 0; i < details.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: 7),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 5, right: 8),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: c.rose,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            details[i],
                            style: theme.text.smallMuted.copyWith(
                              color: c.ink,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
