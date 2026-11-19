import '../models/announcement_item.dart';
import '../models/class_member.dart';
import '../models/local_notification.dart';
import '../models/material_item.dart';
import '../models/practice_item.dart';
import '../models/school_class.dart';
import '../models/staff_account.dart';
import '../models/student_profile.dart';
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

  /// Materi demo. Termasuk kelas 1 (anak orang tua) dan kelas 5-6 (siswa)
  /// supaya kartu "Materi kelas" dan layar Materi tidak kosong.
  static List<MaterialItem> initialMaterials(DateTime now) {
    final made = DateTime(now.year, now.month, now.day, 7, 30).toUtc();
    return <MaterialItem>[
      MaterialItem(
        id: 'm1',
        subject: 'Matematika',
        className: 'Kelas 1',
        title: 'Ringkasan Pecahan',
        summary: 'Pengenalan pecahan sederhana untuk siswa kelas 1.',
        teacher: 'Ibu Sari',
      ),
      MaterialItem(
        id: 'm2',
        subject: 'Bahasa Indonesia',
        className: 'Kelas 1',
        title: 'Contoh Kalimat Sederhana',
        summary: 'Kumpulan contoh kalimat sederhana beserta latihan membaca.',
        teacher: 'Ibu Sari',
      ),
      MaterialItem(
        id: 'm3',
        subject: 'Matematika',
        className: 'Kelas 5',
        title: 'Ringkasan Pecahan Kelas 5',
        summary:
            'Penjelasan pecahan, perbandingan, dan cara menyederhanakan bilangan pecahan.',
        teacher: 'Ibu Sari',
      ),
      MaterialItem(
        id: 'm4',
        subject: 'Bahasa Indonesia',
        className: 'Kelas 5',
        title: 'Contoh Menyinggung Kalimat',
        summary: 'Contoh kalimat berhias beserta latihan menentukan jenis majas.',
        teacher: 'Ibu Sari',
      ),
    ];
  }

  /// Daftar siswa resmi per kelas. Dipakai role operator sekolah untuk
  /// menambah, mengubah, dan menghapus data siswa.
  static List<StudentProfile> initialRoster() {
    const seeds = <List<String>>[
      <String>['s1a', '10050002', 'Aisyah Putri', 'Kelas 1', 'P', 'Ibu Rina'],
      <String>['s1b', '10050003', 'Bagas Wicaksono', 'Kelas 1', 'L', 'Bapak Doni'],
      <String>['s1c', '10050004', 'Citra Kirana', 'Kelas 1', 'P', 'Ibu Melati'],
      <String>['s1d', '10050005', 'Dimas Nugroho', 'Kelas 1', 'L', 'Bapak Hendra'],
      <String>['s2a', '10050006', 'Eka Prasetyo', 'Kelas 2', 'L', 'Bapak Joko'],
      <String>['s2b', '10050007', 'Fitri Handayani', 'Kelas 2', 'P', 'Ibu Sari'],
      <String>['s2c', '10050008', 'Gilang Ramadhan', 'Kelas 2', 'L', 'Bapak Arif'],
      <String>['s2d', '10050009', 'Hana Salsabila', 'Kelas 2', 'P', 'Ibu Yuni'],
      <String>['s3a', '10050010', 'Indira Maharani', 'Kelas 3', 'P', 'Ibu Ratna'],
      <String>['s3b', '10050011', 'Jovan Kurniawan', 'Kelas 3', 'L', 'Bapak Teguh'],
      <String>['s3c', '10050012', 'Kirana Ayu', 'Kelas 3', 'P', 'Ibu Wulan'],
      <String>['s3d', '10050013', 'Lukman Hakim', 'Kelas 3', 'L', 'Bapak Slamet'],
      <String>['s4a', '10050014', 'Maya Anggraini', 'Kelas 4', 'P', 'Ibu Dyah'],
      <String>['s4b', '10050015', 'Naufal Akbar', 'Kelas 4', 'L', 'Bapak Rudi'],
      <String>['s4c', '10050016', 'Nabila Zahra', 'Kelas 4', 'P', 'Ibu Eka'],
      <String>['s4d', '10050017', 'Omar Dzaki', 'Kelas 4', 'L', 'Bapak Irwan'],
      <String>['s5a', '10050018', 'Puspita Rani', 'Kelas 5', 'P', 'Ibu Lilis'],
      <String>['s5b', '10050019', 'Rendi Saputra', 'Kelas 5', 'L', 'Bapak Cahyo'],
      <String>['s5c', '10050020', 'Sekar Arum', 'Kelas 5', 'P', 'Ibu Nining'],
      <String>['s5d', '10050021', 'Taufik Hidayat', 'Kelas 5', 'L', 'Bapak Wahyu'],
      <String>['s6a', '10050022', 'Ulfa Rahmawati', 'Kelas 6', 'P', 'Ibu Tati'],
      <String>['s6b', '10050023', 'Vino Ardiansyah', 'Kelas 6', 'L', 'Bapak Gunawan'],
      <String>['s6c', '10050024', 'Wulan Puspita', 'Kelas 6', 'P', 'Ibu Rina'],
      <String>['s6d', '10050025', 'Yoga Pratama', 'Kelas 6', 'L', 'Bapak Farid'],
    ];
    return seeds
        .map((row) => StudentProfile(
              id: row[0],
              nisn: row[1],
              name: row[2],
              className: row[3],
              gender: row[4],
              parentName: row[5],
            ))
        .toList();
  }

  /// Kelas sekolah bawaan. Operator sekolah bisa menambah, mengubah, dan
  /// menghapus kelas beserta wali kelasnya.
  static List<SchoolClass> initialSchoolClasses() {
    const seeds = <List<String>>[
      <String>['c1', 'Kelas 1', 'Ibu Sari'],
      <String>['c2', 'Kelas 2', 'Ibu Tuti'],
      <String>['c3', 'Kelas 3', 'Bapak Agus'],
      <String>['c4', 'Kelas 4', 'Ibu Rina'],
      <String>['c5', 'Kelas 5', 'Bapak Doni'],
      <String>['c6', 'Kelas 6', 'Ibu Maya'],
    ];
    return seeds
        .map((row) => SchoolClass(
              id: row[0],
              name: row[1],
              teacherName: row[2],
            ))
        .toList();
  }

  /// Akun guru dan wali kelas bawaan. Operator sekolah bisa menambah,
  /// mengubah, dan menghapus akun ini.
  static List<StaffAccount> initialStaffAccounts() {
    const seeds = <List<String>>[
      <String>['u1', 'Ibu Sari', '19870001', 'wali', 'Kelas 1'],
      <String>['u2', 'Ibu Tuti', '19870011', 'wali', 'Kelas 2'],
      <String>['u3', 'Bapak Agus', '19870012', 'wali', 'Kelas 3'],
      <String>['u4', 'Ibu Rina', '19870013', 'wali', 'Kelas 4'],
      <String>['u5', 'Bapak Doni', '19870014', 'wali', 'Kelas 5'],
      <String>['u6', 'Ibu Maya', '19870015', 'wali', 'Kelas 6'],
      <String>['u7', 'Pak Rudi', '19870021', 'guru', ''],
    ];
    return seeds
        .map((row) => StaffAccount(
              id: row[0],
              name: row[1],
              nip: row[2],
              role: row[3],
              className: row[4],
            ))
        .toList();
  }

  /// Notifikasi demo untuk guru, orang tua, dan siswa (kelas 1 dan kelas 5).
  static List<LocalNotification> initialNotifications(DateTime now) {
    LocalNotification make({
      required String id,
      required String target,
      required String subject,
      required String className,
      required String title,
      required String kind,
      required String contentId,
      required int hoursAgo,
      String? studentName,
      int? score,
      int? total,
    }) {
      return LocalNotification(
        id: id,
        target: target,
        subject: subject,
        className: className,
        title: title,
        kind: kind,
        contentId: contentId,
        studentName: studentName,
        score: score,
        total: total,
        createdAt:
            DateTime(now.year, now.month, now.day, 7, 30).subtract(Duration(hours: hoursAgo))
                .toUtc()
                .toIso8601String(),
      );
    }

    return <LocalNotification>[
      make(
        id: 'n1',
        target: 'learners',
        subject: 'Matematika',
        className: 'Kelas 1',
        title: 'Tugas baru · Penjumlahan sampai 20',
        kind: 'task',
        contentId: 't1',
        hoursAgo: 1,
      ),
      make(
        id: 'n2',
        target: 'learners',
        subject: 'Bahasa Indonesia',
        className: 'Kelas 1',
        title: 'Materi baru · Membaca kalimat',
        kind: 'material',
        contentId: 'm1',
        hoursAgo: 2,
      ),
      // Guru perlu tahu SIAPA yang mengumpulkan dan nilainya.
      make(
        id: 'n3',
        target: 'teachers',
        subject: 'Matematika',
        className: 'Kelas 1',
        title: 'Aisyah Putri mengumpulkan Matematika',
        kind: 'submission',
        contentId: 't1',
        hoursAgo: 3,
        studentName: 'Aisyah Putri',
        score: 9,
        total: 10,
      ),
      make(
        id: 'n4',
        target: 'learners',
        subject: 'Matematika',
        className: 'Kelas 5',
        title: 'Tugas baru · Pecahan dan perbandingan',
        kind: 'task',
        contentId: 'seed5',
        hoursAgo: 1,
      ),
      make(
        id: 'n5',
        target: 'learners',
        subject: 'Bahasa Indonesia',
        className: 'Kelas 5',
        title: 'Materi baru · Ringkasan Pecahan Kelas 5',
        kind: 'material',
        contentId: 'm3',
        hoursAgo: 2,
      ),
    ];
  }

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
