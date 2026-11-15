import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

/// Daftar agenda sekolah lintas kelas. Operator sekolah bisa menambah,
/// mengubah, dan menghapus agenda milik wali kelas.
class OperatorAgendaPage extends StatelessWidget {
  const OperatorAgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);

    final filter = state.filter == 'Semua kelas' ? 'Semua kelas' : state.filter;
    final all = state.data.classEvents;
    final events = filter == 'Semua kelas'
        ? all
        : all.where((e) => e.className == filter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Agenda Sekolah',
          sub: '${all.length} agenda tersimpan',
          onBack: () => state.setScreen('main'),
        ),
        KarsaChips(
          options: <String>['Semua kelas', ...state.operatorClassOptions],
          value: filter,
          onChanged: state.setFilter,
        ),
        const SizedBox(height: 6),
        if (events.isEmpty)
          const NoticeCard(body: 'Belum ada agenda untuk kelas ini.')
        else
          for (final event in events)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ListItemCard(
                    iconEmoji: '📅',
                    tileColor: const Color(0xFFF8EBEC),
                    title: event.title,
                    meta: '${event.className} · ${event.date}'
                        '${event.body.isEmpty ? '' : ' · ${event.body}'}',
                    status: 'Ubah',
                    onTap: () => state.openOperatorEventForm(event.id),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => state.openOperatorEventForm(event.id),
                        child: Text('Ubah', style: theme.text.link),
                      ),
                      TextButton(
                        onPressed: () => state.deleteEvent(event.id),
                        child: Text('Hapus', style: theme.text.link),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        KarsaButton(
          title: '+ Tambah agenda',
          onTap: () => state.openOperatorEventForm(),
        ),
        Text(
          'Agenda sekolah tersimpan di perangkat ini pada kunci "@karsa-demo-v1".',
          style: theme.text.smallMuted,
        ),
      ],
    );
  }
}

/// Form tambah / ubah agenda sekolah.
class OperatorAgendaFormPage extends StatelessWidget {
  const OperatorAgendaFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final isEdit = state.draftEventId.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: isEdit ? 'Ubah Agenda' : 'Tambah Agenda',
          sub: 'Tersimpan di perangkat ini',
          onBack: () => state.setScreen('operatorAgenda'),
        ),
        Text('Judul agenda', style: theme.text.label),
        KarsaInput(
          value: state.draftTitle,
          onChanged: state.setDraftTitle,
          placeholder: 'Mis. Pertemuan orang tua',
          semanticsLabel: 'Judul agenda',
        ),
        Text('Tanggal (YYYY-MM-DD)', style: theme.text.label),
        KarsaInput(
          value: state.eventDate,
          onChanged: state.setEventDate,
          placeholder: '2026-11-07',
          semanticsLabel: 'Tanggal agenda',
        ),
        Text('Untuk kelas', style: theme.text.label),
        KarsaChips(
          options: state.operatorClassOptions,
          value: state.draftClass,
          onChanged: state.setDraftClass,
        ),
        Text('Catatan (opsional)', style: theme.text.label),
        KarsaInput(
          value: state.draftBody,
          onChanged: state.setDraftBody,
          placeholder: 'Tambahkan catatan kegiatan',
          multiline: true,
          minHeight: 100,
          semanticsLabel: 'Catatan agenda',
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
          title: 'Simpan agenda',
          onTap: state.saveOperatorEvent,
        ),
        if (isEdit)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                state.deleteEvent(state.draftEventId);
                state.setScreen('operatorAgenda');
              },
              child: Text('Hapus agenda ini', style: theme.text.link),
            ),
          ),
      ],
    );
  }
}
