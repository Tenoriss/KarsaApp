import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/list_item_card.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class StudentsListPage extends StatelessWidget {
  const StudentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final names = <String>[state.data.studentName, 'Sari Putri', 'Rafi Pratama'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Daftar Siswa',
          sub: 'Data contoh',
          onBack: () => state.setScreen('main'),
        ),
        for (int i = 0; i < names.length; i++)
          ListItemCard(
            iconEmoji: i == 2 ? '👦🏻' : '🙂',
            tileColor: const Color(0xFFF8EBEC),
            title: names[i],
            meta: i == 0
                ? '${state.data.results.length} tugas selesai'
                : 'Siswa aktif · Kelas 1',
            status: 'Aktif',
            onTap: () => state.openStudentDetail(names[i], i),
          ),
      ],
    );
  }
}
