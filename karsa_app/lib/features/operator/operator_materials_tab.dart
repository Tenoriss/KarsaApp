import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../models/material_item.dart';
import '../../providers/app_state.dart';

/// Tab "Materi": seluruh materi sekolah lintas kelas dan guru. Operator bisa
/// membuka, mengganti, dan menghapus materi milik role lain.
class OperatorMaterialsTab extends StatelessWidget {
  const OperatorMaterialsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);

    final filter = state.filter == 'Semua kelas' ? 'Semua kelas' : state.filter;
    final all = state.data.materials;
    final materials = filter == 'Semua kelas'
        ? all
        : all.where((m) => m.className == filter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Materi Sekolah',
          sub: '${all.length} materi dari semua guru',
        ),
        KarsaChips(
          options: <String>['Semua kelas', ...state.operatorClassOptions],
          value: filter,
          onChanged: state.setFilter,
        ),
        const SizedBox(height: 6),
        if (materials.isEmpty)
          const NoticeCard(
            body: 'Belum ada materi untuk kelas ini.',
          )
        else
          for (final material in materials)
            _MaterialRow(material: material),
        const SizedBox(height: 4),
        KarsaButton(
          title: '+ Tambah materi',
          onTap: () => state.openOperatorMaterialForm(),
        ),
        Text(
          'Operator sekolah boleh menambah, mengubah, dan menghapus materi milik guru dan wali kelas.',
          style: theme.text.smallMuted,
        ),
      ],
    );
  }
}

class _MaterialRow extends StatelessWidget {
  final MaterialItem material;

  const _MaterialRow({required this.material});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListItemCard(
            iconEmoji: '📚',
            tileColor: const Color(0xFFF8EBEC),
            title: material.title,
            meta: '${material.subject} · ${material.className} · ${material.teacher}',
            status: 'Lihat',
            onTap: () => state.openMaterialDetail(material),
          ),
          if (state.canManageAll)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => state.openOperatorMaterialForm(material.id),
                  child: Text('Ubah', style: theme.text.link),
                ),
                TextButton(
                  onPressed: () => state.deleteMaterial(material.id),
                  child: Text('Hapus', style: theme.text.link),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
