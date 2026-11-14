import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/karsa_segment_tabs.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

/// Form tambah / ubah data siswa untuk operator sekolah.
class OperatorStudentFormPage extends StatelessWidget {
  const OperatorStudentFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final isEdit = state.draftStudentId.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: isEdit ? 'Ubah Data Siswa' : 'Tambah Siswa',
          sub: isEdit
              ? 'Perubahan langsung tersimpan di perangkat ini'
              : 'Siswa baru langsung masuk ke daftar kelas',
          onBack: () => state.setScreen('main'),
        ),
        Text('Nama lengkap', style: theme.text.label),
        KarsaInput(
          value: state.draftStudentName,
          onChanged: state.setDraftStudentName,
          placeholder: 'Nama siswa',
          semanticsLabel: 'Nama siswa',
        ),
        Text('NISN', style: theme.text.label),
        KarsaInput(
          value: state.draftStudentNisn,
          onChanged: state.setDraftStudentNisn,
          placeholder: 'Nomor induk siswa',
          semanticsLabel: 'NISN',
        ),
        Text('Kelas', style: theme.text.label),
        KarsaChips(
          options: state.operatorClassOptions,
          value: state.draftStudentClass,
          onChanged: state.setDraftStudentClass,
        ),
        const SizedBox(height: 10),
        Text('Jenis kelamin', style: theme.text.label),
        KarsaSegmentTabs(
          options: const <String>['L', 'P'],
          value: state.draftStudentGender,
          onChanged: state.setDraftStudentGender,
        ),
        const SizedBox(height: 16),
        Text('Orang tua / wali', style: theme.text.label),
        KarsaInput(
          value: state.draftStudentParent,
          onChanged: state.setDraftStudentParent,
          placeholder: 'Nama orang tua atau wali',
          semanticsLabel: 'Nama orang tua',
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
          title: 'Simpan data siswa',
          onTap: state.saveStudentForm,
        ),
        if (isEdit)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                state.removeStudent(state.draftStudentId);
                state.setScreen('main');
              },
              child: Text('Hapus siswa ini', style: theme.text.link),
            ),
          ),
      ],
    );
  }
}
