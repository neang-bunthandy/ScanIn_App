import 'package:flutter/material.dart';
import '../screens/admin_login_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_lecturers_screen.dart';
import '../screens/admin_students_screen.dart';
import '../screens/admin_classes_screen.dart';
import '../screens/admin_attendances_screen.dart';
import '../screens/admin_student_stats_screen.dart';

/// កំណត់ឈ្មោះ Route ទាំងអស់ក្នុង Admin Panel (Web)
class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String lecturers = '/lecturers';
  static const String students = '/students';
  static const String classes = '/classes';
  static const String attendances = '/attendances';
  static const String studentStats = '/reports/student-stats';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const AdminLoginScreen(),
        dashboard: (context) => const AdminDashboardScreen(),
        lecturers: (context) => const AdminLecturersScreen(),
        students: (context) => const AdminStudentsScreen(),
        classes: (context) => const AdminClassesScreen(),
        attendances: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as int?;
          return AdminAttendancesScreen(initialClassId: args);
        },
        studentStats: (context) => const AdminStudentStatsScreen(),
      };
}
