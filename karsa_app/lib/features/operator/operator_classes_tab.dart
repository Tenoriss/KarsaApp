import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/karsa_segment_tabs.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

/// Tab "Kelas": operator sekolah menambah, mengubah, dan menghapus kelas
/// sekolah beserta wali kelasnya, mengelola akun guru dan wali, serta
/// memindahkan siswa antar kelas.
class OperatorClassesTab extends StatefulWidget {
  const OperatorClassesTab({super.key});

  @override
  State<OperatorClassesTab> createState() => _OperatorClassesTabState();
}

class _OperatorClassesTabState extends State<OperatorClassesTab> {
  String _section = 'Kelas';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Kelas Sekolah',
          sub: '${state.schoolClasses.length} kelas · '
              '${state.staffAccounts.length} akun guru dan wali',
        ),
        KarsaSegmentTabs(
          options: const <String>['Kelas', 'Akun', 'Siswa'],
          value: _section,
          onChanged: (value) => setState(() => _section = value),
        ),
        if (state.error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              state.error,
              style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
            ),
          ),
        if (_section == 'Kelas') _buildClasses(context, state, theme, c),
        if (_section == 'Akun') _buildAccounts(context, state, theme, c),
        if (_section == 'Siswa') _buildStudents(context, state, theme, c),
      ],
    );
  }

  Widget _buildClasses(
    BuildContext context,
    AppState state,
    KarsaThemeScope theme,
    AppColors c,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final schoolClass in state.schoolClasses)
          ClayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(schoolClass.name, style: theme.text.itemTitle),
                    ),
                    Text(
                      '${state.rosterForClass(schoolClass.name).length} siswa',
                      style: theme.text.smallMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Wali kelas: '
                  '${schoolClass.teacherName.isEmpty ? 'Belum ditentukan' : schoolClass.teacherName}'
                  ' · ${state.data.tasks.where((t) => t.className == schoolClass.name).length} tugas'
                  ' · ${state.data.materials.where((m) => m.className == schoolClass.name).length} materi',
                  style: theme.text.smallMuted,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => state.openOperatorClassForm(schoolClass.id),
                      child: Text('Ubah', style: theme.text.link),
                    ),
                    TextButton(
                      onPressed: () => state.removeSchoolClass(schoolClass.id),
                      child: Text('Hapus', style: theme.text.link),
                    ),
                  ],
                ),
              ],
            ),
          ),
        KarsaButton(
          title: '+ Tambah kelas',
          onTap: () => state.openOperatorClassForm(),
        ),
        Text(
          'Menghapus kelas memindahkan siswanya ke kelas pertama yang tersisa.',
          style: theme.text.smallMuted.copyWith(color: c.muted),
        ),
      ],
    );
  }

  Widget _buildAccounts(
    BuildContext context,
    AppState state,
    KarsaThemeScope theme,
    AppColors c,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final account in state.staffAccounts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ListItemCard(
                  iconEmoji: account.isWali ? '👩🏻‍🏫' : '📚',
                  tileColor: const Color(0xFFF8EBEC),
                  title: account.name,
                  meta: 'NIP ${account.nip} · ${account.roleLabel}'
                      '${account.className.isEmpty ? '' : ' · ${account.className}'}',
                  status: 'Ubah',
                  onTap: () => state.openOperatorStaffForm(account.id),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => state.openOperatorStaffForm(account.id),
                      child: Text('Ubah', style: theme.text.link),
                    ),
                    TextButton(
                      onPressed: () => state.removeStaffAccount(account.id),
                      child: Text('Hapus', style: theme.text.link),
                    ),
                  ],
                ),
              ],
            ),
          ),
        KarsaButton(
          title: '+ Tambah akun',
          onTap: () => state.openOperatorStaffForm(),
        ),
        Text(
          'Akun guru dan wali yang dibuat operator tersimpan di perangkat ini.',
          style: theme.text.smallMuted.copyWith(color: c.muted),
        ),
      ],
    );
  }

  Widget _buildStudents(
    BuildContext context,
    AppState state,
    KarsaThemeScope theme,
    AppColors c,
  ) {
    final filter = state.filter == 'Semua kelas' ? 'Semua kelas' : state.filter;
    final students = filter == 'Semua kelas'
        ? state.roster
        : state.rosterForClass(filter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        KarsaChips(
          options: <String>['Semua kelas', ...state.operatorClassOptions],
          value: filter,
          onChanged: state.setFilter,
        ),
        const SizedBox(height: 6),
        for (final student in students)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ListItemCard(
                  iconEmoji: student.gender.toUpperCase() == 'P' ? '👧🏻' : '👦🏻',
                  tileColor: const Color(0xFFF8EBEC),
                  title: student.name,
                  meta: '${student.className} · NISN '
                      '${student.nisn.isEmpty ? '-' : student.nisn}',
                  status: student.active ? 'Aktif' : 'Nonaktif',
                  onTap: () => state.openStudentForm(student.id),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => state.openStudentForm(student.id),
                    child: Text('Ubah data', style: theme.text.link),
                  ),
                ),
              ],
            ),
          ),
        Text(
          'Pindah kelas siswa lewat tombol "Ubah data" pada form siswa.',
          style: theme.text.smallMuted.copyWith(color: c.muted),
        ),
      ],
    );
  }
}

