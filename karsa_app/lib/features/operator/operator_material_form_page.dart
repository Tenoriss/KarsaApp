import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

/// Form tambah / ubah materi sekolah milik semua guru.
class OperatorMaterialFormPage extends StatelessWidget {
  const OperatorMaterialFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final isEdit = state.draftMaterialId.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: isEdit ? 'Ubah Materi' : 'Tambah Materi',
          sub: 'Materi untuk seluruh kelas',
          onBack: () => state.setScreen('main'),
        ),
        Text('Judul materi', style: theme.text.label),
        KarsaInput(
          value: state.draftTitle,
          onChanged: state.setDraftTitle,
          placeholder: 'Mis. Ekosistem',
          semanticsLabel: 'Judul materi',
        ),
        Text('Mata pelajaran', style: theme.text.label),
        KarsaChips(
          options: CurriculumData.subjects,
          value: state.draftSubject,
          onChanged: state.setDraftSubject,
        ),
        Text('Untuk kelas', style: theme.text.label),
        KarsaChips(
          options: state.operatorClassOptions,
          value: state.draftClass,
          onChanged: state.setDraftClass,
        ),
        Text('Ringkasan materi', style: theme.text.label),
        KarsaInput(
          value: state.summaryText,
          onChanged: state.setSummaryText,
          placeholder: 'Tulis ringkasan materi...',
          multiline: true,
          minHeight: 120,
          semanticsLabel: 'Ringkasan materi',
        ),
        const NoticeCard(
          title: 'Ringkasan demo offline',
          body:
              'Teks ringkasan diisi manual oleh operator. Pendinginan otomatis hanya tersedia pada form materi milik guru.',
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
          title: 'Simpan materi',
          onTap: state.saveOperatorMaterial,
        ),
        if (isEdit)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                state.deleteMaterial(state.draftMaterialId);
                state.setScreen('main');
              },
              child: Text('Hapus materi ini', style: theme.text.link),
            ),
          ),
      ],
    );
  }
}
