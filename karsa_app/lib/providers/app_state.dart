import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/date_utils.dart';
import '../core/utils/offline_summarizer.dart';
import '../data/curriculum_data.dart';
import '../data/seed_data.dart';
import '../models/announcement_item.dart';
import '../models/attachment_file.dart';
import '../models/class_event.dart';
import '../models/class_grade_summary.dart';
import '../models/class_member.dart';
import '../models/demo_account.dart';
import '../models/grade_report_row.dart';
import '../models/karsa_store_data.dart';
import '../models/local_notification.dart';
import '../models/material_item.dart';
import '../models/practice_item.dart';
import '../models/quiz_question.dart';
import '../models/task_item.dart';
import '../models/task_result.dart';
import '../models/user_role.dart';
import '../services/attachment_service.dart';
import '../services/grade_export_service.dart';
import '../services/storage_service.dart';

class StudentDetailSelection {
  final String title;
  final String body;

  const StudentDetailSelection({
    required this.title,
    required this.body,
  });
}

class AppState extends ChangeNotifier {
  final StorageService _storageService;
  final AttachmentService _attachmentService;
  final GradeExportService _gradeExportService;

  KarsaStoreData _data = KarsaStoreData.defaults();
  bool _loaded = false;
  bool _storageError = false;

  String _screen = 'splash';
  UserRole? _role;
  String _tab = 'Beranda';
  String _filter = 'Semua kelas';
  String _taskFilter = 'Semua';

  TaskItem? _selectedTask;
  PracticeItem? _selectedPractice;
  AnnouncementItem? _selectedAnnouncement;
  MaterialItem? _selectedMaterial;
  ClassEvent? _selectedEvent;
  StudentDetailSelection? _selectedStudentDetail;

  String _returnScreen = 'main';
  int _questionIndex = 0;
  int? _choiceIndex;
  bool _checked = false;
  List<int> _answers = <int>[];
  String _essay = '';
  bool _showExample = false;

  int _month1Based = DateTime.now().month;
  int _year = DateTime.now().year;
  int _day = DateTime.now().day;

  String _username = '';
  String _password = '';
  bool _showPassword = false;

  String _draftTitle = '';
  String _draftBody = '';
  String _draftSubject = 'Matematika';
  String _draftClass = 'Kelas 1';
  String _draftMinutes = '30';
  String _draftDue = '';
  String _error = '';
  String _notice = '';
  String _setting = '';
  String _subjectTab = 'Tugas';
  String _search = '';
  int _tipIndex = 0;

  AttachmentFile? _attachment;
  String _sourceText = '';
  String _summaryText = '';

  String _recapTab = 'Kehadiran';
  String _recapDate = KarsaDateUtils.formatDateKey(DateTime.now());
  String? _memberId;
  String _scoreDraft = '';
  String _eventDate = '';

  String _subjectFilter = 'Semua';
  String _learnerSubjectTab = 'Tugas';
  DateTime _now = DateTime.now();

  String _gradeClass = 'Kelas 1';
  String _gradeReturn = 'main';
  bool _exporting = false;

  Timer? _clockTimer;

