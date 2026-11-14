import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

class MaterialsPage extends StatelessWidget {
  const MaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    final list = state.data.materials.where((m) {
      if (state.isTeacher) {
        final classOk =
            state.filter == 'Semua kelas' || m.className == state.filter;
        final subjOk = !state.isGuru || m.subject == state.data.teacherSubject;
        return classOk && subjOk;
      }
      return m.className == state.data.childClass;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Materi belajar',
          sub: state.isTeacher
              ? 'Kelola materi dan ringkasan'
              : 'Materi untuk ${state.data.childClass}',
          onBack: () => state.setScreen('main'),
        ),
        if (state.isTeacher)
          KarsaButton(
            title: '+ Unggah materi',
            onTap: () => state.openForm('materialForm'),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Materi dan ringkasan tersimpan di perangkat ini.',
            style: theme.text.muted,
          ),
        ),
        for (final m in list)
          ListItemCard(
            iconEmoji: CurriculumData.metaFor(m.subject).icon,
            tileColor: CurriculumData.metaFor(m.subject).color,
            title: m.title,
            meta: '${m.subject} · ${m.className} · ${m.teacher}',
            status: 'Lihat',
            onTap: () => state.openMaterialDetail(m),
          ),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 35),
            child: Text(
              'Belum ada materi untuk ditampilkan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted),
            ),
          ),
      ],
    );
  }
}
