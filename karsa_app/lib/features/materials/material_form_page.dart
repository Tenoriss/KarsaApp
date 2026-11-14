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

class MaterialFormPage extends StatelessWidget {
  const MaterialFormPage({super.key});

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
          title: 'Tambah materi',
          sub: 'File dan ringkasan untuk kelas',
          onBack: () => state.setScreen('materials'),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Judul materi', style: theme.text.label),
        ),
        KarsaInput(
          value: state.draftTitle,
          onChanged: state.setDraftTitle,
          placeholder: 'Mis. Ekosistem',
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
        KarsaButton(
          title: state.attachment != null
              ? 'Ganti file materi'
              : 'Unggah PDF / file materi',
          onTap: state.pickAttachment,
        ),
        if (state.attachment != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '📎 ${state.attachment!.name}',
              style: theme.text.muted,
            ),
          ),
        const NoticeCard(
          title: 'Asisten ringkasan · demo offline',
          body:
              'Untuk .txt, teks dibaca otomatis. Untuk PDF atau dokumen lain, tempel teks di bawah ini. Tombol memilih tiga kalimat pertama; bukan AI dan tidak membaca PDF otomatis.',
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Teks materi', style: theme.text.label),
        ),
        KarsaInput(
          value: state.sourceText,
          onChanged: state.setSourceText,
          placeholder: 'Tempel teks materi di sini...',
          multiline: true,
          minHeight: 100,
        ),
        KarsaButton(
          title: 'Ringkas teks (offline)',
          onTap: state.summarizeOffline,
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Ringkasan (dapat diedit)', style: theme.text.label),
        ),
        KarsaInput(
          value: state.summaryText,
          onChanged: state.setSummaryText,
          placeholder: 'Tulis atau periksa ringkasan...',
          multiline: true,
          minHeight: 100,
        ),
        if (state.error.isNotEmpty)
          Text(
            state.error,
            style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
          ),
        if (state.notice.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(state.notice, style: theme.text.smallMuted),
          ),
        KarsaButton(
          title: 'Simpan materi',
          onTap: state.saveMaterial,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Text(
            'Batas file: web 1 MB; perangkat 10 MB. Data tidak disinkronkan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
