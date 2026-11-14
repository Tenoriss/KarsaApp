import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class AnnouncementFormPage extends StatelessWidget {
  const AnnouncementFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    final classOptions = state.isWali
        ? const <String>[AppConstants.waliClass]
        : const <String>['Semua kelas', ...AppConstants.classes];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Buat pengumuman',
          sub: 'Data demo tersimpan di perangkat ini',
          onBack: () => state.setScreen('announcements'),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Judul', style: theme.text.label),
        ),
        KarsaInput(
          value: state.draftTitle,
          onChanged: state.setDraftTitle,
          placeholder: 'Mis. Libur sekolah',
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Isi pengumuman', style: theme.text.label),
        ),
        KarsaInput(
          value: state.draftBody,
          onChanged: state.setDraftBody,
          placeholder: 'Tulis pengumuman...',
          multiline: true,
          minHeight: 120,
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
          title: 'Kirim pengumuman',
          onTap: state.saveAnnouncement,
        ),
      ],
    );
  }
}
