import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/date_utils.dart';
import '../core/services/quiz_draft_service.dart';
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
import '../models/operator_profile.dart';
import '../models/remembered_login.dart';
import '../models/quiz_question.dart';
import '../models/school_class.dart';
import '../models/staff_account.dart';
import '../models/media_asset.dart';
import '../models/student_profile.dart';
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

  /// `true` bila halaman esai sedang mengejar bagian esai sebuah **tugas**
  /// (bukan latihan mandiri). Menentukan asal bank soal dan ke mana hasilnya
  /// disimpan.
  bool _essayForTask = false;

  /// Kuis pilihan ganda sedang dijalankan untuk sebuah **latihan**, bukan
  /// tugas. Skornya disimpan di `practiceResults`, bukan `results`.
  bool _quizForPractice = false;

  /// Jawaban esai yang sedang diketik, satu entri per soal.
  List<String> _essayDrafts = <String>[];
  bool _showExample = false;

  int _month1Based = DateTime.now().month;
  int _year = DateTime.now().year;
  int _day = DateTime.now().day;

  String _username = '';
  String _password = '';
  bool _showPassword = false;

  /// Apakah pengguna mencentang "Ingat saya" pada form login.
  bool _rememberMe = true;

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

  /// Teks bahan yang ditempel guru/wali untuk simulasi asisten.
  String _assistantSource = '';

  /// Soal hasil simulasi asisten untuk draft tugas yang sedang dibuat.
  List<QuizQuestion> _assistantQuestions = <QuizQuestion>[];

  /// `true` saat draft memakai soal dari asisten.
  bool _assistantUsed = false;

  String _recapTab = 'Kehadiran';
  String _recapDate = KarsaDateUtils.formatDateKey(DateTime.now());
  String? _memberId;
  String _scoreDraft = '';
  String _eventDate = '';

  String _subjectFilter = 'Semua';
  String _learnerSubjectTab = 'Tugas';
  DateTime _now = DateTime.now();

  // Pencarian data siswa pada tab operator.
  String _operatorStudentQuery = '';

  // Form "Informasi pribadi" operator: kolom selain nama.
  String _draftOperatorNip = '';
  String _draftOperatorRole = '';
  String _draftOperatorEmail = '';
  String _draftOperatorPhone = '';
  String _draftOperatorUnit = '';

  // Pesan galat saat operator memilih gambar.
  String _operatorMediaError = '';

  // Form operator: tugas, materi, pengumuman, agenda, nilai, dan kelas.
  String _draftTaskId = '';
  String _draftMaterialId = '';
  String _draftAnnouncementId = '';
  String _draftEventId = '';
  String _draftGradeStudentId = '';
  String _draftSchoolClassId = '';
  String _draftSchoolClassName = '';
  String _draftSchoolClassTeacher = '';

  // Form operator: tambah/ubah akun guru dan wali kelas.
  String _draftStaffId = '';
  String _draftStaffName = '';
  String _draftStaffNip = '';
  String _draftStaffRole = 'guru';
  String _draftStaffClass = '';

  // Form operator: tambah/ubah data siswa.
  String _draftStudentId = '';
  String _draftStudentName = '';
  String _draftStudentNisn = '';
  String _draftStudentClass = 'Kelas 1';
  String _draftStudentGender = 'L';
  String _draftStudentParent = '';
  bool _draftStudentActive = true;

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

  bool get essayForTask => _essayForTask;

  /// True saat layar kuis menampilkan soal milik latihan.
  bool get quizForPractice => _quizForPractice;

  /// Skor pilihan ganda latihan yang sedang dibuka (null bila belum dikerjakan).
  TaskResult? get selectedPracticeResult {
    final practice = _selectedPractice;
    if (practice == null) return null;
    return _data.practiceResults[practice.id];
  }

  /// Jawaban esai tersimpan untuk tugas yang sedang dibuka.
  List<String> get savedEssayAnswers {
    final task = _selectedTask;
    if (task == null) return const <String>[];
    return _data.results[task.id]?.essayAnswers ?? const <String>[];
  }

  /// Bagian esai tugas ini sudah dikerjakan siswa.
  bool get taskEssayDone => savedEssayAnswers.any((a) => a.trim().isNotEmpty);

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

  /// Teks bahan untuk simulasi asisten penyusun soal.
  String get assistantSource => _assistantSource;

  /// Soal yang sudah dihasilkan asisten untuk draft ini.
  List<QuizQuestion> get assistantQuestions => _assistantQuestions;

  /// Apakah draft tugas ini memakai soal dari asisten.
  bool get assistantUsed => _assistantUsed;

  /// Asisten sudah membuat soal dan soal itu siap dipakai.
  bool get assistantReady => _assistantUsed && _assistantQuestions.isNotEmpty;

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

  /// Kelas yang diajar guru untuk mapelnya sendiri.
  ///
  /// Guru mapel hanya mengajar satu mata pelajaran, jadi daftar kelasnya
  /// diturunkan dari `subjectsForClass` (mis. IPAS baru ada mulai Kelas 3).
  /// Dipakai form pengumuman agar guru tidak mengirim pengumuman ke kelas
  /// yang tidak diajarnya.
  List<String> get teacherClasses => AppConstants.classes
      .where(
        (c) => CurriculumData.subjectsForClass(c).contains(_data.teacherSubject),
      )
      .toList();
  bool get isWali => _role?.isWali ?? false;
  bool get isGuru => _role?.isGuru ?? false;
  bool get isStudent => _role?.isStudent ?? false;
  bool get isParent => _role?.isParent ?? false;
  bool get isOperator => _role?.isOperator ?? false;

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
      // Operator sekolah melihat semua notifikasi sekolah.
      if (isOperator) return true;
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

  /// Pesan galat terakhir saat memilih gambar (tab Media).
  String get operatorMediaError => _operatorMediaError;

  void setOperatorMediaError(String value) {
    _operatorMediaError = value;
    notifyListeners();
  }

  /// Kata kunci pencarian siswa (tab operator).
  String get operatorStudentQuery => _operatorStudentQuery;

  void setOperatorStudentQuery(String value) {
    _operatorStudentQuery = value;
    notifyListeners();
  }

  // Getter form operator.
  String get draftTaskId => _draftTaskId;
  String get draftMaterialId => _draftMaterialId;
  String get draftAnnouncementId => _draftAnnouncementId;
  String get draftEventId => _draftEventId;
  String get draftSchoolClassId => _draftSchoolClassId;
  String get draftSchoolClassName => _draftSchoolClassName;
  String get draftSchoolClassTeacher => _draftSchoolClassTeacher;
  String get draftStaffId => _draftStaffId;
  String get draftStaffName => _draftStaffName;
  String get draftStaffNip => _draftStaffNip;
  String get draftStaffRole => _draftStaffRole;
  String get draftStaffClass => _draftStaffClass;
  String get draftStudentId => _draftStudentId;
  String get draftStudentName => _draftStudentName;
  String get draftStudentNisn => _draftStudentNisn;
  String get draftStudentClass => _draftStudentClass;
  String get draftStudentGender => _draftStudentGender;
  String get draftStudentParent => _draftStudentParent;
  bool get draftStudentActive => _draftStudentActive;

  /// Membuka form tambah/ubah siswa. Null berarti tambah baru.
  void openStudentForm([String? studentId]) {
    final existing = studentId == null
        ? null
        : _data.roster.where((s) => s.id == studentId).toList();
    if (existing == null || existing.isEmpty) {
      _draftStudentId = '';
      _draftStudentName = '';
      _draftStudentNisn = '';
      _draftStudentClass = operatorClassNames.isEmpty
          ? 'Kelas 1'
          : operatorClassNames.first;
      _draftStudentGender = 'L';
      _draftStudentParent = '';
      _draftStudentActive = true;
    } else {
      final student = existing.first;
      _draftStudentId = student.id;
      _draftStudentName = student.name;
      _draftStudentNisn = student.nisn;
      _draftStudentClass = student.className;
      _draftStudentGender = student.gender;
      _draftStudentParent = student.parentName;
      _draftStudentActive = student.active;
    }
    _error = '';
    _screen = 'operatorStudentForm';
    notifyListeners();
  }

  void setDraftStudentName(String value) {
    _draftStudentName = value;
    if (_error.isNotEmpty) _error = '';
    notifyListeners();
  }

  void setDraftStudentNisn(String value) {
    _draftStudentNisn = value;
    notifyListeners();
  }

  void setDraftStudentClass(String value) {
    _draftStudentClass = value;
    notifyListeners();
  }

  void setDraftStudentGender(String value) {
    _draftStudentGender = value;
    notifyListeners();
  }

  void setDraftStudentParent(String value) {
    _draftStudentParent = value;
    notifyListeners();
  }

  void setDraftStudentActive(bool value) {
    _draftStudentActive = value;
    notifyListeners();
  }

  /// Menyimpan data siswa dari form operator.
  void saveStudentForm() {
    final name = _draftStudentName.trim();
    if (name.isEmpty) {
      _error = 'Nama siswa tidak boleh kosong.';
      notifyListeners();
      return;
    }
    final id = _draftStudentId.isEmpty
        ? 'siswa-${DateTime.now().millisecondsSinceEpoch}'
        : _draftStudentId;
    final student = StudentProfile(
      id: id,
      nisn: _draftStudentNisn.trim(),
      name: name,
      className: _draftStudentClass,
      gender: _draftStudentGender,
      parentName: _draftStudentParent.trim(),
      active: _draftStudentActive,
    );
    if (_draftStudentId.isEmpty) {
      addStudent(student);
    } else {
      updateStudent(student);
    }
    _error = '';
    _screen = 'main';
    _tab = 'Siswa';
    notifyListeners();
  }

  /// Apakah role ini boleh mengelola seluruh isi aplikasi (operator sekolah).
  bool get canManageAll => _role?.canManageAll ?? false;

  /// Profil lengkap operator sekolah (nama, NIP, jabatan, kontak, unit).
  OperatorProfile get operatorProfile => _data.operatorProfile;

  String get draftOperatorNip => _draftOperatorNip;
  String get draftOperatorRole => _draftOperatorRole;
  String get draftOperatorEmail => _draftOperatorEmail;
  String get draftOperatorPhone => _draftOperatorPhone;
  String get draftOperatorUnit => _draftOperatorUnit;

  void setDraftOperatorNip(String value) {
    _draftOperatorNip = value;
    if (_error.isNotEmpty) _error = '';
    notifyListeners();
  }

  void setDraftOperatorRole(String value) {
    _draftOperatorRole = value;
    if (_error.isNotEmpty) _error = '';
    notifyListeners();
  }

  void setDraftOperatorEmail(String value) {
    _draftOperatorEmail = value;
    if (_error.isNotEmpty) _error = '';
    notifyListeners();
  }

  void setDraftOperatorPhone(String value) {
    _draftOperatorPhone = value;
    if (_error.isNotEmpty) _error = '';
    notifyListeners();
  }

  void setDraftOperatorUnit(String value) {
    _draftOperatorUnit = value;
    if (_error.isNotEmpty) _error = '';
    notifyListeners();
  }

  /// Validering surel sederhana: cukup satu `@` dengan bagian sebelum/sesudah.
  static bool isValidEmail(String value) {
    final text = value.trim();
    if (text.isEmpty) return true; // opsional
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
  }

  /// Validering telepon: hanya digit, spasi, `+`, `-`, dan tanda kurung.
  static bool isValidPhone(String value) {
    final text = value.trim();
    if (text.isEmpty) return true; // opsional
    if (!RegExp(r'^[0-9+()\-\s]+$').hasMatch(text)) return false;
    final digits = text.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 8 && digits.length <= 16;
  }

  /// Menyimpan seluruh profil operator dari form "Informasi pribadi".
  ///
  /// Mengembalikan `true` bila tersimpan. Kolom kontak boleh kosong, tetapi
  /// nama wajib diisi dan format surel/telepon harus masuk akal supaya galat
  /// bisa ditampilkan langsung di form, bukan diam-diam tersimpan.
  bool saveOperatorProfileForm() {
    final name = _draftTitle.trim();
    if (name.isEmpty) {
      _error = 'Nama operator tidak boleh kosong.';
      notifyListeners();
      return false;
    }
    final nip = _draftOperatorNip.trim();
    if (nip.isEmpty) {
      _error = 'NIP tidak boleh kosong.';
      notifyListeners();
      return false;
    }
    if (!RegExp(r'^[0-9]{6,20}$').hasMatch(nip)) {
      _error = 'NIP harus berupa 6-20 angka.';
      notifyListeners();
      return false;
    }
    final email = _draftOperatorEmail.trim();
    if (!isValidEmail(email)) {
      _error = 'Format surel belum benar, mis. nama@sekolah.sch.id';
      notifyListeners();
      return false;
    }
    final phone = _draftOperatorPhone.trim();
    if (!isValidPhone(phone)) {
      _error = 'Nomor telepon harus 8-16 angka.';
      notifyListeners();
      return false;
    }

    final nextProfile = _data.operatorProfile.copyWith(
      name: name,
      nip: nip,
      role: _draftOperatorRole.trim().isEmpty
          ? _data.operatorProfile.role
          : _draftOperatorRole.trim(),
      email: email,
      phone: phone,
      unit: _draftOperatorUnit.trim().isEmpty
          ? _data.operatorProfile.unit
          : _draftOperatorUnit.trim(),
    );
    _error = '';
    _screen = 'main';
    _persistData(_data.copyWith(
      operatorName: name,
      operatorProfile: nextProfile,
    ));
    return true;
  }

  /// Grafis yang dikelola operator sekolah.
  Map<String, AttachmentFile> get mediaAssets => _data.mediaAssets;

  /// Lampiran untuk satu slot grafis, null bila operator belum mengunggah.
  AttachmentFile? mediaAsset(String key) => _data.mediaAssets[key];

  /// Daftar siswa resmi.
  List<StudentProfile> get roster => _data.roster;

  /// Siswa satu kelas.
  List<StudentProfile> rosterForClass(String className) => _data.roster
      .where((s) => s.className == className)
      .toList();

  /// Jumlah siswa aktif di seluruh kelas.
  int get activeStudentCount =>
      _data.roster.where((s) => s.active).toList().length;

  /// Menyimpan satu grafis ke slot media.
  void setMediaAsset(String key, AttachmentFile file) {
    final next = <String, AttachmentFile>{
      ..._data.mediaAssets,
      key: file,
    };
    _operatorMediaError = '';
    _persistData(_data.copyWith(mediaAssets: next));
  }

  /// Memilih gambar untuk satu slot grafis dan menyimpannya ke store.
  Future<String?> pickMediaAsset(String key) async {
    final outcome = await _attachmentService.pickAttachment(
      currentStoreBytes: 0,
      extensions: AttachmentService.imageExtensions,
    );
    if (outcome.error != null) {
      _operatorMediaError = outcome.error!;
      notifyListeners();
      return outcome.error;
    }
    if (outcome.canceled || outcome.attachment == null) return null;
    setMediaAsset(key, outcome.attachment!);
    return null;
  }

  /// Menghapus gambar dari satu slot grafis dan kembali ke aset bawaan.
  void removeMediaAsset(String key) {
    if (!_data.mediaAssets.containsKey(key)) return;
    final next = <String, AttachmentFile>{..._data.mediaAssets}..remove(key);
    _operatorMediaError = '';
    _persistData(_data.copyWith(mediaAssets: next));
  }

  /// Menambah siswa baru ke roster.
  void addStudent(StudentProfile student) {
    final next = <StudentProfile>[
      student,
      ..._data.roster.where((s) => s.id != student.id),
    ];
    _persistData(_data.copyWith(roster: next));
  }

  /// Mengubah data satu siswa.
  void updateStudent(StudentProfile student) {
    final next = _data.roster
        .map((s) => s.id == student.id ? student : s)
        .toList();
    _persistData(_data.copyWith(roster: next));
  }

  /// Menghapus satu siswa dari roster.
  void removeStudent(String id) {
    final next = _data.roster.where((s) => s.id != id).toList();
    _persistData(_data.copyWith(roster: next));
  }

  /// Menghapus tugas. Hanya operator sekolah yang boleh menghapus data milik
  /// role lain.
  void deleteTask(String id) {
    final next = _data.tasks.where((t) => t.id != id).toList();
    final results = <String, dynamic>{..._data.results}..remove(id);
    _persistData(_data.copyWith(tasks: next, results: results));
  }

  /// Menghapus materi.
  void deleteMaterial(String id) {
    final next = _data.materials.where((m) => m.id != id).toList();
    _persistData(_data.copyWith(materials: next));
  }

  /// Menghapus pengumuman.
  void deleteAnnouncement(String id) {
    final next = _data.announcements.where((a) => a.id != id).toList();
    _persistData(_data.copyWith(announcements: next));
  }

  /* ------------------------------------------------------------------ *
   * Operator sekolah: kelola seluruh data aplikasi
   * ------------------------------------------------------------------ */

  /// Daftar kelas sekolah yang dikelola operator.
  List<SchoolClass> get schoolClasses => _data.schoolClasses;

  /// Nama kelas yang dipakai operator, urut sesuai daftar yang disimpan.
  List<String> get operatorClassNames =>
      _data.schoolClasses.map((c) => c.name).toList();

  /// Kelas yang dipakai untuk form operator (tanpa "Semua kelas").
  List<String> get operatorClassOptions => operatorClassNames;

  SchoolClass? schoolClassByName(String name) {
    for (final c in _data.schoolClasses) {
      if (c.name == name) return c;
    }
    return null;
  }

  /// Membuka form tambah/ubah tugas sekolah. Null berarti tambah baru.
  void openOperatorTaskForm([String? taskId]) {
    final existing = taskId == null
        ? null
        : _data.tasks.where((t) => t.id == taskId).toList();
    if (existing == null || existing.isEmpty) {
      _draftTaskId = '';
      _draftTitle = '';
      _draftBody = '';
      _draftSubject = 'Matematika';
      _draftClass = operatorClassNames.isEmpty ? 'Kelas 1' : operatorClassNames.first;
      _draftMinutes = '30';
      _draftDue = '';
    } else {
      final task = existing.first;
      _draftTaskId = task.id;
      _draftTitle = task.title;
      _draftBody = '';
      _draftSubject = task.subject;
      _draftClass = task.className;
      _draftMinutes = task.minutes;
      _draftDue = (task.dueAt ?? '').split('T').first;
    }
    _error = '';
    _notice = '';
    _screen = 'operatorTaskForm';
    notifyListeners();
  }

  /// Menyimpan tugas baru atau mengubah tugas yang sudah ada.
  void saveOperatorTask() {
    final mins = double.tryParse(_draftMinutes.trim());
    if (_draftTitle.trim().isEmpty || mins == null || !mins.isFinite || mins <= 0) {
      _error = 'Isi judul dan batas waktu yang valid.';
      notifyListeners();
      return;
    }
    final className = _draftClass;
    if (!CurriculumData.subjectsForClass(className).contains(_draftSubject)) {
      _error = 'IPAS hanya boleh dipakai untuk kelas 3-6.';
      notifyListeners();
      return;
    }
    final due = KarsaDateUtils.parseDueEndOfDay(_draftDue);
    if (due == null) {
      _error = 'Isi tanggal tenggat dengan format YYYY-MM-DD.';
      notifyListeners();
      return;
    }

    final isEdit = _draftTaskId.isNotEmpty;
    final id = isEdit ? _draftTaskId : 't${DateTime.now().millisecondsSinceEpoch}';
    // Saat operator mengedit tugas yang sudah punya soal hasil asisten, soalnya
    // tidak boleh ikut terhapus hanya karena form ini tidak mengelola soal.
    final previous = isEdit
        ? _data.tasks.where((t) => t.id == id).toList()
        : const <TaskItem>[];
    final keptQuestions = previous.isEmpty
        ? const <QuizQuestion>[]
        : previous.first.questions;
    final task = TaskItem(
      id: id,
      subject: _draftSubject,
      title: _draftTitle.trim(),
      className: className,
      minutes: _draftMinutes.trim(),
      kind: 'quiz',
      teacher: _data.teacherName,
      dueAt: due.toUtc().toIso8601String(),
      questions: keptQuestions,
      questionsSource: previous.isEmpty
          ? 'example'
          : previous.first.questionsSource,
    );
    final tasks = isEdit
        ? _data.tasks.map((t) => t.id == id ? task : t).toList()
        : <TaskItem>[..._data.tasks, task];
    _error = '';
    _notice = isEdit ? 'Tugas diperbarui.' : 'Tugas tersimpan di perangkat ini.';
    _screen = 'operatorTasks';
    _persistData(_data.copyWith(tasks: tasks));
  }

  /// Membuka form tambah/ubah materi. Null berarti tambah baru.
  void openOperatorMaterialForm([String? materialId]) {
    final existing = materialId == null
        ? null
        : _data.materials.where((m) => m.id == materialId).toList();
    if (existing == null || existing.isEmpty) {
      _draftMaterialId = '';
      _draftTitle = '';
      _draftSubject = 'Matematika';
      _draftClass = operatorClassNames.isEmpty ? 'Kelas 1' : operatorClassNames.first;
      _summaryText = '';
      _sourceText = '';
    } else {
      final material = existing.first;
      _draftMaterialId = material.id;
      _draftTitle = material.title;
      _draftSubject = material.subject;
      _draftClass = material.className;
      _summaryText = material.summary;
      _sourceText = material.summary;
    }
    _error = '';
    _notice = '';
    _screen = 'operatorMaterialForm';
    notifyListeners();
  }

  /// Menyimpan materi baru atau mengubah materi yang sudah ada.
  void saveOperatorMaterial() {
    if (_draftTitle.trim().isEmpty) {
      _error = 'Isi judul materi.';
      notifyListeners();
      return;
    }
    if (!CurriculumData.subjectsForClass(_draftClass).contains(_draftSubject)) {
      _error = 'IPAS hanya boleh dipakai untuk kelas 3-6.';
      notifyListeners();
      return;
    }
    if (_summaryText.trim().isEmpty) {
      _error = 'Isi ringkasan materi.';
      notifyListeners();
      return;
    }

    final isEdit = _draftMaterialId.isNotEmpty;
    final id = isEdit
        ? _draftMaterialId
        : 'm${DateTime.now().millisecondsSinceEpoch}';
    final material = MaterialItem(
      id: id,
      title: _draftTitle.trim(),
      subject: _draftSubject,
      className: _draftClass,
      summary: _summaryText.trim(),
      teacher: _data.teacherName,
    );
    final materials = isEdit
        ? _data.materials.map((m) => m.id == id ? material : m).toList()
        : <MaterialItem>[material, ..._data.materials];
    _error = '';
    _notice = isEdit ? 'Materi diperbarui.' : 'Materi tersimpan di perangkat ini.';
    _screen = 'main';
    _tab = 'Materi';
    _persistData(_data.copyWith(materials: materials));
  }

  /// Membuka form tambah/ubah pengumuman. Null berarti tambah baru.
  void openOperatorAnnouncementForm([String? announcementId]) {
    final existing = announcementId == null
        ? null
        : _data.announcements.where((a) => a.id == announcementId).toList();
    if (existing == null || existing.isEmpty) {
      _draftAnnouncementId = '';
      _draftTitle = '';
      _draftBody = '';
      _draftClass = 'Semua kelas';
    } else {
      final announcement = existing.first;
      _draftAnnouncementId = announcement.id;
      _draftTitle = announcement.title;
      _draftBody = announcement.body;
      _draftClass = announcement.className;
    }
    _error = '';
    _notice = '';
    _screen = 'operatorAnnouncementForm';
    notifyListeners();
  }

  /// Menyimpan pengumuman baru atau mengubah pengumuman yang sudah ada.
  void saveOperatorAnnouncement() {
    if (_draftTitle.trim().isEmpty || _draftBody.trim().isEmpty) {
      _error = 'Isi judul dan isi pengumuman.';
      notifyListeners();
      return;
    }
    final isEdit = _draftAnnouncementId.isNotEmpty;
    final id = isEdit
        ? _draftAnnouncementId
        : 'a${DateTime.now().millisecondsSinceEpoch}';
    final announcement = AnnouncementItem(
      id: id,
      title: _draftTitle.trim(),
      body: _draftBody.trim(),
      detail: isEdit ? 'Diperbarui operator sekolah' : 'Baru saja · $_draftClass',
      category: 'PENGUMUMAN SEKOLAH',
      className: _draftClass,
    );
    final announcements = isEdit
        ? _data.announcements.map((a) => a.id == id ? announcement : a).toList()
        : <AnnouncementItem>[announcement, ..._data.announcements];
    _error = '';
    _notice = isEdit
        ? 'Pengumuman diperbarui.'
        : 'Pengumuman tersimpan di perangkat ini.';
    _screen = 'operatorAnnouncements';
    _persistData(_data.copyWith(announcements: announcements));
  }

  /// Membuka form tambah/ubah agenda sekolah. Null berarti tambah baru.
  void openOperatorEventForm([String? eventId]) {
    final existing = eventId == null
        ? null
        : _data.classEvents.where((e) => e.id == eventId).toList();
    if (existing == null || existing.isEmpty) {
      _draftEventId = '';
      _draftTitle = '';
      _draftBody = '';
      _eventDate = KarsaDateUtils.formatDateKey(DateTime.now());
      _draftClass = operatorClassNames.isEmpty ? 'Kelas 1' : operatorClassNames.first;
    } else {
      final event = existing.first;
      _draftEventId = event.id;
      _draftTitle = event.title;
      _draftBody = event.body;
      _eventDate = event.date;
      _draftClass = event.className;
    }
    _error = '';
    _notice = '';
    _screen = 'operatorAgendaForm';
    notifyListeners();
  }

  /// Menyimpan agenda baru atau mengubah agenda yang sudah ada.
  void saveOperatorEvent() {
    final parsed = KarsaDateUtils.parseDateKey(_eventDate);
    if (_draftTitle.trim().isEmpty || parsed == null) {
      _error = 'Isi judul dan tanggal valid dengan format YYYY-MM-DD.';
      notifyListeners();
      return;
    }
    final isEdit = _draftEventId.isNotEmpty;
    final id = isEdit
        ? _draftEventId
        : 'e${DateTime.now().millisecondsSinceEpoch}';
    final event = ClassEvent(
      id: id,
      title: _draftTitle.trim(),
      body: _draftBody.trim(),
      date: _eventDate.trim(),
      className: _draftClass,
      teacher: _data.teacherName,
    );
    final events = isEdit
        ? _data.classEvents.map((e) => e.id == id ? event : e).toList()
        : <ClassEvent>[..._data.classEvents, event];
    _error = '';
    _notice = isEdit ? 'Agenda diperbarui.' : 'Agenda tersimpan di perangkat ini.';
    _screen = 'operatorAgenda';
    _persistData(_data.copyWith(classEvents: events));
  }

  /// Menghapus agenda sekolah.
  void deleteEvent(String id) {
    final next = _data.classEvents.where((e) => e.id != id).toList();
    _persistData(_data.copyWith(classEvents: next));
  }

  /// Nilai ringkas siswa yang diisi operator sekolah.
  double? operatorScore(String studentId) => _data.rosterScores[studentId];

  /// Rata-rata nilai kelas yang diisi operator.
  double? operatorClassAverage(String className) {
    final values = rosterForClass(className)
        .map((s) => _data.rosterScores[s.id])
        .whereType<double>()
        .toList();
    if (values.isEmpty) return null;
    final sum = values.fold<double>(0, (acc, v) => acc + v);
    return sum / values.length;
  }

  /// Menyimpan nilai ringkas siswa. Null menghapus nilai.
  ///
  /// Nilai wajib berada di rentang 0-100. Nilai di luar rentang (atau bukan
  /// angka) ditolak dan [_error] diisi supaya operator melihat alasannya,
  /// bukan diam-diam menyimpan angka yang tidak valid.
  /// Mengembalikan true bila nilai tersimpan.
  bool saveOperatorScore(String studentId, double? value) {
    if (value != null) {
      if (value.isNaN || value.isInfinite) {
        _error = 'Nilai harus berupa angka.';
        notifyListeners();
        return false;
      }
      if (value < 0 || value > 100) {
        _error = 'Nilai harus antara 0 sampai 100.';
        notifyListeners();
        return false;
      }
    }
    final next = <String, double>{..._data.rosterScores};
    if (value == null) {
      next.remove(studentId);
    } else {
      next[studentId] = value;
    }
    _error = '';
    _notice = value == null ? 'Nilai dihapus.' : 'Nilai tersimpan.';
    _persistData(_data.copyWith(rosterScores: next));
    return true;
  }

  /// Membuka form tambah/ubah kelas sekolah. Null berarti tambah baru.
  void openOperatorClassForm([String? classId]) {
    final existing = classId == null
        ? null
        : _data.schoolClasses.where((c) => c.id == classId).toList();
    if (existing == null || existing.isEmpty) {
      _draftSchoolClassId = '';
      _draftSchoolClassName = '';
      _draftSchoolClassTeacher = '';
    } else {
      final schoolClass = existing.first;
      _draftSchoolClassId = schoolClass.id;
      _draftSchoolClassName = schoolClass.name;
      _draftSchoolClassTeacher = schoolClass.teacherName;
    }
    _error = '';
    _notice = '';
    _screen = 'operatorClassForm';
    notifyListeners();
  }

  void setDraftSchoolClassName(String value) {
    _draftSchoolClassName = value;
    if (_error.isNotEmpty) _error = '';
    notifyListeners();
  }

  void setDraftSchoolClassTeacher(String value) {
    _draftSchoolClassTeacher = value;
    notifyListeners();
  }

  /// Menyimpan kelas baru atau mengubah kelas yang sudah ada.
  void saveOperatorClass() {
    final name = _draftSchoolClassName.trim();
    if (name.isEmpty) {
      _error = 'Isi nama kelas.';
      notifyListeners();
      return;
    }
    final duplicate = _data.schoolClasses.any(
      (c) => c.name.toLowerCase() == name.toLowerCase() && c.id != _draftSchoolClassId,
    );
    if (duplicate) {
      _error = 'Kelas dengan nama itu sudah ada.';
      notifyListeners();
      return;
    }
    final isEdit = _draftSchoolClassId.isNotEmpty;
    final id = isEdit
        ? _draftSchoolClassId
        : 'c${DateTime.now().millisecondsSinceEpoch}';
    final schoolClass = SchoolClass(
      id: id,
      name: name,
      teacherName: _draftSchoolClassTeacher.trim(),
    );
    final classes = isEdit
        ? _data.schoolClasses.map((c) => c.id == id ? schoolClass : c).toList()
        : <SchoolClass>[..._data.schoolClasses, schoolClass];
    _error = '';
    _notice = isEdit ? 'Kelas diperbarui.' : 'Kelas tersimpan di perangkat ini.';
    _screen = 'main';
    _tab = 'Kelas';
    _persistData(_data.copyWith(schoolClasses: classes));
  }

  /// Menghapus kelas sekolah. Siswa di kelas tersebut dipindahkan ke kelas
  /// pertama yang tersisa supaya tidak ada data yatim.
  ///
  /// Kelas terakhir tidak boleh dihapus karena seluruh data sekolah (roster,
  /// tugas, agenda) memakai nama kelas. Mengembalikan true bila kelas dihapus.
  bool removeSchoolClass(String classId) {
    final target = _data.schoolClasses.where((c) => c.id == classId).toList();
    if (target.isEmpty) return false;
    if (_data.schoolClasses.length <= 1) {
      _error = 'Minimal satu kelas sekolah harus tetap ada.';
      notifyListeners();
      return false;
    }
    final removedName = target.first.name;
    final remaining = _data.schoolClasses.where((c) => c.id != classId).toList();
    final fallback = remaining.isEmpty ? null : remaining.first.name;
    final roster = _data.roster
        .map(
          (s) => s.className == removedName && fallback != null
              ? s.copyWith(className: fallback)
              : s,
        )
        .toList();
    final classes = remaining;
    _error = '';
    _notice = 'Kelas $removedName dihapus.';
    _persistData(
      _data.copyWith(schoolClasses: classes, roster: roster),
    );
    return true;
  }

  /// Akun guru dan wali kelas yang dikelola operator.
  List<StaffAccount> get staffAccounts => _data.staffAccounts;

  /// Membuka form tambah/ubah akun guru atau wali kelas.
  void openOperatorStaffForm([String? staffId]) {
    final existing = staffId == null
        ? null
        : _data.staffAccounts.where((a) => a.id == staffId).toList();
    if (existing == null || existing.isEmpty) {
      _draftStaffId = '';
      _draftStaffName = '';
      _draftStaffNip = '';
      _draftStaffRole = 'guru';
      _draftStaffClass = '';
    } else {
      final account = existing.first;
      _draftStaffId = account.id;
      _draftStaffName = account.name;
      _draftStaffNip = account.nip;
      _draftStaffRole = account.role;
      _draftStaffClass = account.className;
    }
    _error = '';
    _notice = '';
    _screen = 'operatorStaffForm';
    notifyListeners();
  }

  void setDraftStaffName(String value) {
    _draftStaffName = value;
    if (_error.isNotEmpty) _error = '';
    notifyListeners();
  }

  void setDraftStaffNip(String value) {
    _draftStaffNip = value;
    notifyListeners();
  }

  void setDraftStaffRole(String value) {
    _draftStaffRole = value;
    notifyListeners();
  }

  void setDraftStaffClass(String value) {
    _draftStaffClass = value;
    notifyListeners();
  }

  /// Menyimpan akun guru atau wali kelas.
  void saveOperatorStaff() {
    final name = _draftStaffName.trim();
    final nip = _draftStaffNip.trim();
    if (name.isEmpty || nip.isEmpty) {
      _error = 'Isi nama lengkap dan NIP.';
      notifyListeners();
      return;
    }
    final duplicate = _data.staffAccounts.any(
      (a) => a.nip == nip && a.id != _draftStaffId,
    );
    if (duplicate) {
      _error = 'NIP itu sudah dipakai akun lain.';
      notifyListeners();
      return;
    }
    final isEdit = _draftStaffId.isNotEmpty;
    final id = isEdit ? _draftStaffId : 'u${DateTime.now().millisecondsSinceEpoch}';
    final account = StaffAccount(
      id: id,
      name: name,
      nip: nip,
      role: _draftStaffRole,
      className: _draftStaffRole == 'wali' ? _draftStaffClass : '',
    );
    final accounts = isEdit
        ? _data.staffAccounts.map((a) => a.id == id ? account : a).toList()
        : <StaffAccount>[..._data.staffAccounts, account];
    _error = '';
    _notice = isEdit ? 'Akun diperbarui.' : 'Akun tersimpan di perangkat ini.';
    _screen = 'main';
    _tab = 'Kelas';
    _persistData(_data.copyWith(staffAccounts: accounts));
  }

  /// Menghapus akun guru atau wali kelas.
  ///
  /// Mengembalikan true bila akun dihapus.
  bool removeStaffAccount(String id) {
    final next = _data.staffAccounts.where((a) => a.id != id).toList();
    if (next.length == _data.staffAccounts.length) return false;
    _error = '';
    _notice = 'Akun dihapus.';
    _persistData(_data.copyWith(staffAccounts: next));
    return true;
  }

  /// Memindahkan siswa ke kelas lain.
  void moveStudentToClass(String studentId, String className) {
    final next = _data.roster
        .map((s) => s.id == studentId ? s.copyWith(className: className) : s)
        .toList();
    _persistData(_data.copyWith(roster: next));
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
      _screen = 'login';
      _prefillRememberedLogin();
      notifyListeners();
    }
  }

  /// Login yang tersimpan lewat "Ingat saya", null bila tidak ada.
  RememberedLogin? get rememberedLogin => _data.rememberedLogin;

  /// Apakah form login sudah terisi otomatis dari "Ingat saya".
  bool get hasRememberedLogin => _data.rememberedLogin != null;

  bool get rememberMe => _rememberMe;

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  /// Mengisi kolom login dari identitas tersimpan tanpa menimpa ketikan
  /// pengguna yang sedang berlangsung.
  void _prefillRememberedLogin() {
    final saved = _data.rememberedLogin;
    if (saved == null) return;
    if (_username.isEmpty) _username = saved.identifier;
    final restored = UserRole.fromName(saved.roleName);
    if (restored != null) _role = restored;
    _password = '';
  }

  /// Menghapus identitas tersimpan (tombol "Bukan saya?" dan saat keluar).
  void forgetRememberedLogin() {
    if (_data.rememberedLogin == null) return;
    _username = '';
    _password = '';
    _role = null;
    _error = '';
    _persistData(_data.copyWith(clearRememberedLogin: true));
  }

  /// Menjalankan aksi "masuk sebagai" dari kartu login tersimpan.
  ///
  /// Hanya mengisi form dengan identitas tersimpan; kata sandi tetap harus
  /// diketik karena tidak pernah disimpan.
  void useRememberedLogin() {
    final saved = _data.rememberedLogin;
    if (saved == null) return;
    _username = saved.identifier;
    _password = '';
    _role = UserRole.fromName(saved.roleName);
    _error = '';
    _screen = 'login';
    notifyListeners();
  }

  void setScreen(String nextScreen) {
    // Meninggalkan layar kuis membatalkan konteks latihan. Tanpa ini, kuis
    // tugas berikutnya bisa memakai bank soal latihan yang ditinggalkan.
    if (nextScreen != 'quiz' && nextScreen != 'practiceResult') {
      _quizForPractice = false;
    }
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

  /// Mencari peran yang cocok dengan identitas dan kata sandi.
  ///
  /// Form login sekarang satu untuk semua peran: pengguna tidak memilih peran
  /// lebih dulu, melainkan cukup mengetik NIP/NISN. Peran ditentukan dari akun
  /// demo yang identitasnya cocok, dan baru setelah itu kata sandinya diperiksa
  /// supaya pesan galat tidak membocorkan akun mana yang ada.
  UserRole? roleForCredentials(String identifier, String password) {
    final userIn = identifier.trim();
    for (final role in UserRole.values) {
      final account = DemoAccount.forRole(role);
      if (account.id == userIn && account.password == password) {
        return role;
      }
    }
    return null;
  }

  /// Apakah suatu identitas dikenal (tanpa memeriksa kata sandi).
  ///
  /// Dipakai untuk menampilkan label kolom (NIP/NISN) dan saran peran saat
  /// pengguna mulai mengetik, bukan untuk menyatakan login berhasil.
  UserRole? roleForIdentifier(String identifier) {
    final userIn = identifier.trim();
    if (userIn.isEmpty) return null;
    for (final role in UserRole.values) {
      if (DemoAccount.forRole(role).id == userIn) return role;
    }
    return null;
  }

  /// Peran yang sedang diisyaratkan form login.
  ///
  /// Hasil ketikan identitas yang dikenal menang; kalau belum dikenal, pakai
  /// peran tersimpan atau operator sebagai tampilan awal label.
  UserRole get loginHintRole =>
      roleForIdentifier(_username) ??
      UserRole.fromName(_data.rememberedLogin?.roleName ?? '') ??
      UserRole.operator;

  bool authenticate([String? customUsername, String? customPassword]) {
    final userIn = (customUsername ?? _username).trim();
    final passIn = customPassword ?? _password;

    if (userIn.isEmpty) {
      _error = 'Isi NIP atau NISN terlebih dahulu.';
      notifyListeners();
      return false;
    }
    if (passIn.isEmpty) {
      _error = 'Isi kata sandi terlebih dahulu.';
      notifyListeners();
      return false;
    }

    final resolved = roleForCredentials(userIn, passIn);
    if (resolved == null) {
      _error = 'NIP/NISN atau kata sandi tidak sesuai.';
      notifyListeners();
      return false;
    }
    _role = resolved;

    var nextData = _data;
    if (resolved == UserRole.siswa) {
      final targetClass = AppConstants.studentClasses.contains(_data.studentClass)
          ? _data.studentClass
          : 'Kelas 5';
      nextData = nextData.copyWith(childClass: targetClass);
    } else if (resolved == UserRole.orangtua) {
      final targetClass = AppConstants.parentClasses.contains(_data.parentClass)
          ? _data.parentClass
          : 'Kelas 1';
      nextData = nextData.copyWith(childClass: targetClass);
    }

    // "Ingat saya": simpan identitas + peran saja, kata sandi tidak pernah.
    nextData = _rememberMe
        ? nextData.copyWith(
            rememberedLogin: RememberedLogin(
              identifier: userIn,
              roleName: resolved.name,
            ),
          )
        : nextData.copyWith(clearRememberedLogin: true);

    _error = '';
    _filter = resolved == UserRole.wali ? AppConstants.waliClass : 'Semua kelas';
    _tab = 'Beranda';
    _taskFilter = resolved.isTeacher ? 'Semua' : 'Aktif';
    _screen = 'main';
    _persistData(nextData);
    return true;
  }

  void logout() {
    _role = null;
    _screen = 'login';
    // Identitas tersimpan tetap dipakai supaya pengguna tidak mengetik ulang.
    final saved = _data.rememberedLogin;
    _username = saved?.identifier ?? '';
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

  /// Hanya guru (termasuk wali kelas) yang punya tab daftar tugas.
  bool get hasTasksTab => isGuru;

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
    _essayForTask = false;
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
    // Latihan memakai bank soal mapelnya sendiri. Tanpa cabang ini, kuis
    // latihan akan meminjam soal tugas terakhir yang dibuka.
    if (_quizForPractice) {
      final subject = _selectedPractice?.subject ?? _draftSubject;
      return CurriculumData.questionsFor(subject, _data.religion);
    }

    // Tugas yang soalnya dibuat asisten memakai soalnya sendiri; tanpa ini
    // soal hasil asisten tidak pernah tampil saat siswa mengerjakan kuis.
    final task = _selectedTask;
    if (task != null && task.hasOwnQuestions) return task.questions;

    final subj = task?.subject ?? _draftSubject;
    final savedReligion = _screen == 'result' && task != null
        ? _data.results[task.id]?.religion
        : null;
    final effectiveReligion = savedReligion ?? _data.religion;
    return CurriculumData.questionsFor(subj, effectiveReligion);
  }

  List<EssayPrompt> get currentEssayBank {
    // Dalam konteks tugas, esai memakai mapel tugas itu supaya siswa tidak
    // mendapat soal esai dari mata pelajaran lain.
    if (_essayForTask && _selectedTask != null) {
      return CurriculumData.exercisesFor(
        _selectedTask!.subject,
        _data.religion,
      );
    }
    final subj = _selectedPractice?.subject ?? _draftSubject;
    return CurriculumData.exercisesFor(subj, _data.religion);
  }

  void startQuiz() {
    // Mulai pilihan ganda untuk sebuah tugas.
    _essayForTask = false;
    _quizForPractice = false;
    _questionIndex = 0;
    _choiceIndex = null;
    _checked = false;
    _answers = <int>[];
    _screen = 'quiz';
    notifyListeners();
  }

  /// Memulai **pilihan ganda** dari sebuah latihan. Skornya disimpan terpisah
  /// dari tugas supaya nilai tugas tidak tercampur nilai latihan.
  void startPracticeQuiz() {
    if (_selectedPractice == null) return;
    _essayForTask = false;
    _quizForPractice = true;
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
    // Latihan tidak punya `_selectedTask`, jadi syaratnya harus mengikuti
    // konteks: latihan butuh `_selectedPractice`, tugas butuh `_selectedTask`.
    if (_choiceIndex == null) return;
    if (_quizForPractice ? _selectedPractice == null : _selectedTask == null) {
      return;
    }
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

      // === Kuis latihan: simpan skor terpisah, jangan sentuh nilai tugas ===
      if (_quizForPractice) {
        final practice = _selectedPractice!;
        final notif = _buildNotification(
          target: 'teachers',
          subject: practice.subject,
          className: _data.childClass,
          title: '${_data.studentName} menyelesaikan latihan '
              '${practice.title} · $score/${bank.length}',
          kind: 'practice',
          contentId: practice.id,
        );
        _quizForPractice = false;
        _screen = 'practiceResult';
        _persistData(
          _data.copyWith(
            practiceDone: <String, bool>{
              ..._data.practiceDone,
              practice.id: true,
            },
            practiceResults: <String, TaskResult>{
              ..._data.practiceResults,
              practice.id: TaskResult(
                score: score,
                total: bank.length,
                answers: nextAnswers,
                religion: _data.religion,
                studentName: _data.studentName,
                className: _data.childClass,
              ),
            },
            localNotifications: <LocalNotification>[
              notif,
              ..._data.localNotifications,
            ],
          ),
        );
        return;
      }

      final task = _selectedTask!;
      // Pertahankan jawaban esai yang mungkin sudah dikirim siswa lebih dulu;
      // mengerjakan pilihan ganda tidak boleh menghapus bagian esai.
      final previousResult = _data.results[task.id];
      final nextResults = <String, TaskResult>{
        ..._data.results,
        task.id: TaskResult(
          score: score,
          total: bank.length,
          answers: nextAnswers,
          religion: _data.religion,
          studentName: _data.studentName,
          className: task.className,
          essayAnswers: previousResult?.essayAnswers ?? const <String>[],
          essayAt: previousResult?.essayAt,
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

  /// Memulai **bagian esai** dari sebuah tugas. Berbeda dari latihan mandiri:
  /// bank soal mengikuti mapel tugas dan jawaban disimpan ke `TaskResult`.
  void startTaskEssay() {
    final task = _selectedTask;
    if (task == null) return;
    _essayForTask = true;
    _questionIndex = 0;
    _essay = '';
    _showExample = false;
    _returnScreen = 'taskDetail';
    // Lanjutkan jawaban yang sudah tersimpan bila siswa kembali lagi.
    final saved = _data.results[task.id]?.essayAnswers ?? const <String>[];
    _essayDrafts = List<String>.from(saved);
    while (_essayDrafts.length < currentEssayBank.length) {
      _essayDrafts.add('');
    }
    _error = '';
    _screen = 'essay';
    notifyListeners();
  }

  /// Menyimpan seluruh jawaban esai tugas lalu membuka layar hasil.
  void submitTaskEssay() {
    final task = _selectedTask;
    if (task == null) return;
    final bank = currentEssayBank;
    final answers = <String>[
      for (var i = 0; i < bank.length; i++)
        i < _essayDrafts.length ? _essayDrafts[i].trim() : '',
    ];
    if (answers.every((a) => a.isEmpty)) {
      _error = 'Tulis minimal satu jawaban esai sebelum mengirim.';
      notifyListeners();
      return;
    }

    final previous = _data.results[task.id];
    final notif = _buildNotification(
      target: 'teachers',
      subject: task.subject,
      className: task.className,
      title: '${_data.studentName} mengirim jawaban esai ${task.title}',
      kind: 'task',
      contentId: task.id,
    );
    _error = '';
    _notice = 'Jawaban esai tersimpan di perangkat ini. Esai tidak dinilai '
        'otomatis; guru dapat melihat jawabanmu.';
    _essayForTask = false;
    _screen = 'result';
    _persistData(
      _data.copyWith(
        results: <String, TaskResult>{
          ..._data.results,
          task.id: TaskResult(
            // Pertahankan skor pilihan ganda yang sudah ada, bila ada.
            score: previous?.score,
            total: previous?.total,
            answers: previous?.answers ?? const <int>[],
            demo: previous?.demo ?? false,
            submittedOnly: previous?.submittedOnly ?? false,
            religion: previous?.religion,
            studentName: _data.studentName,
            className: task.className,
            essayAnswers: answers,
            essayAt: DateTime.now().toUtc().toIso8601String(),
          ),
        },
        localNotifications: <LocalNotification>[notif, ..._data.localNotifications],
      ),
    );
  }

  void startPractice() {
    if (!isTeacher) _returnScreen = 'main';
    _essayForTask = false;
    _questionIndex = 0;
    _essay = '';
    _essayDrafts = <String>[];
    _showExample = false;
    _screen = 'essay';
    notifyListeners();
  }

  void updateEssay(String val) {
    _essay = val;
    // Simpan per nomor soal, baik untuk esai tugas maupun latihan. Sebelumnya
    // hanya esai tugas yang menyimpan draft; pada latihan jawaban soal
    // sebelumnya ikut hilang begitu siswa pindah soal.
    while (_essayDrafts.length <= _questionIndex) {
      _essayDrafts.add('');
    }
    _essayDrafts[_questionIndex] = val;
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
      // Esai bagian tugas: kirim ke penyimpanan tugas, bukan status latihan.
      if (_essayForTask) {
        submitTaskEssay();
        return;
      }
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
      // Setiap soal punya contoh jawabannya sendiri. Sebelumnya `_showExample`
      // tidak pernah kembali false, jadi "Lihat contoh jawaban" hanya muncul di
      // soal pertama dan soal-soal berikutnya bisa terlewat tanpa contoh.
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

    // Pengumuman guru tidak terikat satu kelas: pilihannya "Semua kelas" atau
    // salah satu kelas yang diajar mapelnya. Sebelumnya kelas awal diambil
    // dari `_filter` (filter daftar tugas), sehingga guru Matematika bisa
    // membuka form dengan "Kelas 1" yang tidak ada hubungannya.
    if (kind == 'announcementForm' && isGuru) {
      final taught = teacherClasses;
      _draftClass = taught.isEmpty
          ? 'Semua kelas'
          : (taught.contains(_filter) ? _filter : taught.first);
      _draftMinutes = '30';
      _draftDue = KarsaDateUtils.formatDateKey(
        DateTime.now().add(const Duration(days: 7)),
      );
      _error = '';
      _notice = '';
      _attachment = null;
      _sourceText = '';
      _summaryText = '';
      _assistantSource = '';
      _assistantQuestions = <QuizQuestion>[];
      _assistantUsed = false;
      _screen = kind;
      notifyListeners();
      return;
    }

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
    _assistantSource = '';
    _assistantQuestions = <QuizQuestion>[];
    _assistantUsed = false;
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

  /// Menulis teks bahan untuk simulasi asisten penyusun soal.
  void setAssistantSource(String val) {
    _assistantSource = val;
    if (_error.isNotEmpty) _error = '';
    notifyListeners();
  }

  /// Menjalankan simulasi asisten: ubah bahan menjadi soal.
  ///
  /// Sumber teks diambil dari tempelan guru/wali; kalau kosong, dipakai isi
  /// file `.txt` yang sudah dilampirkan. PDF **tidak** dibaca — itu batasan
  /// jujur demo offline, dan alasannya ditampilkan ke pengguna.
  void generateQuestionsFromMaterial() {
    final attachmentText = _sourceText.trim();
    final text = _assistantSource.trim().isNotEmpty
        ? _assistantSource.trim()
        : attachmentText;

    if (text.isEmpty) {
      _error = 'Tempel teks bahan ajar dulu (atau unggah file .txt). '
          'PDF belum bisa dibaca otomatis di demo ini.';
      _assistantQuestions = <QuizQuestion>[];
      _assistantUsed = false;
      notifyListeners();
      return;
    }

    final draft = const QuizDraftService().draftQuestions(
      text,
      count: QuizDraftService.questionsPerTask,
    );

    if (draft.isEmpty) {
      // Bahan terlalu pendek: jangan mengarang soal, pakai bank contoh saja.
      _assistantQuestions = <QuizQuestion>[];
      _assistantUsed = false;
      _error = 'Bahan terlalu pendek untuk dijadikan soal (minimal dua '
          'kalimat lengkap). Tambah teks atau pakai kuis contoh.';
      notifyListeners();
      return;
    }

    _assistantQuestions = draft;
    _assistantUsed = true;
    _error = '';
    if (_draftTitle.trim().isEmpty) {
      _draftTitle = 'Tugas $_draftSubject';
    }
    _notice = '${draft.length} soal dibuat dari bahan yang ditempel '
        '(simulasi offline, bukan AI sungguhan).';
    notifyListeners();
  }

  /// Membuang soal hasil asisten dan kembali ke bank soal contoh.
  void clearAssistantQuestions() {
    _assistantQuestions = <QuizQuestion>[];
    _assistantUsed = false;
    _notice = '';
    _error = '';
    notifyListeners();
  }

  /// Soal yang dipakai untuk [task].
  ///
  /// Tugas hasil asisten memakai soalnya sendiri; tugas lain memakai bank soal
  /// contoh sesuai mata pelajaran dan agama siswa.
  List<QuizQuestion> questionsForTask(TaskItem task) {
    if (task.hasOwnQuestions) return task.questions;
    return CurriculumData.questionsFor(task.subject, _data.religion);
  }

  void useExampleQuizForTask() {
    _attachment = null;
    _draftBody = 'quiz';
    _assistantQuestions = <QuizQuestion>[];
    _assistantUsed = false;
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
    // Bahan berganti -> soal dari asisten yang lama tidak relevan lagi.
    _assistantQuestions = <QuizQuestion>[];
    _assistantUsed = false;
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
    if (_attachment == null && _draftBody.isEmpty && !_assistantUsed) {
      _error = 'Lampirkan file tugas, jalankan asisten, atau pilih buat kuis contoh.';
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
      questions: _assistantUsed
          ? List<QuizQuestion>.unmodifiable(_assistantQuestions)
          : const <QuizQuestion>[],
      questionsSource: _assistantUsed ? 'assistant' : 'example',
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
    // Wali & operator tidak punya tab 'Tugas'; mereka kembali ke Beranda
    // supaya layar tidak kosong setelah tugas disimpan.
    changeTab(hasTasksTab ? 'Tugas' : 'Beranda');
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
    // Guru mapel hanya boleh mengumumkan ke kelas yang diajar atau ke semua
    // kelas. Ini penjaga terakhir kalau kelas dipilih lewat jalur lain.
    if (isGuru &&
        _draftClass != 'Semua kelas' &&
        !teacherClasses.contains(_draftClass)) {
      _error = '$_draftClass bukan kelas yang kamu ajar.';
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
    _draftTitle = isOperator
        ? _data.operatorName
        : isWali
            ? _data.waliName
            : isTeacher
                ? _data.teacherName
                : _data.studentName;
    if (isOperator) {
      final profile = _data.operatorProfile;
      _draftOperatorNip = profile.nip;
      _draftOperatorRole = profile.role;
      _draftOperatorEmail = profile.email;
      _draftOperatorPhone = profile.phone;
      _draftOperatorUnit = profile.unit;
    }
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
    // Operator punya profil lengkap (NIP, jabatan, kontak, unit) sehingga
    // validasinya ditangani terpisah.
    if (isOperator) {
      saveOperatorProfileForm();
      return;
    }
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
