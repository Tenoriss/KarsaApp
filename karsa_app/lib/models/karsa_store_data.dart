import '../data/curriculum_data.dart';
import '../data/seed_data.dart';
import 'announcement_item.dart';
import 'class_event.dart';
import 'local_notification.dart';
import 'material_item.dart';
import 'practice_item.dart';
import 'task_item.dart';
import 'task_result.dart';

class KarsaStoreData {
  final List<TaskItem> tasks;
  final List<PracticeItem> customPractices;
  final Map<String, TaskResult> results;
  final Map<String, bool> practiceDone;
  final List<AnnouncementItem> announcements;
  final List<String> readAnnouncements;
  final String teacherName;
  final String waliName;
  final String studentName;
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

  const KarsaStoreData({
    required this.tasks,
    required this.customPractices,
    required this.results,
    required this.practiceDone,
    required this.announcements,
    required this.readAnnouncements,
    required this.teacherName,
    required this.waliName,
    required this.studentName,
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
  });

  factory KarsaStoreData.defaults({DateTime? now}) {
    final seed = SeedData.demoSeedTasks(now ?? DateTime.now());
    final allTasks = <TaskItem>[...SeedData.initialTasks, ...seed];
    return KarsaStoreData(
      tasks: allTasks,
      customPractices: const <PracticeItem>[],
      results: SeedData.demoResults(seed),
      practiceDone: const <String, bool>{},
      announcements: SeedData.initialAnnouncements,
      readAnnouncements: const <String>[],
      teacherName: 'Ibu Sari',
      waliName: 'Ibu Sari',
      studentName: 'Dimas Nugroho',
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
      materials: const <MaterialItem>[],
      localNotifications: const <LocalNotification>[],
      readNotifications: const <String, List<String>>{},
    );
  }

  KarsaStoreData copyWith({
    List<TaskItem>? tasks,
    List<PracticeItem>? customPractices,
    Map<String, TaskResult>? results,
    Map<String, bool>? practiceDone,
    List<AnnouncementItem>? announcements,
    List<String>? readAnnouncements,
    String? teacherName,
    String? waliName,
    String? studentName,
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
  }) {
    return KarsaStoreData(
      tasks: tasks ?? this.tasks,
      customPractices: customPractices ?? this.customPractices,
      results: results ?? this.results,
      practiceDone: practiceDone ?? this.practiceDone,
      announcements: announcements ?? this.announcements,
      readAnnouncements: readAnnouncements ?? this.readAnnouncements,
      teacherName: teacherName ?? this.teacherName,
      waliName: waliName ?? this.waliName,
      studentName: studentName ?? this.studentName,
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
      materials: (saved['materials'] is List)
          ? (saved['materials'] as List)
              .whereType<Map>()
              .map((m) => MaterialItem.fromJson(
                    m.map((k, v) => MapEntry(k.toString(), v)),
                    normalizeSubject: CurriculumData.normalizeSubject,
                  ))
              .toList()
          : const <MaterialItem>[],
      localNotifications: (saved['localNotifications'] is List)
          ? (saved['localNotifications'] as List)
              .whereType<Map>()
              .map((n) => LocalNotification.fromJson(
                    n.map((k, v) => MapEntry(k.toString(), v)),
                    normalizeSubject: CurriculumData.normalizeSubject,
                  ))
              .toList()
          : const <LocalNotification>[],
      readNotifications: parsedReadNotifications,
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
      'announcements': announcements.map((a) => a.toJson()).toList(),
      'readAnnouncements': readAnnouncements,
      'teacherName': teacherName,
      'waliName': waliName,
      'studentName': studentName,
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
    };
  }
}
