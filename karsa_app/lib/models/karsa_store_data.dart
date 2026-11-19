import '../data/curriculum_data.dart';
import '../data/seed_data.dart';
import 'announcement_item.dart';
import 'attachment_file.dart';
import 'class_event.dart';
import 'local_notification.dart';
import 'material_item.dart';
import 'operator_profile.dart';
import 'remembered_login.dart';
import 'practice_item.dart';
import 'school_class.dart';
import 'staff_account.dart';
import 'student_profile.dart';
import 'task_item.dart';
import 'task_result.dart';

class KarsaStoreData {
  final List<TaskItem> tasks;
  final List<PracticeItem> customPractices;
  final Map<String, TaskResult> results;
  final Map<String, bool> practiceDone;

  /// Skor pilihan ganda per latihan (kunci: id latihan). Skor hanya diisi
  /// setelah siswa menyelesaikan seluruh soal PG; latihan tetap dianggap
  /// selesai lewat `practiceDone` walau baru mengerjakan bagian esai.
  final Map<String, TaskResult> practiceResults;
  final List<AnnouncementItem> announcements;
  final List<String> readAnnouncements;
  final String teacherName;
  final String waliName;
  final String studentName;

  /// Login terakhir yang disimpan lewat "Ingat saya".
  ///
  /// Berisi identitas yang dipakai untuk masuk lagi tanpa mengetik ulang.
  /// Null berarti belum pernah memilih "Ingat saya" (atau sudah keluar).
  final RememberedLogin? rememberedLogin;

  /// Nama operator sekolah.
  final String operatorName;

  /// Profil lengkap operator sekolah: NIP, jabatan, kontak, dan unit kerja.
  /// Disimpan terpisah dari `operatorName` supaya kompatibel dengan data lama
  /// yang hanya punya nama.
  final OperatorProfile operatorProfile;
  final bool notifications;
  final List<String> reviewed;
  final String childClass;
  final String parentClass;
  final String studentClass;
  final String teacherSubject;
  final String religion;
  final String? mood;
  final bool darkMode;
  final Map<String, Map<String, String>> attendance;
  final Map<String, double> classScores;
  final List<ClassEvent> classEvents;
  final List<MaterialItem> materials;
  final List<LocalNotification> localNotifications;
  final Map<String, List<String>> readNotifications;

  /// Grafis yang dikelola operator sekolah (kunci slot -> lampiran).
  final Map<String, AttachmentFile> mediaAssets;

  /// Daftar siswa resmi (dikelola operator sekolah).
  final List<StudentProfile> roster;

  /// Daftar kelas sekolah yang dikelola operator sekolah.
  final List<SchoolClass> schoolClasses;

  /// Akun guru dan wali kelas yang dikelola operator sekolah.
  final List<StaffAccount> staffAccounts;

  /// Nilai ringkas yang diisi operator sekolah untuk setiap siswa.
  /// Kunci: id siswa.
  final Map<String, double> rosterScores;

  const KarsaStoreData({
    required this.tasks,
    required this.customPractices,
    required this.results,
    required this.practiceDone,
    this.practiceResults = const <String, TaskResult>{},
    required this.announcements,
    required this.readAnnouncements,
    required this.teacherName,
    required this.waliName,
    required this.studentName,
    this.rememberedLogin,
    required this.operatorName,
    required this.operatorProfile,
    required this.notifications,
    required this.reviewed,
    required this.childClass,
    required this.parentClass,
    required this.studentClass,
    required this.teacherSubject,
    required this.religion,
    required this.mood,
    required this.darkMode,
    required this.attendance,
    required this.classScores,
    required this.classEvents,
    required this.materials,
    required this.localNotifications,
    required this.readNotifications,
    required this.mediaAssets,
    required this.roster,
    required this.schoolClasses,
    required this.rosterScores,
    required this.staffAccounts,
  });

