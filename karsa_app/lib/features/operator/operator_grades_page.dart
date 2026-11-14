import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/notice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../models/student_profile.dart';
import '../../providers/app_state.dart';

/// Rekap nilai yang diisi operator sekolah untuk setiap kelas. Nilai disimpan
/// per siswa sehingga tidak ada angka yang dibuat-buat.
class OperatorGradesPage extends StatefulWidget {
  const OperatorGradesPage({super.key});

  @override
  State<OperatorGradesPage> createState() => _OperatorGradesPageState();
}

class _OperatorGradesPageState extends State<OperatorGradesPage> {
  String? _className;

  String _resolveClass(AppState state) {
    final classes = state.operatorClassOptions;
    if (classes.isEmpty) return 'Kelas 1';
    if (_className != null && classes.contains(_className)) return _className!;
    return classes.first;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    final className = _resolveClass(state);
    final students = state.rosterForClass(className);
    final average = state.operatorClassAverage(className);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Nilai Kelas',
          sub: className,
          onBack: () => state.setScreen('main'),
        ),
        KarsaChips(
          options: state.operatorClassOptions,
          value: className,
          onChanged: (value) => setState(() => _className = value),
        ),
        Text(
          average == null
              ? 'Belum ada nilai yang diisi untuk kelas ini.'
              : 'Rata-rata kelas: ${average.toStringAsFixed(1)}',
          style: theme.text.muted,
        ),
        const SizedBox(height: 6),
        if (students.isEmpty)
          const NoticeCard(body: 'Belum ada siswa di kelas ini.')
        else
          for (final student in students)
            _ScoreRow(student: student),
        Text(
          'Nilai kosong berarti belum dinilai - tidak ada angka contoh yang dibuat operator.',
          style: theme.text.smallMuted.copyWith(color: c.muted),
        ),
      ],
    );
  }
}

class _ScoreRow extends StatefulWidget {
  final StudentProfile student;

  const _ScoreRow({required this.student});

  @override
  State<_ScoreRow> createState() => _ScoreRowState();
}

class _ScoreRowState extends State<_ScoreRow> {
  late final TextEditingController _controller;

  /// Pesan galat khusus baris ini (mis. nilai di luar rentang 0-100).
  String _rowError = '';

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    final score = state.operatorScore(widget.student.id);
    _controller = TextEditingController(
      text: score == null
          ? ''
          : (score == score.roundToDouble()
              ? score.toInt().toString()
              : score.toString()),
    );
  }

  @override
  void didUpdateWidget(covariant _ScoreRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.student.id != widget.student.id) {
      final state = context.read<AppState>();
      final score = state.operatorScore(widget.student.id);
      _controller.text = score == null
          ? ''
          : (score == score.roundToDouble()
              ? score.toInt().toString()
              : score.toString());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final score = state.operatorScore(widget.student.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListItemCard(
            iconEmoji:
                widget.student.gender.toUpperCase() == 'P' ? '👧🏻' : '👦🏻',
            tileColor: const Color(0xFFF8EBEC),
            title: widget.student.name,
            meta: widget.student.nisn.isEmpty
                ? 'NISN -'
                : 'NISN ${widget.student.nisn}',
            status: score == null ? 'Belum ada nilai' : 'Nilai $score',
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 14, color: c.ink),
                  decoration: InputDecoration(
                    hintText: 'Nilai 0-100',
                    hintStyle: TextStyle(fontSize: 14, color: c.muted),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: c.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: c.line),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 108,
                child: KarsaButton(
                  title: 'Simpan',
                  margin: const EdgeInsets.only(bottom: 0),
                  onTap: () {
                    final raw = _controller.text.trim();
                    if (raw.isEmpty) {
                      setState(() => _rowError = '');
                      state.saveOperatorScore(widget.student.id, null);
                      return;
                    }
                    final parsed = double.tryParse(raw.replaceAll(',', '.'));
                    if (parsed == null) {
                      setState(() => _rowError = 'Isi angka 0-100.');
                      return;
                    }
                    if (parsed < 0 || parsed > 100) {
                      setState(() => _rowError = 'Nilai harus antara 0 sampai 100.');
                      return;
                    }
                    setState(() => _rowError = '');
                    state.saveOperatorScore(widget.student.id, parsed);
                  },
                ),
              ),
            ],
          ),
          if (_rowError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _rowError,
                style: theme.text.smallMuted.copyWith(color: c.rose),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() => _rowError = '');
                state.saveOperatorScore(widget.student.id, null);
                _controller.clear();
              },
              child: Text('Hapus nilai', style: theme.text.link),
            ),
          ),
        ],
      ),
    );
  }
}
