import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_language.dart';
import '../../data/mock_data.dart';
import '../../models/user_model.dart';
import '../../models/class_model.dart';
import '../../models/attendance_model.dart';
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

  // ដំណើរការស្កេន QR Code កត់វត្តមានចូល Database (Step 2)
  Future<void> _processScan(String qrToken) async {
    if (qrToken.trim().isEmpty) return;

    // បង្ហាញ Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final result = await AttendanceService.scanAttendance(qrToken.trim());

    if (!mounted) return;
    Navigator.pop(context); // បិទ Loading Dialog

    if (result['success'] == true) {
      final AttendanceModel? att = result['attendance'] as AttendanceModel?;
      _showScanSuccessDialog(att, qrToken.trim());
    } else {
      _showScanErrorDialog(result['message'] as String? ?? 'ការស្កេនបរាជ័យ');
    }
  }

  // បង្ហាញផ្ទាំងជោគជ័យក្រោយពេលកត់វត្តមានចូល Database រួចរាល់
  void _showScanSuccessDialog(AttendanceModel? att, String qrToken) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              AppLanguage.tr('បានកត់វត្តមានជោគជ័យ!', 'Attendance Marked Successfully!'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textCol,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLanguage.tr(
                'ទិន្នន័យវត្តមានរបស់អ្នកត្រូវបានកត់ត្រាចូលក្នុង Database រួចរាល់។',
                'Your attendance record has been saved to the Database.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: subTextCol),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLanguage.tr('មុខវិជ្ជា៖', 'Subject:'), style: TextStyle(fontSize: 13, color: subTextCol)),
                      Flexible(
                        child: Text(
                          att?.subjectName ?? 'ថ្នាក់រៀន',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textCol),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLanguage.tr('កូដ QR៖', 'QR Token:'), style: TextStyle(fontSize: 13, color: subTextCol)),
                      Text(
                        qrToken,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLanguage.tr('ស្ថានភាព៖', 'Status:'), style: TextStyle(fontSize: 13, color: subTextCol)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppLanguage.tr('វត្តមាន (Present)', 'Present'),
                          style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(AppLanguage.tr('យល់ព្រម', 'Done'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // បង្ហាញផ្ទាំង Error បើការស្កេនបរាជ័យ (ឧ. QR បិទ ឬខុស Token)
  void _showScanErrorDialog(String errorMsg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              AppLanguage.tr('ការស្កេនមិនជោគជ័យ!', 'Scan Failed!'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textCol,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: subTextCol),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(AppLanguage.tr('ព្យាយាមម្តងទៀត', 'Try Again'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerWidget({required bool isTop, required bool isLeft}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Colors.greenAccent, width: 3) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Colors.greenAccent, width: 3) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Colors.greenAccent, width: 3) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Colors.greenAccent, width: 3) : BorderSide.none,
        ),
      ),
    );
  }

  void _handleScanQr() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final activeClasses = _classes.where((c) => c.isQrActive || (c.qrToken != null && c.qrToken!.isNotEmpty)).toList();
    final tokenController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle Bar
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF475569) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLanguage.tr('ស្កេន QR កត់វត្តមាន', 'Scan Attendance QR'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textCol,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: subTextCol),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Camera Viewfinder Simulation
                    Container(
                      width: double.infinity,
                      height: 170,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 44,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                AppLanguage.tr(
                                  'ដាក់កាមេរ៉ាឱ្យចំ QR Code របស់គ្រូ',
                                  'Point camera at the teacher\'s QR code',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // Viewfinder Corners
                          Positioned(
                            top: 12,
                            left: 12,
                            child: _buildCornerWidget(isTop: true, isLeft: true),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: _buildCornerWidget(isTop: true, isLeft: false),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: _buildCornerWidget(isTop: false, isLeft: true),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: _buildCornerWidget(isTop: false, isLeft: false),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Active Broadcasted Classes (1-Tap Fast Scan)
                    if (activeClasses.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              AppLanguage.tr('ថ្នាក់កំពុងផ្សាយ QR Code (ស្កេនរហ័ស)', 'Live Broadcasting Classes (Quick Scan)'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...activeClasses.take(2).map((c) {
                        final token = c.qrToken ?? 'SCANIN-${c.subjectCode}-2026';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.4) : const Color(0xFFBBF7D0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF16A34A), size: 22),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.subjectName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textCol),
                                    ),
                                    Text(
                                      '${c.room} · Code: $token',
                                      style: TextStyle(fontSize: 11, color: subTextCol),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(sheetContext);
                                  _processScan(token);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(AppLanguage.tr('ស្កេនភ្លាម', 'Scan Now'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],

                    // Manual Input
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLanguage.tr('ឬបញ្ចូលកូដ QR ដោយដៃ', 'Or enter QR code token manually'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textCol,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tokenController,
                            style: TextStyle(color: textCol, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: AppLanguage.tr('ឧទាហរណ៍៖ SCANIN-CS101-W06', 'e.g. SCANIN-CS101-W06'),
                              hintStyle: TextStyle(color: subTextCol.withValues(alpha: 0.7), fontSize: 13),
                              filled: true,
                              fillColor: inputBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderCol),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderCol),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            final val = tokenController.text.trim();
                            if (val.isNotEmpty) {
                              Navigator.pop(sheetContext);
                              _processScan(val);
                            }
                          },
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: Text(AppLanguage.tr('កត់វត្តមាន', 'Submit')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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
