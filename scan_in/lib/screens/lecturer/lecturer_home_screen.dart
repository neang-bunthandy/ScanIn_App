import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../data/mock_data.dart';
import '../../models/class_model.dart';
import '../../models/user_model.dart';
import '../../models/attendance_model.dart';
import '../../services/auth_service.dart';
import '../../services/class_service.dart';
import 'create_class_screen.dart';
import 'show_qr_screen.dart';
import 'lecturer_dashboard_screen.dart';
import 'lecturer_attendance_screen.dart';
import 'lecturer_profile_screen.dart';

/// អេក្រង់មេរបស់គ្រូ (Lecturer Main Shell)
/// គ្រប់គ្រង BottomNavigationBar និងប្តូររវាងអេក្រង់ទាំង ៣
/// គាំទ្រ Dark Mode ទាំងស្រុងលើ Scaffold, BottomNavigationBar និងគ្រប់ Tabs
class LecturerHomeScreen extends StatefulWidget {
  final String? lecturerEmail;
  final UserModel? user;

  const LecturerHomeScreen({super.key, this.lecturerEmail, this.user});

  @override
  State<LecturerHomeScreen> createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  int _currentIndex = 0;
  UserModel? _cachedLecturer;

  UserModel get lecturer {
    if (widget.user != null) return widget.user!;
    if (_cachedLecturer != null) return _cachedLecturer!;
    if (widget.lecturerEmail != null && widget.lecturerEmail!.isNotEmpty) {
      return UserModel(
        id: MockData.currentLecturer.id,
        name: MockData.currentLecturer.name,
        email: widget.lecturerEmail!,
        role: MockData.currentLecturer.role,
        staffId: MockData.currentLecturer.staffId,
        department: MockData.currentLecturer.department,
        phone: MockData.currentLecturer.phone,
        avatarUrl: MockData.currentLecturer.avatarUrl,
        createdAt: MockData.currentLecturer.createdAt,
      );
    }
    return MockData.currentLecturer;
  }

  late List<ClassModel> _classes;
  late Map<int, bool> _classQrActive;
  late List<AttendanceModel> _attendanceRecords;

  bool _notificationsEnabled = true;
  String _selectedLanguage = 'ភាសាខ្មែរ (Khmer)';

  @override
  void initState() {
    super.initState();
    _classes = List.from(MockData.sampleClasses);
    _classQrActive = {
      for (var c in _classes) c.id: c.isQrActive,
    };
    _attendanceRecords = List.from(MockData.sampleAttendances);
    _loadBackendData();
  }

  Future<void> _loadBackendData() async {
    final cached = await AuthService.getCurrentUser();
    if (cached != null && mounted) {
      setState(() => _cachedLecturer = cached);
    }
    final remoteClasses = await ClassService.getLecturerClasses();
    if (mounted && remoteClasses.isNotEmpty) {
      setState(() {
        _classes = remoteClasses;
        _classQrActive = {
          for (var c in _classes) c.id: c.isQrActive,
        };
      });
    }
  }