  factory KarsaStoreData.defaults({DateTime? now}) {
    final seed = SeedData.demoSeedTasks(now ?? DateTime.now());
    final allTasks = <TaskItem>[...SeedData.initialTasks, ...seed];
    return KarsaStoreData(
      tasks: allTasks,
      customPractices: const <PracticeItem>[],
      results: SeedData.demoResults(seed),
      practiceDone: const <String, bool>{},
      practiceResults: const <String, TaskResult>{},
      announcements: SeedData.initialAnnouncements,
      readAnnouncements: const <String>[],
      teacherName: 'Ibu Sari',
      waliName: 'Ibu Sari',
      studentName: 'Dimas Nugroho',
      rememberedLogin: null,
      operatorName: OperatorProfile.defaults().name,
      operatorProfile: OperatorProfile.defaults(),
      notifications: true,
      reviewed: const <String>[],
      childClass: 'Kelas 1',
      parentClass: 'Kelas 1',
      studentClass: 'Kelas 5',
      teacherSubject: 'Matematika',
      religion: '',
      mood: null,
      darkMode: false,
      attendance: const <String, Map<String, String>>{},
      classScores: const <String, double>{},
      classEvents: const <ClassEvent>[],
      materials: SeedData.initialMaterials(now ?? DateTime.now()),
      localNotifications: SeedData.initialNotifications(now ?? DateTime.now()),
      readNotifications: const <String, List<String>>{},
      mediaAssets: const <String, AttachmentFile>{},
      roster: SeedData.initialRoster(),
      schoolClasses: SeedData.initialSchoolClasses(),
      rosterScores: const <String, double>{},
      staffAccounts: SeedData.initialStaffAccounts(),
    );
  }

  KarsaStoreData copyWith({
    List<TaskItem>? tasks,
    List<PracticeItem>? customPractices,
    Map<String, TaskResult>? results,
    Map<String, bool>? practiceDone,
    Map<String, TaskResult>? practiceResults,
    List<AnnouncementItem>? announcements,
    List<String>? readAnnouncements,
    String? teacherName,
    String? waliName,
    String? studentName,
    String? operatorName,
    OperatorProfile? operatorProfile,
    RememberedLogin? rememberedLogin,
    bool clearRememberedLogin = false,
    bool? notifications,
    List<String>? reviewed,
    String? childClass,
    String? parentClass,
    String? studentClass,
    String? teacherSubject,
    String? religion,
    String? mood,
    bool clearMood = false,
    bool? darkMode,
    Map<String, Map<String, String>>? attendance,
    Map<String, double>? classScores,
    List<ClassEvent>? classEvents,
    List<MaterialItem>? materials,
    List<LocalNotification>? localNotifications,
    Map<String, List<String>>? readNotifications,
    Map<String, AttachmentFile>? mediaAssets,
    List<StudentProfile>? roster,
    List<SchoolClass>? schoolClasses,
    Map<String, double>? rosterScores,
    List<StaffAccount>? staffAccounts,
  }) {
    return KarsaStoreData(
      tasks: tasks ?? this.tasks,
      customPractices: customPractices ?? this.customPractices,
      results: results ?? this.results,
      practiceDone: practiceDone ?? this.practiceDone,
      practiceResults: practiceResults ?? this.practiceResults,
      announcements: announcements ?? this.announcements,
      readAnnouncements: readAnnouncements ?? this.readAnnouncements,
      teacherName: teacherName ?? this.teacherName,
      waliName: waliName ?? this.waliName,
      studentName: studentName ?? this.studentName,
      operatorName: operatorName ?? this.operatorName,
      operatorProfile: operatorProfile ?? this.operatorProfile,
      rememberedLogin: clearRememberedLogin
          ? null
          : (rememberedLogin ?? this.rememberedLogin),
      notifications: notifications ?? this.notifications,
      reviewed: reviewed ?? this.reviewed,
      childClass: childClass ?? this.childClass,
      parentClass: parentClass ?? this.parentClass,
      studentClass: studentClass ?? this.studentClass,
      teacherSubject: teacherSubject ?? this.teacherSubject,
      religion: religion ?? this.religion,
      mood: clearMood ? null : (mood ?? this.mood),
      darkMode: darkMode ?? this.darkMode,
      attendance: attendance ?? this.attendance,
      classScores: classScores ?? this.classScores,
      classEvents: classEvents ?? this.classEvents,
      materials: materials ?? this.materials,
      localNotifications: localNotifications ?? this.localNotifications,
      readNotifications: readNotifications ?? this.readNotifications,
      mediaAssets: mediaAssets ?? this.mediaAssets,
      roster: roster ?? this.roster,
      schoolClasses: schoolClasses ?? this.schoolClasses,
      rosterScores: rosterScores ?? this.rosterScores,
      staffAccounts: staffAccounts ?? this.staffAccounts,
    );
  }

