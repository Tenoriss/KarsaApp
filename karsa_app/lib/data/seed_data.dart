import '../models/announcement_item.dart';
import '../models/class_member.dart';
import '../models/practice_item.dart';
import '../models/task_item.dart';
import '../models/task_result.dart';
import 'curriculum_data.dart';

class SeedData {
  SeedData._();

  static const List<TaskItem> initialTasks = <TaskItem>[
    TaskItem(
      id: 'seed5',
      subject: 'Matematika',
      title: 'Pecahan dan perbandingan',
      className: 'Kelas 5',
      minutes: '30',
    ),
    TaskItem(
      id: 'seed6',
      subject: 'Ilmu Pengetahuan Alam dan Sosial (IPAS)',
      title: 'Ekosistem dan lingkungan',
      className: 'Kelas 6',
      minutes: '30',
    ),
    TaskItem(
      id: 't1',
      subject: 'Matematika',
      title: 'Penjumlahan sampai 20',
      className: 'Kelas 1',
      minutes: '30',
    ),
    TaskItem(
      id: 't2',
      subject: 'Bahasa Indonesia',
      title: 'Membaca kalimat',
      className: 'Kelas 1',
      minutes: '30',
    ),
  ];

  static final List<PracticeItem> defaultPractices = <PracticeItem>[
    for (int i = 0; i < CurriculumData.subjects.length; i++)
      PracticeItem(
        id: CurriculumData.subjects[i] == 'Matematika'
            ? 'p1'
            : CurriculumData.subjects[i] == 'Bahasa Indonesia'
                ? 'p2'
                : CurriculumData.subjects[i] == 'Ilmu Pengetahuan Alam dan Sosial (IPAS)'
                    ? 'p3'
                    : 'practice-$i',
        subject: CurriculumData.subjects[i],
        title: 'Latihan ${CurriculumData.subjects[i]}',
      ),
  ];

  static List<TaskItem> demoSeedTasks(DateTime now) {
    final items = <TaskItem>[];
    for (final grade in <int>[5, 6]) {
      for (int i = 0; i < CurriculumData.subjects.length; i++) {
        final subject = CurriculumData.subjects[i];
        final dueLocal = DateTime(now.year, now.month, now.day + i + 1, 23, 59, 59, 999);
        final pastLocal = DateTime(now.year, now.month, now.day - i - 2, 23, 59, 59, 999);
        items.add(
          TaskItem(
            id: 'demo-$grade-$i-active',
            subject: subject,
            title: 'Tugas $subject',
            className: 'Kelas $grade',
            minutes: '30',
            dueAt: dueLocal.toUtc().toIso8601String(),
            demo: true,
          ),
        );
        items.add(
          TaskItem(
            id: 'demo-$grade-$i-history',
            subject: subject,
            title: 'Tugas sebelumnya · $subject',
            className: 'Kelas $grade',
            minutes: '30',
            dueAt: pastLocal.toUtc().toIso8601String(),
            demo: true,
            demoHistory: true,
          ),
        );
      }
    }
    return items;
  }

  static Map<String, TaskResult> demoResults(List<TaskItem> tasks) {
    final map = <String, TaskResult>{};
    for (final task in tasks) {
      if (!task.demoHistory) continue;
      final quiz = CurriculumData.quizBank[task.subject] ?? CurriculumData.quizBank['Matematika']!;
      final answers = <int>[
        for (int i = 0; i < quiz.length; i++)
          i < 7 ? quiz[i].answerIndex : (quiz[i].answerIndex + 1) % quiz[i].choices.length,
      ];
      map[task.id] = TaskResult(
        score: 7,
        total: 10,
        answers: answers,
        demo: true,
      );
    }
    return map;
  }

  static const List<AnnouncementItem> initialAnnouncements = <AnnouncementItem>[
    AnnouncementItem(
      id: 'a1',
      category: 'KEGIATAN SEKOLAH',
      title: 'Hari Literasi KARSA',
      detail: 'Jumat, 6 November 2026 · Aula sekolah',
      body: 'Mari tumbuhkan kebiasaan membaca melalui kegiatan berbagi cerita dan pojok baca kelas.',
      className: 'Semua kelas',
    ),
    AnnouncementItem(
      id: 'a2',
      category: 'UNTUK ORANG TUA',
      title: 'Pertemuan Wali Murid',
      detail: 'Sabtu, 7 November 2026 · 09.00 WIB',
      body: 'Pertemuan rutin membahas perkembangan belajar dan kegiatan semester.',
      className: 'Semua kelas',
    ),
    AnnouncementItem(
      id: 'a3',
      category: 'PENGINGAT',
      title: 'Pengumpulan tugas mingguan',
      detail: '',
      body: 'Pastikan semua tugas dikumpulkan tepat waktu.',
      className: 'Semua kelas',
    ),
  ];

  static List<ClassMember> waliMembers(String studentName) => <ClassMember>[
        ClassMember(id: 'dimas', name: studentName, icon: '👦🏻'),
        const ClassMember(id: 'sari', name: 'Sari Putri', icon: '👧🏻'),
        const ClassMember(id: 'rafi', name: 'Rafi Pratama', icon: '👦🏻'),
      ];

  static const Map<String, List<String>> exampleRosterByClass = <String, List<String>>{
    'Kelas 1': <String>['Dimas Nugroho', 'Sari Putri', 'Rafi Pratama'],
    'Kelas 2': <String>['Alya Putri', 'Bima Saputra', 'Nadia Lestari'],
    'Kelas 3': <String>['Raka Pratama', 'Citra Maharani', 'Fajar Ramadhan'],
    'Kelas 4': <String>['Nabila Putri', 'Rizky Saputra', 'Intan Sari'],
    'Kelas 5': <String>['Dimas Nugroho', 'Nisa Aulia', 'Bintang Pratama'],
    'Kelas 6': <String>['Adit Prasetyo', 'Dewi Lestari', 'Farhan Maulana'],
  };

  static const List<String> studyTips = <String>[
    'Baca soal pelan-pelan sebelum menjawab.',
    'Istirahat sebentar jika kamu merasa lelah.',
    'Tidak apa-apa bertanya jika belum mengerti.',
  ];
}
