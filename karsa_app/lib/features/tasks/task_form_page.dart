import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/motion_pressable.dart';
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
        const SizedBox(height: 14),
        _AssistantPanel(state: state),
        NoticeCard(
          title: 'Bank soal contoh',
          body:
              'Kalau tidak memakai asisten, tugas memakai bank soal contoh mata pelajaran ini (10 soal). Pilih "Gunakan kuis contoh" untuk itu.',
          trailingChild: KarsaButton(
            title: state.assistantUsed
                ? 'Pakai kuis contoh saja'
                : 'Gunakan kuis contoh',
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


/// Panel simulasi asisten penyusun soal.
///
/// Alur yang diharapkan: guru/wali mengunggah file (PDF/gambar/teks) **atau**
/// menempel teks bahan, lalu asisten membuat soal dari bahan itu. Karena demo
/// ini offline, hanya file `.txt` yang benar-benar terbaca; PDF tidak dibaca
/// dan itu dinyatakan terang-terangan supaya tidak menyesatkan.
class _AssistantPanel extends StatefulWidget {
  const _AssistantPanel({required this.state});

  final AppState state;

  @override
  State<_AssistantPanel> createState() => _AssistantPanelState();
}

class _AssistantPanelState extends State<_AssistantPanel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.assistantSource);
  }

  @override
  void didUpdateWidget(covariant _AssistantPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Form dibuka ulang untuk tugas lain: samakan isi kotak dengan state.
    if (_controller.text != widget.state.assistantSource) {
      _controller.value = TextEditingValue(
        text: widget.state.assistantSource,
        selection: TextSelection.collapsed(
          offset: widget.state.assistantSource.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final questions = state.assistantQuestions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ClayStyles.soft(
        color: const Color(0xFFF2F6F8),
        isDark: c.isDark,
        radius: 18,
        borderColor: const Color(0xFFDCE9EE),
        borderWidth: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: ClayStyles.raised(
                  color: c.blue,
                  isDark: c.isDark,
                  radius: 17,
                ),
                child: const Icon(
                  KarsaIcons.albums,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Asisten penyusun soal', style: theme.text.itemTitle),
                    Text(
                      'Simulasi offline',
                      style: theme.text.smallMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Unggah bahan (PDF/gambar/teks) lalu tempel isinya di bawah, '
            'atau unggah file .txt yang teksnya terbaca otomatis. Asisten '
            'akan menyusun soal pilihan ganda dari bahan itu — satu soal per '
            'kalimat lengkap, maksimal 10 soal.',
            style: theme.text.smallMuted,
          ),
          const SizedBox(height: 10),
          if (state.attachment != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                state.sourceText.trim().isEmpty
                    ? '📎 ${state.attachment!.name} — bukan .txt, teksnya tidak '
                        'terbaca otomatis. Tempel teksnya di bawah.'
                    : '📎 ${state.attachment!.name} — teksnya terbaca otomatis.',
                style: theme.text.smallMuted,
              ),
            ),
          TextField(
            controller: _controller,
            onChanged: state.setAssistantSource,
            minLines: 3,
            maxLines: 6,
            style: TextStyle(fontSize: 13, color: c.ink),
            decoration: InputDecoration(
              hintText: 'Tempel teks bahan ajar di sini (minimal dua kalimat)...',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9AAABD)),
              filled: true,
              fillColor: c.card,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: c.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: c.line),
              ),
            ),
          ),
          const SizedBox(height: 10),
          KarsaButton(
            title: state.assistantReady
                ? 'Buat ulang soal dari bahan'
                : 'Buat soal dengan asisten',
            onTap: state.generateQuestionsFromMaterial,
          ),
          if (questions.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Icon(KarsaIcons.checkmarkCircle, size: 16, color: c.blue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${questions.length} soal siap dipakai tugas ini',
                    style: theme.text.smallMuted.copyWith(
                      color: c.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                MotionPressable(
                  semanticsLabel: 'Buang soal asisten',
                  onTap: state.clearAssistantQuestions,
                  child: Text('Buang', style: theme.text.link),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < questions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  '${i + 1}. ${questions[i].question}',
                  style: theme.text.smallMuted.copyWith(color: c.ink),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
