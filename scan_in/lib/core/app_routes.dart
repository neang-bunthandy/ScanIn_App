import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/student/student_home_screen.dart';
import '../screens/lecturer/lecturer_home_screen.dart';
import '../screens/lecturer/class_detail_screen.dart';
import '../screens/lecturer/create_class_screen.dart';
import '../screens/lecturer/show_qr_screen.dart';
import '../screens/lecturer/attendance_list_screen.dart';
import '../data/mock_data.dart';

/// កំណត់ឈ្មោះ Route ទាំងអស់ក្នុងកម្មវិធី ScanIn
class AppRoutes {
  static const String login = '/login';
  static const String studentHome = '/student/home';
  static const String lecturerHome = '/lecturer/home';
  static const String classDetail = '/lecturer/class-detail';
  static const String createClass = '/lecturer/create-class';
  static const String showQr = '/lecturer/show-qr';
  static const String attendanceList = '/lecturer/attendance-list';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        studentHome: (context) => const StudentHomeScreen(),
        lecturerHome: (context) => const LecturerHomeScreen(),
        classDetail: (context) => const ClassDetailScreen(),
        createClass: (context) => const CreateClassScreen(),
        showQr: (context) => ShowQrScreen(classModel: MockData.sampleClasses.first),
        attendanceList: (context) => const AttendanceListScreen(),
      };
}
