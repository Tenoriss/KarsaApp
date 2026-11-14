import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

class PracticeFormPage extends StatelessWidget {
  const PracticeFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    final subjectOptions = state.isGuru
        ? <String>[state.data.teacherSubject]
        : CurriculumData.subjects;
    final classOptions = state.draftSubject == 'Ilmu Pengetahuan Alam dan Sosial (IPAS)'
        ? AppConstants.classes.sublist(2)
        : AppConstants.classes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Tambah latihan',
          sub: 'Buat latihan esai untuk kelas',
          onBack: () => state.setScreen('subject'),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Judul latihan', style: theme.text.label),
        ),
        KarsaInput(
          value: state.draftTitle,
          onChanged: state.setDraftTitle,
          placeholder: 'Mis. Latihan penjumlahan',
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Mata pelajaran', style: theme.text.label),
        ),
        KarsaChips(
          options: subjectOptions,
          value: state.draftSubject,
          onChanged: state.setDraftSubject,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Untuk kelas', style: theme.text.label),
        ),
        KarsaChips(
          options: classOptions,
          value: state.draftClass,
          onChanged: state.setDraftClass,
        ),
        Text(
          'Instruksi asisten (demo offline): buat latihan tepat 5 soal sesuai mata pelajaran dan kelas. Latihan memakai bank soal contoh, bukan AI. Jawaban tidak dikirim. Status selesai hanya terlihat di perangkat ini.',
          style: theme.text.smallMuted,
        ),
        if (state.error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              state.error,
              style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
            ),
          ),
        KarsaButton(
          title: 'Simpan latihan',
          onTap: state.savePractice,
        ),
      ],
    );
  }
}
