import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class GradeRecapPage extends StatelessWidget {
  const GradeRecapPage({super.key});

  String _formatScore(double? score) {
    if (score == null) return '—';
    if (score == score.roundToDouble()) return score.toInt().toString();
    return score.toString();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final classTasks = state.data.tasks
        .where(
          (t) =>
              t.className == state.gradeClass &&
              t.subject == state.data.teacherSubject,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Rekap nilai per kelas',
          sub: '${state.data.teacherSubject} · data lokal',
          onBack: () => state.setScreen(state.gradeReturn),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Pilih kelas untuk wali kelas', style: theme.text.label),
        ),
        KarsaChips(
          options: AppConstants.classes,
          value: state.gradeClass,
          onChanged: state.setGradeClass,
        ),
        NoticeCard(
          title: '${state.gradeClass} · ${state.data.teacherSubject}',
          body:
              'Hanya tugas dan siswa contoh kelas ini yang disertakan. Nilai kosong bukan nol; nilai contoh bukan nilai resmi.',
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('Ringkasan nilai', style: theme.text.section),
        ),
        if (classTasks.isNotEmpty)
          for (final t in classTasks)
            ClayCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    '${t.title}${t.demo ? " · contoh" : ""}',
                    style: theme.text.itemTitle,
                  ),
                  for (final member in state.gradeRoster(state.gradeClass, t))
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(member.name, style: theme.text.itemTitle),
                                Text(
                                  '${state.gradeNote(t, member)}${member.example ? " · siswa contoh" : ""}',
                                  style: theme.text.smallMuted,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatScore(state.gradeFor(t, member)),
                            style: TextStyle(
                              color: c.rose,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              'Belum ada tugas untuk kelas dan mata pelajaran ini.',
              style: theme.text.muted,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Text('Ekspor dan bagikan', style: theme.text.section),
        ),
        Text(
          'Pilih format. Di ponsel, pilih sendiri wali kelas melalui menu berbagi; di web file diunduh. Belum ada pengiriman otomatis atau sinkronisasi antarperangkat.',
          style: theme.text.muted,
        ),
        if (state.error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.error,
              style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
            ),
          ),
        if (state.notice.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(state.notice, style: theme.text.smallMuted),
          ),
        KarsaButton(
          title: 'Ekspor Excel (.xlsx)',
          disabled: state.exporting,
          onTap: () => state.exportGrades('Excel'),
        ),
        KarsaButton(
          title: 'Ekspor PDF',
          disabled: state.exporting,
          onTap: () => state.exportGrades('PDF'),
        ),
      ],
    );
  }
}
