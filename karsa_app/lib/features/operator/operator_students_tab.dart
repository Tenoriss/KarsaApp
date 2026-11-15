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

/// Tab "Siswa": seluruh data siswa lintas kelas, bisa ditambah, diubah, dan
/// dihapus oleh operator sekolah.
class OperatorStudentsTab extends StatelessWidget {
  const OperatorStudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);

    final filter = state.filter == 'Semua kelas' ? 'Semua kelas' : state.filter;
    final students = filter == 'Semua kelas'
        ? state.roster
        : state.rosterForClass(filter);
    final query = state.operatorStudentQuery.trim().toLowerCase();

    final visible = query.isEmpty
        ? students
        : students
            .where((s) =>
                s.name.toLowerCase().contains(query) ||
                s.nisn.contains(query))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Data Siswa',
          sub: '${state.roster.length} siswa · ${state.activeStudentCount} aktif',
        ),
        KarsaChips(
          options: <String>['Semua kelas', ...state.operatorClassOptions],
          value: filter,
          onChanged: state.setFilter,
        ),
        const SizedBox(height: 6),
        _SearchField(
          value: state.operatorStudentQuery,
          onChanged: state.setOperatorStudentQuery,
        ),
        if (visible.isEmpty)
          const NoticeCard(
            body: 'Tidak ada siswa yang cocok dengan pencarian ini.',
          )
        else
          for (final student in visible)
            _StudentRow(student: student),
        const SizedBox(height: 6),
        KarsaButton(
          title: '+ Tambah siswa',
          onTap: () => state.openStudentForm(),
        ),
        Text(
          'Data tersimpan di perangkat ini pada kunci "@karsa-demo-v1".',
          style: theme.text.smallMuted,
        ),
      ],
    );
  }
}

class _SearchField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.value, required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'Cari nama atau NISN',
          hintStyle: const TextStyle(color: Color(0xFF8294A3), fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFFFFDFB),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEFDFD9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEFDFD9)),
          ),
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final StudentProfile student;

  const _StudentRow({required this.student});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);

    return ListItemCard(
      iconEmoji: student.gender.toUpperCase() == 'P' ? '👧🏻' : '👦🏻',
      tileColor: const Color(0xFFF8EBEC),
      title: student.name,
      meta: '${student.className} · NISN ${student.nisn.isEmpty ? '-' : student.nisn}'
          '${student.parentName.isEmpty ? '' : ' · ${student.parentName}'}',
      status: student.active ? 'Aktif' : 'Nonaktif',
      onTap: () => state.openStudentForm(student.id),
    );
  }
}