  // បើក/បិទ QR សម្រាប់ថ្នាក់រៀន
  void _toggleQrForClass(ClassModel c) {
    final currentStatus = _classQrActive[c.id] ?? false;
    final newStatus = !currentStatus;
    setState(() {
      _classQrActive[c.id] = newStatus;
    });

    ClassService.toggleQr(c.id, newStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              !currentStatus ? Icons.check_circle_rounded : Icons.info_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                !currentStatus
                    ? 'បានបើកដំណើរការ QR សម្រាប់ ${c.subjectName}'
                    : 'បានបិទដំណើរការ QR សម្រាប់ ${c.subjectName}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: !currentStatus ? AppColors.success : AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // បង្ហាញ Bottom Sheet QR Code សម្រាប់និស្សិតស្កេន
  void _showQrBottomSheet(ClassModel c) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    setState(() {
      _classQrActive[c.id] = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final token = c.qrToken ?? 'SCANIN-${c.subjectCode}-2026';
            final scannedCount = (c.studentCount * 0.8).round();

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF475569) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.subjectName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textCol,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${c.room} · ${c.dayOfWeek} ${c.time}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subTextCol,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'បញ្ចាំងពេញអេក្រង់ (Projector)',
                          icon: const Icon(Icons.fullscreen_rounded, color: AppColors.primary, size: 28),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowQrScreen(classModel: c),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Simulated QR Code Container
                    Container(
                      width: 220,
                      height: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryLight, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildQrFinderCorner(),
                                  _buildQrFinderCorner(),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildQrDot(),
                                  _buildQrDot(),
                                  _buildQrDot(),
                                  _buildQrDot(),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildQrFinderCorner(),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_2_rounded,
                                      color: Color(0xFF16A34A),
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // QR Code Expiry & Token indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF16A34A).withValues(alpha: isDark ? 0.4 : 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.security_update_good_rounded, color: Color(0xFF16A34A), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Dynamic QR Code: $token',
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Live Scan Progress Counter
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.people_alt_rounded, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'និស្សិតបានស្កេនចូលរៀន',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: textCol,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$scannedCount / ${c.studentCount} នាក់',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: scannedCount / (c.studentCount > 0 ? c.studentCount : 1),
                              backgroundColor: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setSheetState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('បានបន្តសុពលភាព QR Code ថ្មី'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('បង្កើតថ្មី'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _toggleQrForClass(c);
                            },
                            icon: const Icon(Icons.stop_circle_outlined, size: 18),
                            label: const Text('បិទ QR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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

  static Widget _buildQrFinderCorner() {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AppColors.textPrimary, width: 4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  static Widget _buildQrDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Future<void> _navigateToCreateClass({ClassModel? initialClass}) async {
    final result = await Navigator.push<ClassModel>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateClassScreen(initialClass: initialClass),
      ),
    );

    if (result != null) {
      ClassService.createClass(result);
      setState(() {
        final existingIndex = _classes.indexWhere((c) => c.id == result.id);
        if (existingIndex != -1) {
          _classes[existingIndex] = result;
        } else {
          _classes.add(result);
          _classQrActive[result.id] = result.isQrActive;
        }
      });
    }
  }

  void _confirmDeleteClass(ClassModel c) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('លុបថ្នាក់រៀន'),
          ],
        ),
        content: Text('តើលោកគ្រូពិតជាចង់លុបថ្នាក់ "${c.subjectName}" (${c.subjectCode}) មែនទេ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('បោះបង់', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _classes.removeWhere((item) => item.id == c.id);
                _classQrActive.remove(c.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('បានលុបថ្នាក់ ${c.subjectName} រួចរាល់'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('លុបចេញ'),
          ),
        ],
      ),
    );
  }

  void _updateAttendanceStatus(AttendanceModel item, String newStatus) {
    setState(() {
      final index = _attendanceRecords.indexWhere((a) => a.id == item.id);
      if (index != -1) {
        _attendanceRecords[index] = AttendanceModel(
          id: item.id,
          classId: item.classId,
          studentId: item.studentId,
          studentName: item.studentName,
          studentCode: item.studentCode,
          status: newStatus,
          scannedAt: newStatus == 'absent' ? null : DateTime.now(),
          date: item.date,
          note: newStatus == 'present'
              ? 'កែប្រែដោយគ្រូ'
              : (newStatus == 'late' ? 'មកយឺត' : 'អវត្តមាន'),
          createdAt: item.createdAt,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('បានកែប្រែវត្តមាន ${item.studentName} រួចរាល់'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            LecturerDashboardScreen(
              lecturer: lecturer,
              classes: _classes,
              classQrActive: _classQrActive,
              onShowQr: _showQrBottomSheet,
              onToggleQr: _toggleQrForClass,
              onNavigateToCreateClass: _navigateToCreateClass,
              onConfirmDeleteClass: _confirmDeleteClass,
              onGoToAttendanceTab: () => setState(() => _currentIndex = 1),
            ),
            // Tab 2: វត្តមាន (Attendance)
            LecturerAttendanceScreen(
              classes: _classes,
              attendanceRecords: _attendanceRecords,
              onUpdateAttendanceStatus: _updateAttendanceStatus,
            ),
            // Tab 3: ខ្ញុំ (Profile)
            LecturerProfileScreen(
              lecturer: lecturer,
              classes: _classes,
              attendanceRecords: _attendanceRecords,
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'ដើម',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_outlined),
              activeIcon: Icon(Icons.fact_check_rounded),
              label: 'វត្តមាន',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'ខ្ញុំ',
            ),
          ],
        ),
      ),
    );
  }
}
