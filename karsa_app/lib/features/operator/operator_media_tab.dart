import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../models/media_asset.dart';
import '../../providers/app_state.dart';
import '../../shared/widgets/media_image.dart';

/// Tab "Media": tempat operator sekolah mengelola seluruh grafis sekolah -
/// logo sekolah, banner siswa, dan banner guru.
///
/// Gambar yang dipilih disimpan di `@karsa-demo-v1` dan langsung dipakai di
/// seluruh aplikasi. Slot yang belum diisi memakai aset bawaan.
class OperatorMediaTab extends StatelessWidget {
  const OperatorMediaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final assets = state.mediaAssets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PageHeader(
          title: 'Foto & Grafis',
          sub: 'Logo dan banner sekolah',
        ),
        NoticeCard(
          title: 'Aset sekolah dikelola operator',
          body:
              'Pilih gambar JPG atau PNG. Grafik yang dipilih langsung tampil di seluruh aplikasi - beranda siswa, beranda guru, dan kartu identitas sekolah. Slot yang dikosongkan kembali memakai aset bawaan.',
        ),
        for (final slot in MediaAssetSlot.slots)
          _MediaSlotCard(
            slot: slot,
            hasCustomImage: assets.containsKey(slot.key),
          ),
        const SizedBox(height: 6),
        Text(
          'Gambar disimpan di perangkat ini pada kunci "@karsa-demo-v1".',
          style: theme.text.smallMuted,
        ),
      ],
    );
  }
}

class _MediaSlotCard extends StatelessWidget {
  final MediaAssetSlot slot;
  final bool hasCustomImage;

  const _MediaSlotCard({required this.slot, required this.hasCustomImage});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    return ClayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: c.line),
                ),
                clipBehavior: Clip.antiAlias,
                child: MediaImage(
                  slotKey: slot.key,
                  fallbackAsset: slot.fallbackAsset,
                  fit: BoxFit.cover,
                  semanticLabel: slot.label,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(slot.label, style: theme.text.itemTitle),
                    const SizedBox(height: 3),
                    Text(slot.description, style: theme.text.smallMuted),
                    const SizedBox(height: 6),
                    Text(
                      hasCustomImage
                          ? 'Gambar pilihan operator aktif'
                          : 'Memakai aset bawaan aplikasi',
                      style: theme.text.smallMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          KarsaButton(
            title: hasCustomImage ? 'Ganti gambar' : 'Pilih gambar',
            margin: EdgeInsets.zero,
            onTap: () async {
              final error = await state.pickMediaAsset(slot.key);
              if (error != null && context.mounted) {
                state.setOperatorMediaError(error);
              }
            },
          ),
          if (hasCustomImage)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => state.removeMediaAsset(slot.key),
                child: Text('Hapus gambar', style: theme.text.link),
              ),
            ),
          if (state.operatorMediaError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.operatorMediaError,
                style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}