  /// Parses JSON saved by either React Native AsyncStorage or Flutter SharedPreferences
  /// under key "@karsa-demo-v1", migrating legacy "IPA" subject names and backfilling missing seed tasks.
  factory KarsaStoreData.fromSavedJson(Map<String, dynamic> saved, {DateTime? now}) {
    final base = KarsaStoreData.defaults(now: now);
    final seedPool = <TaskItem>[...SeedData.initialTasks, ...SeedData.demoSeedTasks(now ?? DateTime.now())];

    final rawTasks = saved['tasks'];
    final savedTasks = rawTasks is List
        ? rawTasks
            .whereType<Map<String, dynamic>>()
            .map((t) => TaskItem.fromJson(t, normalizeSubject: CurriculumData.normalizeSubject))
            .toList()
        : <TaskItem>[];

    final existingIds = savedTasks.map((t) => t.id).toSet();
    final missing = seedPool.where((t) => !existingIds.contains(t.id)).toList();
    final addedResults = SeedData.demoResults(missing);

    final parsedResults = <String, TaskResult>{...addedResults};
    if (saved['results'] is Map) {
      (saved['results'] as Map).forEach((k, v) {
        if (v is Map<String, dynamic>) {
          parsedResults[k.toString()] = TaskResult.fromJson(v);
        } else if (v is Map) {
          parsedResults[k.toString()] =
              TaskResult.fromJson(v.map((ek, ev) => MapEntry(ek.toString(), ev)));
        }
      });
    }

    final parsedPracticeDone = <String, bool>{};
    if (saved['practiceDone'] is Map) {
      (saved['practiceDone'] as Map).forEach((k, v) {
        if (v == true) parsedPracticeDone[k.toString()] = true;
      });
    }

    // Skor latihan; data lama tanpa kunci ini tetap valid (peta kosong).
    final parsedPracticeResults = <String, TaskResult>{};
    if (saved['practiceResults'] is Map) {
      (saved['practiceResults'] as Map).forEach((k, v) {
        if (v is Map) {
          parsedPracticeResults[k.toString()] =
              TaskResult.fromJson(v.map((ek, ev) => MapEntry(ek.toString(), ev)));
        }
      });
    }

    final parsedAttendance = <String, Map<String, String>>{};
    if (saved['attendance'] is Map) {
      (saved['attendance'] as Map).forEach((dateKey, dayMap) {
        if (dayMap is Map) {
          final inner = <String, String>{};
          dayMap.forEach((mId, st) {
            if (st != null) inner[mId.toString()] = st.toString();
          });
          parsedAttendance[dateKey.toString()] = inner;
        }
      });
    }

    final parsedScores = <String, double>{};
    if (saved['classScores'] is Map) {
      (saved['classScores'] as Map).forEach((mId, val) {
        if (val is num && val.isFinite) {
          parsedScores[mId.toString()] = val.toDouble();
        }
      });
    }

    final parsedMaterials = <String, dynamic>{};
    if (saved['materials'] is List) {
      (saved['materials'] as List).whereType<Map>().forEach((m) {
        final id = (m['id'] ?? '').toString();
        parsedMaterials[id] = m;
      });
    }
    for (final seeded in base.materials) {
      parsedMaterials.putIfAbsent(seeded.id, () => seeded.toJson());
    }

    final parsedNotifications = <String, dynamic>{};
    if (saved['localNotifications'] is List) {
      (saved['localNotifications'] as List).whereType<Map>().forEach((n) {
        final id = (n['id'] ?? '').toString();
        parsedNotifications[id] = n;
      });
    }
    for (final seeded in base.localNotifications) {
      parsedNotifications.putIfAbsent(seeded.id, () => seeded.toJson());
    }

    final parsedMediaAssets = <String, AttachmentFile>{};
    if (saved['mediaAssets'] is Map) {
      (saved['mediaAssets'] as Map).forEach((key, value) {
        if (value is Map) {
          parsedMediaAssets[key.toString()] = AttachmentFile.fromJson(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
        }
      });
    }

    final parsedRoster = <String, dynamic>{};
    if (saved['roster'] is List) {
      (saved['roster'] as List).whereType<Map>().forEach((r) {
        final id = (r['id'] ?? '').toString();
        parsedRoster[id] = r;
      });
    }
    if (saved['roster'] is! List) {
      // Data lama yang belum punya roster memakai siswa bawaan. Kalau daftar
      // roster sudah tersimpan, isi operator dihormati apa adanya supaya
      // siswa yang dihapus tidak muncul lagi setelah aplikasi dibuka ulang.
      for (final seeded in base.roster) {
        parsedRoster[seeded.id] = seeded.toJson();
      }
    }

    final parsedSchoolClasses = <String, dynamic>{};
    if (saved['schoolClasses'] is List) {
      (saved['schoolClasses'] as List).whereType<Map>().forEach((c) {
        final id = (c['id'] ?? '').toString();
        parsedSchoolClasses[id] = c;
      });
    }
    if (saved['schoolClasses'] is! List) {
      // Hanya data lama tanpa daftar kelas yang memakai kelas bawaan.
      // Kelas yang dihapus operator tidak boleh dibangkitkan lagi.
      for (final seeded in base.schoolClasses) {
        parsedSchoolClasses[seeded.id] = seeded.toJson();
      }
    }

    final parsedRosterScores = <String, double>{};
    if (saved['rosterScores'] is Map) {
      (saved['rosterScores'] as Map).forEach((k, v) {
        if (v is num && v.isFinite) {
          parsedRosterScores[k.toString()] = v.toDouble();
        }
      });
    }

    final parsedStaffAccounts = <String, dynamic>{};
    if (saved['staffAccounts'] is List) {
      (saved['staffAccounts'] as List).whereType<Map>().forEach((a) {
        final id = (a['id'] ?? '').toString();
        parsedStaffAccounts[id] = a;
      });
    }
    if (saved['staffAccounts'] is! List) {
      // Hanya data lama tanpa daftar akun yang memakai akun bawaan.
      // Akun yang dihapus operator tidak boleh dibangkitkan lagi.
      for (final seeded in base.staffAccounts) {
        parsedStaffAccounts[seeded.id] = seeded.toJson();
      }
    }

    final parsedReadNotifications = <String, List<String>>{};
    if (saved['readNotifications'] is Map) {
      (saved['readNotifications'] as Map).forEach((key, list) {
        if (list is List) {
          parsedReadNotifications[key.toString()] = list.map((e) => e.toString()).toList();
        }
      });
    }

    return KarsaStoreData(
      tasks: <TaskItem>[...savedTasks, ...missing],
      customPractices: (saved['customPractices'] is List)
          ? (saved['customPractices'] as List)
              .whereType<Map>()
              .map((p) => PracticeItem.fromJson(
                    p.map((k, v) => MapEntry(k.toString(), v)),
                    normalizeSubject: CurriculumData.normalizeSubject,
                  ))
              .toList()
          : const <PracticeItem>[],
      results: parsedResults,
      practiceDone: parsedPracticeDone,
      practiceResults: parsedPracticeResults,
      announcements: (saved['announcements'] is List)
          ? (saved['announcements'] as List)
              .whereType<Map>()
              .map((a) => AnnouncementItem.fromJson(a.map((k, v) => MapEntry(k.toString(), v))))
              .toList()
          : base.announcements,
      readAnnouncements: (saved['readAnnouncements'] is List)
          ? (saved['readAnnouncements'] as List).map((e) => e.toString()).toList()
          : const <String>[],
      teacherName: (saved['teacherName'] ?? base.teacherName).toString(),
      waliName: (saved['waliName'] ?? base.waliName).toString(),
      studentName: (saved['studentName'] ?? base.studentName).toString(),
      operatorName: (saved['operatorName'] ?? base.operatorName).toString(),
      rememberedLogin: RememberedLogin.fromSaved(saved['rememberedLogin']),
      operatorProfile: OperatorProfile.fromSaved(
        saved['operatorProfile'],
        fallbackName: (saved['operatorName'] ?? base.operatorName).toString(),
      ),
      notifications: saved['notifications'] is bool ? saved['notifications'] as bool : true,
      reviewed: (saved['reviewed'] is List)
          ? (saved['reviewed'] as List).map((e) => e.toString()).toList()
          : const <String>[],
      childClass: (saved['childClass'] ?? base.childClass).toString(),
      parentClass: (saved['parentClass'] ?? base.parentClass).toString(),
      studentClass: (saved['studentClass'] ?? base.studentClass).toString(),
      teacherSubject: CurriculumData.normalizeSubject(
        saved['teacherSubject']?.toString() ?? base.teacherSubject,
      ),
      religion: (saved['religion'] ?? '').toString(),
      mood: saved['mood']?.toString(),
      darkMode: saved['darkMode'] == true,
      attendance: parsedAttendance,
      classScores: parsedScores,
      classEvents: (saved['classEvents'] is List)
          ? (saved['classEvents'] as List)
              .whereType<Map>()
              .map((e) => ClassEvent.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
              .toList()
          : const <ClassEvent>[],
      materials: parsedMaterials.values
          .whereType<Map>()
          .map((m) => MaterialItem.fromJson(
                m.map((k, v) => MapEntry(k.toString(), v)),
                normalizeSubject: CurriculumData.normalizeSubject,
              ))
          .toList(),
      localNotifications: parsedNotifications.values
          .whereType<Map>()
          .map((n) => LocalNotification.fromJson(
                n.map((k, v) => MapEntry(k.toString(), v)),
                normalizeSubject: CurriculumData.normalizeSubject,
              ))
          .toList(),
      readNotifications: parsedReadNotifications,
      mediaAssets: parsedMediaAssets,
      roster: parsedRoster.values
          .whereType<Map>()
          .map((r) => StudentProfile.fromJson(
                r.map((k, v) => MapEntry(k.toString(), v)),
              ))
          .toList(),
      rosterScores: parsedRosterScores,
      staffAccounts: parsedStaffAccounts.values
          .whereType<Map>()
          .map((a) => StaffAccount.fromJson(
                a.map((k, v) => MapEntry(k.toString(), v)),
              ))
          .toList(),
      schoolClasses: parsedSchoolClasses.values
          .whereType<Map>()
          .map((c) => SchoolClass.fromJson(
                c.map((k, v) => MapEntry(k.toString(), v)),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final serializedScores = <String, num>{};
    classScores.forEach((k, v) {
      serializedScores[k] = (v == v.roundToDouble()) ? v.toInt() : v;
    });

    return <String, dynamic>{
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'customPractices': customPractices.map((p) => p.toJson()).toList(),
      'results': results.map((k, v) => MapEntry(k, v.toJson())),
      'practiceDone': practiceDone,
      'practiceResults':
          practiceResults.map((k, v) => MapEntry(k, v.toJson())),
      'announcements': announcements.map((a) => a.toJson()).toList(),
      'readAnnouncements': readAnnouncements,
      'teacherName': teacherName,
      'waliName': waliName,
      'studentName': studentName,
      'operatorName': operatorName,
      'operatorProfile': operatorProfile.toJson(),
      'rememberedLogin': rememberedLogin?.toJson(),
      'notifications': notifications,
      'reviewed': reviewed,
      'childClass': childClass,
      'parentClass': parentClass,
      'studentClass': studentClass,
      'teacherSubject': teacherSubject,
      'religion': religion,
      'mood': mood,
      'darkMode': darkMode,
      'attendance': attendance,
      'classScores': serializedScores,
      'classEvents': classEvents.map((e) => e.toJson()).toList(),
      'materials': materials.map((m) => m.toJson()).toList(),
      'localNotifications': localNotifications.map((n) => n.toJson()).toList(),
      'readNotifications': readNotifications,
      'mediaAssets': mediaAssets.map((k, v) => MapEntry(k, v.toJson())),
      'roster': roster.map((r) => r.toJson()).toList(),
      'schoolClasses': schoolClasses.map((c) => c.toJson()).toList(),
      'rosterScores': rosterScores,
      'staffAccounts': staffAccounts.map((a) => a.toJson()).toList(),
    };
  }
}