  AppState({
    StorageService? storageService,
    AttachmentService? attachmentService,
    GradeExportService? gradeExportService,
    bool autoLoad = true,
  })  : _storageService = storageService ?? const StorageService(),
        _attachmentService = attachmentService ?? const AttachmentService(),
        _gradeExportService = gradeExportService ?? const GradeExportService() {
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
    if (autoLoad) {
      loadFromStorage();
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  // Getters
  KarsaStoreData get data => _data;
  bool get loaded => _loaded;
  bool get storageError => _storageError;
  String get screen => _screen;
  UserRole? get role => _role;
  String get tab => _tab;
  String get filter => _filter;
  String get taskFilter => _taskFilter;

  TaskItem? get selectedTask => _selectedTask;
  PracticeItem? get selectedPractice => _selectedPractice;
  AnnouncementItem? get selectedAnnouncement => _selectedAnnouncement;
  MaterialItem? get selectedMaterial => _selectedMaterial;
  ClassEvent? get selectedEvent => _selectedEvent;
  StudentDetailSelection? get selectedStudentDetail => _selectedStudentDetail;

  String get returnScreen => _returnScreen;
  int get questionIndex => _questionIndex;
  int? get choiceIndex => _choiceIndex;
  bool get checked => _checked;
  List<int> get answers => _answers;
  String get essay => _essay;
  bool get showExample => _showExample;

  int get month1Based => _month1Based;
  int get year => _year;
  int get day => _day;

  String get username => _username;
  String get password => _password;
  bool get showPassword => _showPassword;

  String get draftTitle => _draftTitle;
  String get draftBody => _draftBody;
  String get draftSubject => _draftSubject;
  String get draftClass => _draftClass;
  String get draftMinutes => _draftMinutes;
  String get draftDue => _draftDue;
  String get error => _error;
  String get notice => _notice;
  String get setting => _setting;
  String get subjectTab => _subjectTab;
  String get search => _search;
  int get tipIndex => _tipIndex;

  AttachmentFile? get attachment => _attachment;
  String get sourceText => _sourceText;
  String get summaryText => _summaryText;

  String get recapTab => _recapTab;
  String get recapDate => _recapDate;
  String? get memberId => _memberId;
  String get scoreDraft => _scoreDraft;
  String get eventDate => _eventDate;

  String get subjectFilter => _subjectFilter;
  String get learnerSubjectTab => _learnerSubjectTab;
  DateTime get now => _now;

  String get gradeClass => _gradeClass;
  String get gradeReturn => _gradeReturn;
  bool get exporting => _exporting;

  bool get isDark => _data.darkMode;
  bool get isTeacher => _role?.isTeacher ?? false;
  bool get isWali => _role?.isWali ?? false;
  bool get isGuru => _role?.isGuru ?? false;
  bool get isStudent => _role?.isStudent ?? false;
  bool get isParent => _role?.isParent ?? false;

  bool get isSheetScreen => _screen == 'taskDetail' || _screen == 'practiceDetail';

  List<ClassMember> get classMembers => SeedData.waliMembers(_data.studentName);

  List<PracticeItem> get allPractices => <PracticeItem>[
        ...SeedData.defaultPractices,
        ..._data.customPractices,
      ];

  List<PracticeItem> get visiblePractices {
    final allowedSubjects = CurriculumData.subjectsForClass(_data.childClass);
    return allPractices
        .where(
          (p) =>
              (p.className == null || p.className == _data.childClass) &&
              allowedSubjects.contains(p.subject),
        )
        .toList();
  }

  int get donePracticeCount =>
      visiblePractices.where((p) => _data.practiceDone[p.id] == true).length;

  List<TaskItem> get activeTasks {
    final allowedSubjects = CurriculumData.subjectsForClass(_data.childClass);
    return _data.tasks
        .where(
          (t) =>
              t.className == _data.childClass &&
              allowedSubjects.contains(t.subject) &&
              !_data.results.containsKey(t.id),
        )
        .toList();
  }

  List<AnnouncementItem> get visibleAnnouncements {
    return _data.announcements.where((a) {
      if (isWali) {
        return a.className == 'Semua kelas' || a.className == AppConstants.waliClass;
      }
      return isTeacher ||
          a.className == 'Semua kelas' ||
          a.className == _data.childClass;
    }).toList();
  }

  int get unreadAnnouncementsCount => visibleAnnouncements
      .where((a) => !_data.readAnnouncements.contains(a.id))
      .length;

  List<LocalNotification> get relevantNotifications {
    return _data.localNotifications.where((n) {
      if (isTeacher) {
        return n.target == 'teachers' &&
            (!isGuru || n.subject == _data.teacherSubject) &&
            (!isWali || n.className == AppConstants.waliClass);
      }
      return n.target == 'learners' && n.className == _data.childClass;
    }).toList();
  }

  String get notificationKey {
    if (_role == null) return 'guest';
    return isTeacher ? _role!.key : '${_role!.key}:${_data.childClass}';
  }

  bool isNotificationRead(String id) {
    final readIds = _data.readNotifications[notificationKey] ?? const <String>[];
    return readIds.contains(id);
  }

  int get unreadEventsCount =>
      relevantNotifications.where((n) => !isNotificationRead(n.id)).length;

  int get totalBadgeCount =>
      _data.notifications ? (unreadAnnouncementsCount + unreadEventsCount) : 0;

  List<TaskItem> get educatorTasks {
    return _data.tasks.where((t) {
      if (isWali && t.className != AppConstants.waliClass) return false;
      if (_filter != 'Semua kelas' && t.className != _filter) return false;
      if (isGuru && t.subject != _data.teacherSubject) return false;
      return true;
    }).toList();
  }

  String get todayKey => KarsaDateUtils.formatDateKey(DateTime.now());
  Map<String, String> get dayAttendance =>
      _data.attendance[_recapDate] ?? const <String, String>{};
  Map<String, String> get todayAttendance =>
      _data.attendance[todayKey] ?? const <String, String>{};

  int recordsForTodayStatus(String status) =>
      classMembers.where((m) => todayAttendance[m.id] == status).length;

  List<ClassMember> get scoredMembers =>
      classMembers.where((m) => _data.classScores.containsKey(m.id)).toList();

  int? get scoreAverage {
    final members = scoredMembers;
    if (members.isEmpty) return null;
    final sum = members.fold<double>(
      0.0,
      (acc, m) => acc + (_data.classScores[m.id] ?? 0.0),
    );
    return (sum / members.length).round();
  }

  /// Kelas yang dipakai untuk ringkasan nilai: siswa memakai kelasnya sendiri,
  /// orang tua memakai kelas anaknya. Guru dan wali memakai kelas.filter.
  String get learnerClassName {
    if (isStudent) return _data.studentClass;
    if (isParent) return _data.childClass;
    if (_filter != 'Semua kelas') return _filter;
    return _data.childClass;
  }

  /// Ringkasan nilai kelas per mata pelajaran, dihitung dari hasil kuis yang
  /// sudah dikerjakan pada perangkat ini. Mata pelajaran tanpa nilai tetap
  /// ditampilkan dengan status "Belum ada nilai" (bukan nol).
  List<ClassGradeSummary> get classGradeSummaries {
    final className = learnerClassName;
    final allowed = CurriculumData.subjectsForClass(className);
    final buckets = <String, List<double>>{};
    final totals = <String, int>{};

    for (final task in _data.tasks) {
      if (task.className != className) continue;
      if (!allowed.contains(task.subject)) continue;
      totals[task.subject] = (totals[task.subject] ?? 0) + 1;
      final result = _data.results[task.id];
      if (result == null) continue;
      final score = result.score;
      final total = result.total;
      if (score == null || total == null || total <= 0) continue;
      buckets
          .putIfAbsent(task.subject, () => <double>[])
          .add(score * 100 / total);
    }

    final summaries = <ClassGradeSummary>[];
    for (final subject in allowed) {
      final totalTasks = totals[subject] ?? 0;
      if (totalTasks == 0) continue;
      final scores = buckets[subject] ?? const <double>[];
      final average = scores.isEmpty
          ? 0.0
          : scores.reduce((a, b) => a + b) / scores.length;
      summaries.add(
        ClassGradeSummary(
          subject: subject,
          gradedTasks: scores.length,
          totalTasks: totalTasks,
          average: average,
        ),
      );
    }
    return summaries;
  }

  /// Rata-rata seluruh nilai kelas (0-100). Null ketika belum ada nilai.
  int? get classGradeAverage {
    final graded = classGradeSummaries.where((s) => s.gradedTasks > 0).toList();
    if (graded.isEmpty) return null;
    final sum = graded.fold<double>(0.0, (acc, s) => acc + s.average);
    return (sum / graded.length).round();
  }

  /// Jumlah tugas yang sudah dinilai pada kelas aktif.
  int get classGradedTaskCount => classGradeSummaries.fold<int>(
        0,
        (acc, s) => acc + s.gradedTasks,
      );

  Future<void> loadFromStorage() async {
    _data = await _storageService.load(now: DateTime.now());
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persistData(KarsaStoreData next) async {
    _data = next;
    notifyListeners();
    if (_loaded) {
      final ok = await _storageService.save(next);
      if (_storageError != !ok) {
        _storageError = !ok;
        notifyListeners();
      }
    }
  }

  void refreshNow() {
    _now = DateTime.now();
    notifyListeners();
  }

  // Navigation & Auth
  void finishSplash() {
    if (_screen == 'splash') {
      _screen = 'welcome';
      notifyListeners();
    }
  }

  void setScreen(String nextScreen) {
    _screen = nextScreen;
    notifyListeners();
  }

  void selectRoleForLogin(UserRole selectedRole) {
    _role = selectedRole;
    _username = '';
    _password = '';
    _showPassword = false;
    _error = '';
    _screen = 'login';
    notifyListeners();
  }

  void setUsername(String val) {
    _username = val;
    if (_error.isNotEmpty) _error = '';
    notifyListeners();
  }

  void setPassword(String val) {
    _password = val;
    if (_error.isNotEmpty) _error = '';
    notifyListeners();
  }

  void toggleShowPassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  bool authenticate([String? customUsername, String? customPassword]) {
    if (_role == null) return false;
    final account = DemoAccount.forRole(_role!);
    final userIn = (customUsername ?? _username).trim();
    final passIn = customPassword ?? _password;

    if (userIn != account.id || passIn != account.password) {
      _error = 'NIP/NISN atau kata sandi tidak sesuai.';
      notifyListeners();
      return false;
    }

    var nextData = _data;
    if (_role == UserRole.siswa) {
      final targetClass = AppConstants.studentClasses.contains(_data.studentClass)
          ? _data.studentClass
          : 'Kelas 5';
      nextData = nextData.copyWith(childClass: targetClass);
    } else if (_role == UserRole.orangtua) {
      final targetClass = AppConstants.parentClasses.contains(_data.parentClass)
          ? _data.parentClass
          : 'Kelas 1';
      nextData = nextData.copyWith(childClass: targetClass);
    }

    _error = '';
    _filter = _role == UserRole.wali ? AppConstants.waliClass : 'Semua kelas';
    _tab = 'Beranda';
    _taskFilter = _role!.isTeacher ? 'Semua' : 'Aktif';
    _screen = 'main';
    _persistData(nextData);
    return true;
  }

  void logout() {
    _role = null;
    _screen = 'welcome';
    _username = '';
    _password = '';
    _error = '';
    notifyListeners();
  }

  void toggleDarkMode() {
    _persistData(_data.copyWith(darkMode: !_data.darkMode));
  }

  void setDarkMode(bool value) {
    _persistData(_data.copyWith(darkMode: value));
  }

  void setNotificationsEnabled(bool value) {
    _persistData(_data.copyWith(notifications: value));
  }

  void changeTab(String nextTab) {
    _tab = nextTab;
    if (nextTab == 'Tugas') {
      _subjectFilter = 'Semua';
      _learnerSubjectTab = 'Tugas';
    }
    _taskFilter = isTeacher ? 'Semua' : 'Aktif';
    _screen = 'main';
    notifyListeners();
  }

  void setFilter(String classFilter) {
    _filter = classFilter;
    notifyListeners();
  }

  void setTaskFilter(String tf) {
    _taskFilter = tf;
    notifyListeners();
  }

  void setSearch(String query) {
    _search = query;
    notifyListeners();
  }

  void setSubjectFilter(String subj) {
    _subjectFilter = subj;
    _learnerSubjectTab = 'Tugas';
    notifyListeners();
  }

  void setLearnerSubjectTab(String val) {
    _learnerSubjectTab = val;
    notifyListeners();
  }

  void openStudentSubjectShortcut(String subject) {
    _subjectFilter = subject;
    _learnerSubjectTab = 'Tugas';
    _taskFilter = 'Aktif';
    _tab = 'Tugas';
    _screen = 'main';
    notifyListeners();
  }

  void openHistoryShortcut() {
    _tab = 'Tugas';
    _taskFilter = 'Riwayat';
    _screen = 'main';
    notifyListeners();
  }

  void nextStudyTip() {
    _tipIndex = (_tipIndex + 1) % SeedData.studyTips.length;
    notifyListeners();
  }

  // Tasks & Quiz
  void openTask(TaskItem task) {
    _selectedTask = task;
    _error = '';
    _screen = isTeacher ? 'teacherTask' : 'taskDetail';
    notifyListeners();
  }

  void openPractice(PracticeItem practice, {bool previewForTeacher = false, String from = 'main'}) {
    _selectedPractice = practice;
    _returnScreen = from;
    _error = '';
    _screen = previewForTeacher ? 'practicePreview' : 'practiceDetail';
    notifyListeners();
  }

  List<QuizQuestion> get currentQuizBank {
    final subj = _selectedTask?.subject ?? _draftSubject;
    final savedReligion = _screen == 'result' && _selectedTask != null
        ? _data.results[_selectedTask!.id]?.religion
        : null;
    final effectiveReligion = savedReligion ?? _data.religion;
    return CurriculumData.questionsFor(subj, effectiveReligion);
  }

  List<EssayPrompt> get currentEssayBank {
    final subj = _selectedPractice?.subject ?? _draftSubject;
    return CurriculumData.exercisesFor(subj, _data.religion);
  }

  void startQuiz() {
    _questionIndex = 0;
    _choiceIndex = null;
    _checked = false;
    _answers = <int>[];
    _screen = 'quiz';
    notifyListeners();
  }

  void selectQuizChoice(int index) {
    if (_checked) return;
    _choiceIndex = index;
    notifyListeners();
  }

  LocalNotification _buildNotification({
    required String target,
    required String subject,
    required String className,
    required String title,
    required String kind,
    required String contentId,
  }) {
    final rand = Random().nextInt(90000) + 10000;
    return LocalNotification(
      id: 'n${DateTime.now().millisecondsSinceEpoch}-$rand',
      target: target,
      subject: subject,
      className: className,
      title: title,
      kind: kind,
      contentId: contentId,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  void checkOrAdvanceQuiz() {
    if (_choiceIndex == null || _selectedTask == null) return;
    if (!_checked) {
      _checked = true;
      notifyListeners();
      return;
    }

    final bank = currentQuizBank;
    final nextAnswers = <int>[..._answers, _choiceIndex!];
    _answers = nextAnswers;

    if (_questionIndex >= bank.length - 1) {
      int score = 0;
      for (int i = 0; i < bank.length && i < nextAnswers.length; i++) {
        if (nextAnswers[i] == bank[i].answerIndex) score++;
      }
      final task = _selectedTask!;
      final nextResults = <String, TaskResult>{
        ..._data.results,
        task.id: TaskResult(
          score: score,
          total: bank.length,
          answers: nextAnswers,
          religion: _data.religion,
          studentName: _data.studentName,
          className: task.className,
        ),
      };
      final nextReviewed = _data.reviewed.where((id) => id != task.id).toList();
      final notif = _buildNotification(
        target: 'teachers',
        subject: task.subject,
        className: task.className,
        title: '${_data.studentName} menyelesaikan tugas ${task.title}',
        kind: 'task',
        contentId: task.id,
      );
      _screen = 'result';
      _persistData(
        _data.copyWith(
          results: nextResults,
          reviewed: nextReviewed,
          localNotifications: <LocalNotification>[notif, ..._data.localNotifications],
        ),
      );
    } else {
      _questionIndex++;
      _choiceIndex = null;
      _checked = false;
      notifyListeners();
    }
  }

  void startPractice() {
    if (!isTeacher) _returnScreen = 'main';
    _questionIndex = 0;
    _essay = '';
    _showExample = false;
    _screen = 'essay';
    notifyListeners();
  }

  void updateEssay(String val) {
    _essay = val;
    notifyListeners();
  }

  void checkOrAdvanceEssay() {
    if (_essay.trim().isEmpty || _selectedPractice == null) return;
    if (!_showExample) {
      _showExample = true;
      notifyListeners();
      return;
    }

    final bank = currentEssayBank;
    if (_questionIndex >= bank.length - 1) {
      final practice = _selectedPractice!;
      if (!isTeacher) {
        final nextDone = <String, bool>{
          ..._data.practiceDone,
          practice.id: true,
        };
        final notif = _buildNotification(
          target: 'teachers',
          subject: practice.subject,
          className: _data.childClass,
          title: '${_data.studentName} menyelesaikan latihan ${practice.title}',
          kind: 'practice',
          contentId: practice.id,
        );
        _screen = 'practiceResult';
        _persistData(
          _data.copyWith(
            practiceDone: nextDone,
            localNotifications: <LocalNotification>[notif, ..._data.localNotifications],
          ),
        );
      } else {
        _screen = 'practiceResult';
        notifyListeners();
      }
    } else {
      _questionIndex++;
      _essay = '';
      _showExample = false;
      notifyListeners();
    }
  }

  void submitFileTask() {
    final task = _selectedTask;
    if (task == null) return;
    final notif = _buildNotification(
      target: 'teachers',
      subject: task.subject,
      className: task.className,
      title: '${_data.studentName} menandai tugas ${task.title} selesai',
      kind: 'task',
      contentId: task.id,
    );
    _notice = 'Tugas ditandai selesai di perangkat ini. Tidak ada file jawaban yang dikirim.';
    _taskFilter = 'Riwayat';
    _tab = 'Tugas';
    _screen = 'main';
    _persistData(
      _data.copyWith(
        results: <String, TaskResult>{
          ..._data.results,
          task.id: TaskResult(
            submittedOnly: true,
            studentName: _data.studentName,
            className: task.className,
          ),
        },
        reviewed: _data.reviewed.where((id) => id != task.id).toList(),
        localNotifications: <LocalNotification>[notif, ..._data.localNotifications],
      ),
    );
  }

  // Forms, Attachments, Materials, Announcements
  void openForm(String kind, {String? overrideSubject, String? overrideClass}) {
    _draftTitle = '';
    _draftBody = '';
    final subj = overrideSubject ?? (isGuru ? _data.teacherSubject : 'Matematika');
    _draftSubject = subj;

    String resolvedClass;
    if (overrideClass != null) {
      resolvedClass = (subj == 'Ilmu Pengetahuan Alam dan Sosial (IPAS)' &&
              !CurriculumData.subjectsForClass(overrideClass).contains(subj))
          ? 'Kelas 3'
          : overrideClass;
    } else if (isWali) {
      resolvedClass = AppConstants.waliClass;
    } else if (isGuru &&
        _data.teacherSubject == 'Ilmu Pengetahuan Alam dan Sosial (IPAS)' &&
        (_filter == 'Semua kelas' ||
            !CurriculumData.subjectsForClass(_filter).contains(_data.teacherSubject))) {
      resolvedClass = 'Kelas 3';
    } else {
      resolvedClass = _filter == 'Semua kelas' ? 'Kelas 1' : _filter;
    }

    _draftClass = resolvedClass;
    _draftMinutes = '30';
    _draftDue = KarsaDateUtils.formatDateKey(DateTime.now().add(const Duration(days: 7)));
    _error = '';
    _notice = '';
    _attachment = null;
    _sourceText = '';
    _summaryText = '';
    _screen = kind;
    notifyListeners();
  }

  void setDraftTitle(String val) {
    _draftTitle = val;
    notifyListeners();
  }

  void setDraftBody(String val) {
    _draftBody = val;
    notifyListeners();
  }

  void setDraftSubject(String val) {
    _draftSubject = val;
    if (val == 'Ilmu Pengetahuan Alam dan Sosial (IPAS)' &&
        !CurriculumData.subjectsForClass(_draftClass).contains(val)) {
      _draftClass = 'Kelas 3';
    }
    notifyListeners();
  }

  void setDraftClass(String val) {
    _draftClass = val;
    notifyListeners();
  }

  void setDraftMinutes(String val) {
    _draftMinutes = val;
    notifyListeners();
  }

  void setDraftDue(String val) {
    _draftDue = val;
    notifyListeners();
  }

  void setSourceText(String val) {
    _sourceText = val;
    notifyListeners();
  }

  void setSummaryText(String val) {
    _summaryText = val;
    notifyListeners();
  }

  void useExampleQuizForTask() {
    _attachment = null;
    _draftBody = 'quiz';
    if (_draftTitle.trim().isEmpty) {
      _draftTitle = 'Kuis $_draftSubject';
    }
    _notice = 'Kuis contoh siap disimpan.';
    _error = '';
    notifyListeners();
  }

  Future<void> pickAttachment() async {
    _error = '';
    _notice = '';
    notifyListeners();

    final currentSize = _storageService.estimateSerializedLength(_data);
    final outcome = await _attachmentService.pickAttachment(currentStoreBytes: currentSize);
    if (outcome.canceled) return;
    if (outcome.error != null) {
      _error = outcome.error!;
      notifyListeners();
      return;
    }
    _attachment = outcome.attachment;
    if (outcome.extractedText != null) {
      _sourceText = outcome.extractedText!;
    }
    _notice = outcome.notice ?? '';
    notifyListeners();
  }

  Future<void> openAttachment(AttachmentFile? file) async {
    final err = await _attachmentService.openAttachment(file);
    if (err != null) {
      _error = err;
      notifyListeners();
    }
  }

  void summarizeOffline() {
    final result = OfflineSummarizer.summarizeFirstThreeSentences(_sourceText);
    if (result == null) {
      _error =
          'Tempel teks materi atau unggah file .txt untuk diringkas. PDF belum dapat dibaca otomatis di demo.';
      notifyListeners();
      return;
    }
    _summaryText = result;
    _error = '';
    _notice = 'Ringkasan dipilih dari tiga kalimat pertama; ini bukan AI.';
    notifyListeners();
  }

  void saveMaterial() {
    if (!CurriculumData.subjectsForClass(_draftClass).contains(_draftSubject)) {
      _error = 'IPAS hanya untuk kelas 3–6.';
      notifyListeners();
      return;
    }
    if (_draftTitle.trim().isEmpty || (_attachment == null && _summaryText.trim().isEmpty)) {
      _error = 'Isi judul dan lampirkan file atau isi ringkasan materi.';
      notifyListeners();
      return;
    }

    final id = 'm${DateTime.now().millisecondsSinceEpoch}';
    final m = MaterialItem(
      id: id,
      title: _draftTitle.trim(),
      subject: _draftSubject,
      className: _draftClass,
      file: _attachment,
      summary: _summaryText.trim(),
      teacher: _data.teacherName,
    );
    final notif = _buildNotification(
      target: 'learners',
      subject: m.subject,
      className: m.className,
      title: '${_data.teacherName} menambah ringkasan materi: ${m.title}',
      kind: 'material',
      contentId: id,
    );
    _notice = 'Materi tersimpan di perangkat ini.';
    _error = '';
    _screen = 'materials';
    _persistData(
      _data.copyWith(
        materials: <MaterialItem>[m, ..._data.materials],
        localNotifications: <LocalNotification>[notif, ..._data.localNotifications],
      ),
    );
  }

  void openMaterialDetail(MaterialItem item) {
    _selectedMaterial = item;
    _error = '';
    _screen = 'materialDetail';
    notifyListeners();
  }

  void saveTask() {
    final mins = double.tryParse(_draftMinutes.trim());
    if (_draftTitle.trim().isEmpty || mins == null || !mins.isFinite || mins <= 0) {
      _error = 'Isi judul dan batas waktu yang valid.';
      notifyListeners();
      return;
    }
    if (_attachment == null && _draftBody.isEmpty) {
      _error = 'Lampirkan file tugas atau pilih buat kuis contoh.';
      notifyListeners();
      return;
    }
    final due = KarsaDateUtils.parseDueEndOfDay(_draftDue);
    if (due == null || due.millisecondsSinceEpoch <= DateTime.now().millisecondsSinceEpoch) {
      _error = 'Isi tanggal tenggat yang valid dan belum lewat (YYYY-MM-DD).';
      notifyListeners();
      return;
    }
    if (!CurriculumData.subjectsForClass(_draftClass).contains(_draftSubject)) {
      _error = 'IPAS hanya untuk kelas 3–6.';
      notifyListeners();
      return;
    }

    final id = 't${DateTime.now().millisecondsSinceEpoch}';
    final task = TaskItem(
      id: id,
      subject: _draftSubject,
      title: _draftTitle.trim(),
      className: _draftClass,
      minutes: _draftMinutes.trim(),
      kind: _attachment != null ? 'file' : 'quiz',
      file: _attachment,
      teacher: _data.teacherName,
      dueAt: due.toUtc().toIso8601String(),
    );
    final notif = _buildNotification(
      target: 'learners',
      subject: task.subject,
      className: task.className,
      title: '${_data.teacherName} menambahkan tugas baru: ${task.title}',
      kind: 'task',
      contentId: id,
    );
    _notice = 'Tugas tersimpan di perangkat ini.';
    _error = '';
    _persistData(
      _data.copyWith(
        tasks: <TaskItem>[..._data.tasks, task],
        localNotifications: <LocalNotification>[notif, ..._data.localNotifications],
      ),
    );
    changeTab('Tugas');
  }

  void savePractice() {
    if (_draftTitle.trim().isEmpty) {
      _error = 'Isi judul latihan.';
      notifyListeners();
      return;
    }
    if (!CurriculumData.subjectsForClass(_draftClass).contains(_draftSubject)) {
      _error = 'IPAS hanya untuk kelas 3–6.';
      notifyListeners();
      return;
    }
    final item = PracticeItem(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      subject: _draftSubject,
      title: _draftTitle.trim(),
      className: _draftClass,
    );
    _filter = _draftClass;
    _subjectTab = 'Latihan';
    _error = '';
    _screen = 'subject';
    _persistData(
      _data.copyWith(
        customPractices: <PracticeItem>[..._data.customPractices, item],
      ),
    );
  }

  void openAnnouncement(AnnouncementItem item) {
    _selectedAnnouncement = item;
    final nextRead = <String>{..._data.readAnnouncements, item.id}.toList();
    _screen = 'announcementDetail';
    _persistData(_data.copyWith(readAnnouncements: nextRead));
  }

  void saveAnnouncement() {
    if (_draftTitle.trim().isEmpty || _draftBody.trim().isEmpty) {
      _error = 'Isi judul dan isi pengumuman.';
      notifyListeners();
      return;
    }
    final created = AnnouncementItem(
      id: 'a${DateTime.now().millisecondsSinceEpoch}',
      title: _draftTitle.trim(),
      body: _draftBody.trim(),
      detail: 'Baru saja · $_draftClass',
      category: 'PENGUMUMAN GURU',
      className: _draftClass,
    );
    _error = '';
    _screen = 'announcements';
    _persistData(
      _data.copyWith(
        announcements: <AnnouncementItem>[created, ..._data.announcements],
      ),
    );
  }

  void markNotification(LocalNotification n) {
    final key = notificationKey;
    final existing = _data.readNotifications[key] ?? const <String>[];
    final updatedRead = <String, List<String>>{
      ..._data.readNotifications,
      key: <String>{...existing, n.id}.toList(),
    };

    if (isWali && n.kind == 'task') {
      _tab = 'Rekap';
      _screen = 'main';
      _persistData(_data.copyWith(readNotifications: updatedRead));
      return;
    }

    if (n.kind == 'agenda') {
      final matches = _data.classEvents.where((e) => e.id == n.contentId).toList();
      if (matches.isNotEmpty) {
        _selectedEvent = matches.first;
        _screen = 'agendaDetail';
        _persistData(_data.copyWith(readNotifications: updatedRead));
        return;
      }
    }

    if (n.kind == 'task') {
      final matches = _data.tasks.where((t) => t.id == n.contentId).toList();
      if (matches.isNotEmpty) {
        _tab = 'Tugas';
        _selectedTask = matches.first;
        _screen = isTeacher ? 'teacherTask' : 'taskDetail';
        _persistData(_data.copyWith(readNotifications: updatedRead));
        return;
      }
    }

    if (n.kind == 'material') {
      final matches = _data.materials.where((m) => m.id == n.contentId).toList();
      if (matches.isNotEmpty) {
        _selectedMaterial = matches.first;
        _screen = 'materialDetail';
        _persistData(_data.copyWith(readNotifications: updatedRead));
        return;
      }
    }

    _notice = n.title;
    _screen = 'notifications';
    _persistData(_data.copyWith(readNotifications: updatedRead));
  }

  // Teacher Class / Subject / Grade Recap
  void openSubjectPage(String subject, {String initialTab = 'Tugas'}) {
    _draftSubject = subject;
    _subjectTab = initialTab;
    _screen = 'subject';
    notifyListeners();
  }

  void setSubjectTab(String val) {
    _subjectTab = val;
    notifyListeners();
  }

  void openStudentDetail(String name, int index) {
    final body = index == 0
        ? '${_data.results.length} tugas selesai dan $donePracticeCount latihan selesai di perangkat ini.'
        : 'Data siswa contoh.';
    _selectedStudentDetail = StudentDetailSelection(title: name, body: body);
    _screen = 'studentDetail';
    notifyListeners();
  }

  List<RosterMember> gradeRoster(String className, TaskItem? task) {
    final result = task != null ? _data.results[task.id] : null;
    final exampleNames = SeedData.exampleRosterByClass[className] ??
        const <String>['Siswa A', 'Siswa B', 'Siswa C'];
    final activeProfile = className == _data.childClass ||
        className == _data.studentClass ||
        className == _data.parentClass;
    final profileName = result?.studentName ??
        ((result != null && !result.demo) ? 'Profil siswa (data lama)' : null) ??
        (activeProfile ? _data.studentName : exampleNames[0]);

    return <RosterMember>[
      RosterMember(
        id: 'profile',
        name: profileName,
        profile: true,
        example: (result?.studentName == null) && !activeProfile,
      ),
      RosterMember(id: 'example-b', name: exampleNames[1], profile: false, example: true),
      RosterMember(id: 'example-c', name: exampleNames[2], profile: false, example: true),
    ];
  }

  double? gradeFor(TaskItem task, RosterMember member) {
    final r = member.profile ? _data.results[task.id] : null;
    if (r == null ||
        r.submittedOnly ||
        r.score == null ||
        r.total == null ||
        r.total! <= 0) {
      return null;
    }
    return ((r.score! / r.total!) * 10000).round() / 100.0;
  }

  String gradeNote(TaskItem task, RosterMember member) {
    final r = member.profile ? _data.results[task.id] : null;
    if (r == null) return 'Belum ada nilai';
    if (r.submittedOnly) return 'File ditandai selesai; belum dinilai';
    if (r.demo) return 'Nilai contoh';
    if (r.studentName != null && r.studentName!.isNotEmpty) return 'Hasil lokal';
    return 'Hasil lokal lama; identitas belum tercatat';
  }

  List<GradeReportRow> reportRows(String className) {
    final matchingTasks = _data.tasks
        .where((t) => t.className == className && t.subject == _data.teacherSubject)
        .toList();
    final rows = <GradeReportRow>[];
    for (final task in matchingTasks) {
      for (final member in gradeRoster(className, task)) {
        rows.add(
          GradeReportRow(
            name: member.name,
            task: task.title,
            grade: gradeFor(task, member),
            note: gradeNote(task, member) + (member.example ? ' · siswa contoh' : ''),
          ),
        );
      }
    }
    return rows;
  }

  void openGradeRecap(String className, String fromScreen) {
    _gradeClass = className.isEmpty ? 'Kelas 1' : className;
    _gradeReturn = fromScreen;
    _error = '';
    _notice = '';
    _screen = 'gradeRecap';
    notifyListeners();
  }

  void setGradeClass(String className) {
    _gradeClass = className;
    _error = '';
    _notice = '';
    notifyListeners();
  }

  Future<void> exportGrades(String format) async {
    if (_exporting) return;
    _exporting = true;
    _error = '';
    _notice = '';
    notifyListeners();

    try {
      final payload = GradeReportPayload(
        className: _gradeClass,
        subject: _data.teacherSubject,
        teacher: _data.teacherName,
        rows: reportRows(_gradeClass),
      );
      final msg = await _gradeExportService.exportAndShare(
        format: format,
        report: payload,
      );
      _notice = msg;
    } catch (e) {
      _error = 'Gagal membuat rekap: $e';
    } finally {
      _exporting = false;
      notifyListeners();
    }
  }

  // Wali Kelas Attendance, Scores & Agenda
  void setRecapTab(String nextRecapTab) {
    _recapTab = nextRecapTab;
    notifyListeners();
  }

  void openWaliRecapShortcut({required String tabName, bool resetToToday = false}) {
    if (resetToToday) _recapDate = todayKey;
    _recapTab = tabName;
    changeTab('Rekap');
  }

  void moveRecapDate(int deltaDays) {
    final parsed = KarsaDateUtils.parseDateKey(_recapDate) ?? DateTime.now();
    final shifted = DateTime(parsed.year, parsed.month, parsed.day + deltaDays);
    _recapDate = KarsaDateUtils.formatDateKey(shifted);
    notifyListeners();
  }

  void setAttendance(String mId, String status) {
    final nextDay = <String, String>{...dayAttendance, mId: status};
    final nextAll = <String, Map<String, String>>{
      ..._data.attendance,
      _recapDate: nextDay,
    };
    _persistData(_data.copyWith(attendance: nextAll));
  }

  void clearAttendance(String mId) {
    final nextDay = <String, String>{...dayAttendance}..remove(mId);
    final nextAll = <String, Map<String, String>>{
      ..._data.attendance,
      _recapDate: nextDay,
    };
    _persistData(_data.copyWith(attendance: nextAll));
  }

  void editMember(ClassMember m) {
    _memberId = m.id;
    final existing = _data.classScores[m.id];
    if (existing == null) {
      _scoreDraft = '';
    } else {
      _scoreDraft = existing == existing.roundToDouble()
          ? existing.toInt().toString()
          : existing.toString();
    }
    _error = '';
    _screen = 'waliMember';
    notifyListeners();
  }

  void setScoreDraft(String val) {
    _scoreDraft = val;
    notifyListeners();
  }

  void saveScore() {
    final raw = _scoreDraft.trim();
    final valid = RegExp(r'^\d+(\.\d+)?$').hasMatch(raw);
    final parsed = double.tryParse(raw);
    if (!valid || parsed == null || parsed > 100 || _memberId == null) {
      _error = 'Masukkan nilai antara 0 dan 100.';
      notifyListeners();
      return;
    }
    final nextScores = <String, double>{
      ..._data.classScores,
      _memberId!: parsed,
    };
    _error = '';
    _tab = 'Rekap';
    _recapTab = 'Nilai';
    _screen = 'main';
    _persistData(_data.copyWith(classScores: nextScores));
  }

  void deleteScore() {
    if (_memberId == null) return;
    final nextScores = <String, double>{..._data.classScores}..remove(_memberId!);
    _scoreDraft = '';
    _tab = 'Rekap';
    _recapTab = 'Nilai';
    _screen = 'main';
    _persistData(_data.copyWith(classScores: nextScores));
  }

  void moveCalendarMonth(int deltaMonths) {
    final shifted = DateTime(_year, _month1Based + deltaMonths, 1);
    _year = shifted.year;
    _month1Based = shifted.month;
    _day = 1;
    notifyListeners();
  }

  void selectCalendarDay(int d) {
    _day = d;
    notifyListeners();
  }

  void openEventForm() {
    _draftTitle = '';
    _draftBody = '';
    _eventDate = KarsaDateUtils.formatDateKey(DateTime(_year, _month1Based, _day));
    _error = '';
    _screen = 'agendaForm';
    notifyListeners();
  }

  void setEventDate(String val) {
    _eventDate = val;
    notifyListeners();
  }

  void saveEvent() {
    final parsed = KarsaDateUtils.parseDateKey(_eventDate);
    if (_draftTitle.trim().isEmpty || parsed == null) {
      _error = 'Isi judul dan tanggal valid dengan format YYYY-MM-DD.';
      notifyListeners();
      return;
    }
    final event = ClassEvent(
      id: 'e${DateTime.now().millisecondsSinceEpoch}',
      title: _draftTitle.trim(),
      body: _draftBody.trim(),
      date: _eventDate.trim(),
      className: AppConstants.waliClass,
      teacher: _data.waliName,
    );
    final notif = _buildNotification(
      target: 'learners',
      subject: 'Agenda',
      className: AppConstants.waliClass,
      title: '${_data.waliName} menambahkan agenda: ${event.title}',
      kind: 'agenda',
      contentId: event.id,
    );
    _year = parsed.year;
    _month1Based = parsed.month;
    _day = parsed.day;
    _error = '';
    _tab = 'Agenda';
    _screen = 'main';
    _persistData(
      _data.copyWith(
        classEvents: <ClassEvent>[..._data.classEvents, event],
        localNotifications: <LocalNotification>[notif, ..._data.localNotifications],
      ),
    );
  }

  void openAgendaDetail(ClassEvent event) {
    _selectedEvent = event;
    _screen = 'agendaDetail';
    notifyListeners();
  }

  // Progress & Settings
  void setMood(String moodLabel) {
    _persistData(_data.copyWith(mood: moodLabel));
  }

  void openSetting(String settingTitle) {
    _setting = settingTitle;
    _draftTitle = isWali
        ? _data.waliName
        : isTeacher
            ? _data.teacherName
            : _data.studentName;
    _error = '';
    _screen = 'setting';
    notifyListeners();
  }

  void setChildClassFromSetting(String cls) {
    if (isStudent) {
      _persistData(_data.copyWith(childClass: cls, studentClass: cls));
    } else {
      _persistData(_data.copyWith(childClass: cls, parentClass: cls));
    }
  }

  void setReligion(String rel) {
    _persistData(_data.copyWith(religion: rel));
  }

  void setTeacherSubject(String subj) {
    _persistData(_data.copyWith(teacherSubject: subj));
  }

  void savePersonalInfo() {
    final trimmed = _draftTitle.trim();
    if (trimmed.isEmpty) {
      _error = 'Nama tidak boleh kosong.';
      notifyListeners();
      return;
    }
    _error = '';
    _screen = 'main';
    if (isWali) {
      _persistData(_data.copyWith(waliName: trimmed));
    } else if (isTeacher) {
      _persistData(_data.copyWith(teacherName: trimmed));
    } else {
      _persistData(_data.copyWith(studentName: trimmed));
    }
  }
}
