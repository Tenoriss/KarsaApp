import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../providers/app_state.dart';

class TaskFormPage extends StatelessWidget {
  const TaskFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    final subjectOptions = state.isGuru
        ? <String>[state.data.teacherSubject]
        : CurriculumData.subjects;
    final classOptions = state.isWali
        ? const <String>[AppConstants.waliClass]
        : (state.draftSubject == 'Ilmu Pengetahuan Alam dan Sosial (IPAS)'
            ? AppConstants.classes.sublist(2)
            : AppConstants.classes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Tambah tugas',
          sub: 'Data demo tersimpan di perangkat ini',
          onBack: () => state.setScreen('main'),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Judul', style: theme.text.label),
        ),
        KarsaInput(
          value: state.draftTitle,
          onChanged: state.setDraftTitle,
          placeholder: 'Mis. Pecahan sederhana',
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
          child: Text('File tugas', style: theme.text.label),
        ),
        KarsaButton(
          title: state.attachment != null ? 'Ganti file' : 'Unggah file tugas',
          onTap: state.pickAttachment,
        ),
        if (state.attachment != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '📎 ${state.attachment!.name}',
              style: theme.text.smallMuted,
            ),
          ),
        NoticeCard(
          title: 'Asisten penyusunan · demo offline',
          body:
              'Instruksi asisten (demo offline): buat tugas tepat 10 soal sesuai mata pelajaran dan kelas. Bank soal ini belum menggunakan AI dan tidak membaca isi PDF.',
          trailingChild: KarsaButton(
            title: 'Gunakan kuis contoh',
            onTap: state.useExampleQuizForTask,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Tenggat pengumpulan (YYYY-MM-DD)', style: theme.text.label),
        ),
        KarsaInput(
          value: state.draftDue,
          onChanged: state.setDraftDue,
          placeholder: '2026-12-31',
        ),
        Text(
          'Hitung mundur memakai akhir hari pada zona waktu perangkat; waktu tidak mengunci tugas di demo.',
          style: theme.text.smallMuted,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Durasi pengerjaan (menit)', style: theme.text.label),
        ),
        KarsaInput(
          value: state.draftMinutes,
          onChanged: state.setDraftMinutes,
          keyboardType: TextInputType.number,
        ),
        Text(
          'File tersimpan lokal. Kuis contoh berisi 10 soal. Batas waktu belum menghitung mundur.',
          style: theme.text.smallMuted,
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Untuk kelas', style: theme.text.label),
        ),
        KarsaChips(
          options: classOptions,
          value: state.draftClass,
          onChanged: state.setDraftClass,
        ),
        if (state.error.isNotEmpty)
          Text(
            state.error,
            style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
          ),
        KarsaButton(
          title: 'Simpan tugas',
          onTap: state.saveTask,
        ),
        if (state.notice.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(state.notice, style: theme.text.smallMuted),
          ),
      ],
    );
  }
}
