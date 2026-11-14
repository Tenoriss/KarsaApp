import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/dark_color_mapper.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/notice_card.dart';
import '../../features/announcements/announcement_detail_page.dart';
import '../../features/announcements/announcement_form_page.dart';
import '../../features/announcements/announcements_page.dart';
import '../../features/announcements/notifications_page.dart';
import '../../features/authentication/forgot_password_page.dart';
import '../../features/authentication/login_page.dart';
import '../../features/authentication/welcome_page.dart';
import '../../features/calendar/calendar_tab.dart';
import '../../features/dashboard/parent_home_tab.dart';
import '../../features/dashboard/student_home_tab.dart';
import '../../features/dashboard/teacher_home_tab.dart';
import '../../features/dashboard/wali_home_tab.dart';
import '../../features/grades/grade_recap_page.dart';
import '../../features/homeroom/agenda_detail_page.dart';
import '../../features/homeroom/agenda_form_page.dart';
import '../../features/homeroom/wali_agenda_tab.dart';
import '../../features/homeroom/wali_member_detail_page.dart';
import '../../features/homeroom/wali_members_tab.dart';
import '../../features/homeroom/wali_recap_tab.dart';
import '../../features/materials/material_detail_page.dart';
import '../../features/materials/material_form_page.dart';
import '../../features/materials/materials_page.dart';
import '../../features/quizzes/essay_practice_page.dart';
import '../../features/quizzes/practice_detail_sheet.dart';
import '../../features/quizzes/practice_form_page.dart';
import '../../features/quizzes/practice_list_tab.dart';
import '../../features/quizzes/practice_preview_page.dart';
import '../../features/quizzes/practice_result_page.dart';
import '../../features/quizzes/quiz_page.dart';
import '../../features/quizzes/quiz_result_page.dart';
import '../../features/settings/profile_tab.dart';
import '../../features/settings/setting_detail_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/student/learning_progress_page.dart';
import '../../features/tasks/task_detail_sheet.dart';
import '../../features/tasks/task_form_page.dart';
import '../../features/tasks/tasks_tab.dart';
import '../../features/teacher/student_detail_page.dart';
import '../../features/teacher/students_list_page.dart';
import '../../features/teacher/subject_detail_page.dart';
import '../../features/teacher/teacher_classes_tab.dart';
import '../../features/teacher/teacher_task_detail_page.dart';
import '../../models/user_role.dart';
import '../../providers/app_state.dart';
import 'detail_bottom_sheet.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  IconData _navIcon(String tabName) {
    switch (tabName) {
      case 'Beranda':
        return KarsaIcons.home;
      case 'Anggota':
      case 'Kelas':
        return KarsaIcons.people;
      case 'Rekap':
        return KarsaIcons.barChart;
      case 'Agenda':
      case 'Kalender':
        return KarsaIcons.calendar;
      case 'Tugas':
        return KarsaIcons.checkmarkCircle;
      case 'Latihan':
        return KarsaIcons.grid;
      case 'Profil':
      default:
        return KarsaIcons.person;
    }
  }

  Widget _mainTabBody(AppState state) {
    final role = state.role ?? UserRole.siswa;
    if (role == UserRole.wali) {
      switch (state.tab) {
        case 'Beranda':
          return const WaliHomeTab();
        case 'Anggota':
          return const WaliMembersTab();
        case 'Rekap':
          return const WaliRecapTab();
        case 'Agenda':
          return const WaliAgendaTab();
        default:
          return const ProfileTab();
      }
    }

    switch (state.tab) {
      case 'Beranda':
        if (role == UserRole.guru) return const TeacherHomeTab();
        if (role == UserRole.siswa) return const StudentHomeTab();
        return const ParentHomeTab();
      case 'Tugas':
        return const TasksTab();
      case 'Latihan':
        return const PracticeListTab();
      case 'Kelas':
        return const TeacherClassesTab();
      case 'Kalender':
        return const CalendarTab();
      default:
        return const ProfileTab();
    }
  }

  Widget _body(AppState state) {
    switch (state.screen) {
      case 'welcome':
        return const WelcomePage();
      case 'login':
        return const LoginPage();
      case 'forgot':
        return const ForgotPasswordPage();
      case 'main':
        return _mainTabBody(state);
      case 'taskDetail':
        return const TasksTab();
      case 'practiceDetail':
        return state.isStudent ? const TasksTab() : const PracticeListTab();
      case 'waliMember':
        return const WaliMemberDetailPage();
      case 'agendaForm':
        return const AgendaFormPage();
      case 'agendaDetail':
        return const AgendaDetailPage();
      case 'notifications':
        return const NotificationsPage();
      case 'materials':
        return const MaterialsPage();
      case 'materialDetail':
        return const MaterialDetailPage();
      case 'materialForm':
        return const MaterialFormPage();
      case 'announcements':
        return const AnnouncementsPage();
      case 'announcementDetail':
        return const AnnouncementDetailPage();
      case 'announcementForm':
        return const AnnouncementFormPage();
      case 'quiz':
        return const QuizPage();
      case 'result':
        return const QuizResultPage();
      case 'essay':
        return const EssayPracticePage();
      case 'practiceResult':
        return const PracticeResultPage();
      case 'teacherTask':
        return const TeacherTaskDetailPage();
      case 'gradeRecap':
        return state.isGuru ? const GradeRecapPage() : _mainTabBody(state);
      case 'subject':
        return const SubjectDetailPage();
      case 'practicePreview':
        return const PracticePreviewPage();
      case 'practiceForm':
        return const PracticeFormPage();
      case 'students':
        return const StudentsListPage();
      case 'studentDetail':
        return const StudentDetailPage();
      case 'taskForm':
        return const TaskFormPage();
      case 'progress':
        return const LearningProgressPage();
      case 'setting':
        return const SettingDetailPage();
      default:
        return const WelcomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final isSplash = state.screen == 'splash';
    final isLogin = state.screen == 'login';
    final isSheet = state.isSheetScreen;
    final showBottomNav =
        state.role != null && (state.screen == 'main' || isSheet);

    final outerBg = isSplash
        ? AppColors.splashSafeSky
        : DarkColorMapper.surface(AppColors.outerCanvasLight, isDark: c.isDark);

    return Scaffold(
      backgroundColor: outerBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: isSplash ? AppColors.splashSky : c.bg,
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: isSplash
                            ? const SplashPage()
                            : SingleChildScrollView(
                                key: ValueKey<String>(
                                  isSheet
                                      ? 'main:${state.tab}'
                                      : '${state.screen}:${state.tab}',
                                ),
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: isLogin
                                    ? EdgeInsets.zero
                                    : const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 30,
                                      ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    if (state.storageError)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: NoticeCard(
                                          title:
                                              'Penyimpanan lokal gagal. Perubahan mungkin tidak tersimpan; periksa ruang perangkat.',
                                          body: '',
                                        ),
                                      ),
                                    _body(state),
                                  ],
                                ),
                              ),
                      ),
                      if (showBottomNav) _BottomNavBar(navIcon: _navIcon),
                    ],
                  ),
                  if (isSheet)
                    DetailBottomSheet(
                      onClose: () => state.setScreen('main'),
                      child: state.screen == 'taskDetail'
                          ? const TaskDetailSheet()
                          : const PracticeDetailSheet(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final IconData Function(String) navIcon;

  const _BottomNavBar({required this.navIcon});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final tabs = state.role?.navTabs ?? const <String>[];
    final topBorder =
        DarkColorMapper.border(Colors.white, isDark: c.isDark);

    return Container(
      height: 76,
      decoration: ClayStyles.soft(
        color: const Color(0xFFFFFAF8),
        isDark: c.isDark,
        borderColor: topBorder,
        customRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((tabLabel) {
          final active = state.tab == tabLabel;
          return Expanded(
            child: MotionPressable(
              semanticsLabel: tabLabel,
              onTap: () => state.changeTab(tabLabel),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    navIcon(tabLabel),
                    size: 23,
                    color: active ? c.rose : AppColors.navInactive,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tabLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: active ? c.rose : c.muted,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
