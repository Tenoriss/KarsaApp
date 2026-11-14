import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class AgendaFormPage extends StatelessWidget {
  const AgendaFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Tambah agenda kelas',
          sub: AppConstants.waliClass,
          onBack: () => state.changeTab('Agenda'),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Judul agenda', style: theme.text.label),
        ),
        KarsaInput(
          value: state.draftTitle,
          onChanged: state.setDraftTitle,
          placeholder: 'Mis. Pertemuan orang tua',
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Tanggal (YYYY-MM-DD)', style: theme.text.label),
        ),
        KarsaInput(
          value: state.eventDate,
          onChanged: state.setEventDate,
          placeholder: '2026-11-07',
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Catatan (opsional)', style: theme.text.label),
        ),
        KarsaInput(
          value: state.draftBody,
          onChanged: state.setDraftBody,
          placeholder: 'Tambahkan catatan kegiatan',
          multiline: true,
          minHeight: 100,
        ),
        if (state.error.isNotEmpty)
          Text(
            state.error,
            style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
          ),
        KarsaButton(
          title: 'Simpan agenda',
          onTap: state.saveEvent,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Text(
            'Agenda dan pemberitahuan disimpan pada perangkat ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
