import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_language.dart';
import '../../data/mock_data.dart';
import '../../models/user_model.dart';
import '../../models/class_model.dart';
import '../../services/auth_service.dart';
import '../../services/class_service.dart';
import '../../services/attendance_service.dart';
import 'student_dashboard_screen.dart';
import 'student_history_screen.dart';
import 'student_profile_screen.dart';

/// អេក្រង់មេរបស់សិស្ស (Student Main Shell)
/// គ្រប់គ្រង BottomNavigationBar និងប្តូររវាងអេក្រង់ទាំង ៣
/// គាំទ្រ Dark Mode ទាំងស្រុងលើ Scaffold, BottomNavigationBar និងគ្រប់ Tabs
class StudentHomeScreen extends StatefulWidget {
  final String? studentEmail;
  final UserModel? user;

  const StudentHomeScreen({super.key, this.studentEmail, this.user});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;
  UserModel? _cachedStudent;
  List<ClassModel> _classes = List.from(MockData.sampleClasses);
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'ខ្មែរ (Khmer)';

  UserModel get student {
    if (widget.user != null) return widget.user!;
    if (_cachedStudent != null) return _cachedStudent!;
    if (widget.studentEmail != null && widget.studentEmail!.isNotEmpty) {
      return UserModel(
        id: MockData.currentStudent.id,
        name: MockData.currentStudent.name,
        email: widget.studentEmail!,
        role: MockData.currentStudent.role,
        studentCode: MockData.currentStudent.studentCode,
        department: MockData.currentStudent.department,
        phone: MockData.currentStudent.phone,
        avatarUrl: MockData.currentStudent.avatarUrl,
        createdAt: MockData.currentStudent.createdAt,
      );
    }
    return MockData.currentStudent;
  }

  List<ClassModel> get classes => _classes;

  @override
  void initState() {
    super.initState();
    _loadBackendData();
  }

  Future<void> _loadBackendData() async {
    final cached = await AuthService.getCurrentUser();
    if (cached != null && mounted) {
      setState(() => _cachedStudent = cached);
    }
    final remoteClasses = await ClassService.getStudentClasses();
    if (mounted && remoteClasses.isNotEmpty) {
      setState(() => _classes = remoteClasses);
    }
  }

  void _handleScanQr() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: isDark ? 0.2 : 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLanguage.tr('កាមេរ៉ាស្កេន QR វត្តមាន', 'Attendance QR Camera Scanner'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textCol,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLanguage.tr(
                    'សូមដាក់កាមេរ៉ាឱ្យចំ QR Code របស់គ្រូដើម្បីកត់វត្តមាន',
                    'Please point your camera at the teacher\'s QR code to mark attendance',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: subTextCol,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(context);
                      final result = await AttendanceService.scanAttendance('SCANIN-TOKEN-CS301-2026');
                      messenger.showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                result['success'] == true ? Icons.check_circle_rounded : Icons.info_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(result['message'] as String),
                              ),
                            ],
                          ),
                          backgroundColor: result['success'] == true ? AppColors.success : AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLanguage.tr('សាកល្បងស្កេនជោគជ័យ', 'Test Successful Scan'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLanguage,
      builder: (context, currentLang, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
        final navBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final navBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        final unselectedCol = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                // Tab 1: ដើម (Dashboard)
                StudentDashboardScreen(
                  student: student,
                  classes: classes,
                  onScanQr: _handleScanQr,
                ),
                // Tab 2: ប្រវត្តិ (History)
                StudentHistoryScreen(),
                // Tab 3: ខ្ញុំ (Profile)
                StudentProfileScreen(
                  student: student,
                  notificationsEnabled: _notificationsEnabled,
                  selectedLanguage: _selectedLanguage,
                  onToggleNotifications: (val) {
                    setState(() => _notificationsEnabled = val);
                  },
                  onLanguageChanged: (lang) {
                    setState(() => _selectedLanguage = lang);
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: navBg,
              border: Border(
                top: BorderSide(color: navBorder, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: navBg,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: unselectedCol,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_rounded),
                  label: AppLanguage.tr('ដើម', 'Home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.fact_check_outlined),
                  activeIcon: const Icon(Icons.fact_check_rounded),
                  label: AppLanguage.tr('ប្រវត្តិ', 'History'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline_rounded),
                  activeIcon: const Icon(Icons.person_rounded),
                  label: AppLanguage.tr('ខ្ញុំ', 'Profile'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
