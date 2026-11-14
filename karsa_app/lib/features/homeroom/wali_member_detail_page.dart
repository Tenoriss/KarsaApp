import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class WaliMemberDetailPage extends StatelessWidget {
  const WaliMemberDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final matches = state.classMembers.where((m) => m.id == state.memberId).toList();

    if (matches.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PageHeader(
            title: 'Siswa tidak ditemukan',
            onBack: () => state.setScreen('main'),
          ),
        ],
      );
    }

    final member = matches.first;
    final hasScore = state.data.classScores.containsKey(member.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: member.name,
          sub: '${AppConstants.waliClass} · data contoh',
          onBack: () => state.changeTab('Anggota'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(
            children: <Widget>[
              Container(
                width: 84,
                height: 84,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: ClayStyles.soft(
                  color: const Color(0xFFF4E4E7),
                  isDark: c.isDark,
                  radius: 42,
                ),
                alignment: Alignment.center,
                child: Text(member.icon, style: const TextStyle(fontSize: 42)),
              ),
              Text(member.name, style: theme.text.name),
              const SizedBox(height: 4),
              Text(
                '${AppConstants.waliClass} · Siswa aktif',
                style: theme.text.muted,
              ),
            ],
          ),
        ),
        ClayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Kehadiran hari ini', style: theme.text.itemTitle),
              const SizedBox(height: 4),
              Text(
                state.todayAttendance[member.id] ?? 'Belum dicatat',
                style: theme.text.muted,
              ),
              KarsaButton(
                title: 'Isi kehadiran',
                onTap: () => state.openWaliRecapShortcut(
                  tabName: 'Kehadiran',
                  resetToToday: true,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('Nilai ringkas', style: theme.text.section),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Masukkan nilai contoh 0–100. Ini bukan nilai resmi atau nilai per mata pelajaran.',
            style: theme.text.muted,
          ),
        ),
        KarsaInput(
          value: state.scoreDraft,
          onChanged: state.setScoreDraft,
          placeholder: 'Mis. 85',
          semanticsLabel: 'Nilai ringkas',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        if (state.error.isNotEmpty)
          Text(
            state.error,
            style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
          ),
        KarsaButton(
          title: 'Simpan nilai',
          onTap: state.saveScore,
        ),
        if (hasScore)
          Center(
            child: MotionPressable(
              onTap: state.deleteScore,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Hapus nilai', style: theme.text.link),
              ),
            ),
          ),
      ],
    );
  }
}