/// Form tambah / ubah kelas sekolah.
class OperatorClassFormPage extends StatelessWidget {
  const OperatorClassFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final isEdit = state.draftSchoolClassId.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: isEdit ? 'Ubah Kelas' : 'Tambah Kelas',
          sub: 'Kelas sekolah beserta wali kelasnya',
          onBack: () => state.setScreen('main'),
        ),
        Text('Nama kelas', style: theme.text.label),
        KarsaInput(
          value: state.draftSchoolClassName,
          onChanged: state.setDraftSchoolClassName,
          placeholder: 'Mis. Kelas 7',
          semanticsLabel: 'Nama kelas',
        ),
        Text('Wali kelas', style: theme.text.label),
        KarsaInput(
          value: state.draftSchoolClassTeacher,
          onChanged: state.setDraftSchoolClassTeacher,
          placeholder: 'Nama wali kelas',
          semanticsLabel: 'Wali kelas',
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
          title: 'Simpan kelas',
          onTap: state.saveOperatorClass,
        ),
        if (isEdit)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                if (state.removeSchoolClass(state.draftSchoolClassId)) {
                  state.setScreen('main');
                }
              },
              child: Text('Hapus kelas ini', style: theme.text.link),
            ),
          ),
      ],
    );
  }
}

/// Form tambah / ubah akun guru atau wali kelas.
class OperatorStaffFormPage extends StatelessWidget {
  const OperatorStaffFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final isEdit = state.draftStaffId.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: isEdit ? 'Ubah Akun' : 'Tambah Akun',
          sub: 'Akun guru atau wali kelas',
          onBack: () => state.setScreen('main'),
        ),
        Text('Nama lengkap', style: theme.text.label),
        KarsaInput(
          value: state.draftStaffName,
          onChanged: state.setDraftStaffName,
          placeholder: 'Nama pengguna',
          semanticsLabel: 'Nama pengguna',
        ),
        Text('NIP', style: theme.text.label),
        KarsaInput(
          value: state.draftStaffNip,
          onChanged: state.setDraftStaffNip,
          placeholder: 'Nomor induk pegawai',
          semanticsLabel: 'NIP',
        ),
        Text('Peran', style: theme.text.label),
        KarsaSegmentTabs(
          options: const <String>['guru', 'wali'],
          value: state.draftStaffRole,
          onChanged: state.setDraftStaffRole,
        ),
        if (state.draftStaffRole == 'wali') ...<Widget>[
          Text('Kelas yang diampu', style: theme.text.label),
          KarsaChips(
            options: state.operatorClassOptions,
            value: state.draftStaffClass,
            onChanged: state.setDraftStaffClass,
          ),
        ],
        if (state.error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              state.error,
              style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
            ),
          ),
        KarsaButton(
          title: 'Simpan akun',
          onTap: state.saveOperatorStaff,
        ),
        if (isEdit)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                if (state.removeStaffAccount(state.draftStaffId)) {
                  state.setScreen('main');
                }
              },
              child: Text('Hapus akun ini', style: theme.text.link),
            ),
          ),
      ],
    );
  }
}
