import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../data/mock_data.dart';
import '../../models/class_model.dart';
import '../../models/user_model.dart';
import '../../models/attendance_model.dart';
import 'class_detail_screen.dart';
import 'show_qr_screen.dart';
import 'create_class_screen.dart';
import 'attendance_list_screen.dart';

class LecturerHomeScreen extends StatefulWidget {
  final String? lecturerEmail;

  const LecturerHomeScreen({super.key, this.lecturerEmail});

  @override
  State<LecturerHomeScreen> createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  int _currentIndex = 0;

  UserModel get lecturer {
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

  // Filter & Search in Attendance Tab
  int? _selectedClassFilterId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _classes = List.from(MockData.sampleClasses);
    _classQrActive = {
      for (var c in _classes) c.id: c.isQrActive,
    };
    _attendanceRecords = List.from(MockData.sampleAttendances);
  }

  // បើក/បិទ QR សម្រាប់ថ្នាក់រៀន
  void _toggleQrForClass(ClassModel c) {
    final currentStatus = _classQrActive[c.id] ?? false;
    setState(() {
      _classQrActive[c.id] = !currentStatus;
    });

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
    setState(() {
      _classQrActive[c.id] = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                        color: Colors.grey.shade300,
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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${c.room} · ${c.dayOfWeek} ${c.time}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
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

                    // Beautiful Simulated QR Code Container
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
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_2_rounded,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Center Badge
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Token Text & Remaining Time
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          const Text(
                            'សុពលភាព៖ 04:59 នាទី',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '•  $token',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Attendance Live Counter Bar
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.people_alt_rounded, size: 18, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text(
                                    'និស្សិតបានស្កេនចូលរៀន',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
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
                              backgroundColor: Colors.grey.shade200,
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
                        // Button 1: បង្កើត QR ថ្មី (Regenerate)
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Button 2: បញ្ចប់ការកត់វត្តមាន (Finish)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _toggleQrForClass(c);
                            },
                            icon: const Icon(Icons.stop_circle_outlined, size: 18),
                            label: const Text('បញ្ចប់ការស្កេន'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
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

  // QR Corner Marker Finder Widget
  static Widget _buildQrFinderCorner() {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
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

  // QR Tiny Dot Visual
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

  // បង្កើត ឬកែប្រែថ្នាក់រៀន
  Future<void> _navigateToCreateClass({ClassModel? initialClass}) async {
    final result = await Navigator.push<ClassModel>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateClassScreen(initialClass: initialClass),
      ),
    );

    if (result != null) {
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

  // លុបថ្នាក់រៀន
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

  // កែប្រែវត្តមានសិស្សដោយផ្ទាល់
  void _showEditStudentAttendanceModal(AttendanceModel item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'កែប្រែវត្តមាន: ${item.studentName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'អត្តលេខ៖ ${item.studentCode}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
                  title: const Text('វត្តមាន (Present)', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: item.isPresent ? const Icon(Icons.done, color: Color(0xFF16A34A)) : null,
                  onTap: () {
                    Navigator.pop(context);
                    _updateAttendanceStatus(item, 'present');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time_filled_rounded, color: Color(0xFFD97706)),
                  title: const Text('មកយឺត (Late)', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: item.isLate ? const Icon(Icons.done, color: Color(0xFFD97706)) : null,
                  onTap: () {
                    Navigator.pop(context);
                    _updateAttendanceStatus(item, 'late');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626)),
                  title: const Text('អវត្តមាន (Absent)', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: item.isAbsent ? const Icon(Icons.done, color: Color(0xFFDC2626)) : null,
                  onTap: () {
                    Navigator.pop(context);
                    _updateAttendanceStatus(item, 'absent');
                  },
                ),
              ],
            ),
          ),
        );
      },
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            _buildAttendanceTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFF94A3B8),
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

  // ==========================================
  // Tab 1: ទំព័រដើម (Home Tab)
  // ==========================================
  Widget _buildHomeTab() {
    // ថ្នាក់ដែលត្រូវបង្ហាញ QR លំនាំដើម
    final defaultClass = _classes.firstWhere(
      (c) => (_classQrActive[c.id] ?? false),
      orElse: () => _classes.isNotEmpty ? _classes.first : MockData.sampleClasses.first,
    );

    // គណនាស្ថិតិរួម
    final totalStudents = _classes.fold<int>(0, (sum, c) => sum + c.studentCount);
    final activeQrCount = _classQrActive.values.where((active) => active).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Header (សួស្តី & តួនាទី) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'សួស្តី, លោកគ្រូ ${lecturer.name} 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ថ្ងៃព្រហស្បតិ៍ 15 តុលា 2026 • ${lecturer.department ?? 'ដេប៉ាតឺម៉ង់ IT'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  lecturer.name.substring(0, 1),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- 2. Big Action Button (📱 បង្ហាញ QR កត់វត្តមាន) ---
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showQrBottomSheet(defaultClass),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'បង្ហាញ QR កត់វត្តមាន',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeQrCount > 0
                                  ? 'កំពុងបើក QR សម្រាប់ $activeQrCount ថ្នាក់ (ចុចមើល)'
                                  : 'ចុចដើម្បីបង្ហាញ QR សម្រាប់និស្សិតស្កេន',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- 3. Teaching Summary Cards (ស្ថិតិបង្រៀន) ---
          const Text(
            'ស្ថិតិបង្រៀន',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // ថ្នាក់បង្រៀន (Classes)
              Expanded(
                child: _buildStatCard(
                  count: '${_classes.length}',
                  label: 'ថ្នាក់បង្រៀន',
                  bgColor: const Color(0xFFEFF6FF),
                  borderColor: const Color(0xFFBFDBFE),
                  textColor: const Color(0xFF1D4ED8),
                ),
              ),
              const SizedBox(width: 12),

              // សិស្សសរុប (Total Students)
              Expanded(
                child: _buildStatCard(
                  count: '$totalStudents',
                  label: 'សិស្សសរុប',
                  bgColor: const Color(0xFFF5F3FF),
                  borderColor: const Color(0xFFDDD6FE),
                  textColor: const Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 12),

              // វត្តមានមធ្យម (Avg Attendance) - Clickable to go to Attendance tab
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _currentIndex = 1),
                    child: _buildStatCard(
                      count: '94%',
                      label: 'វត្តមានមធ្យម',
                      bgColor: const Color(0xFFF0FDF4),
                      borderColor: const Color(0xFFBBF7D0),
                      textColor: const Color(0xFF16A34A),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // --- 4. Teaching Classes Section Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ថ្នាក់បង្រៀនរបស់ខ្ញុំ (${_classes.length})',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () => _navigateToCreateClass(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('បង្កើតថ្នាក់'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // --- 5. Class Cards List ---
          if (_classes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36.0),
                child: Column(
                  children: [
                    Icon(Icons.school_outlined, size: 54, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      'លោកគ្រូមិនទាន់មានថ្នាក់បង្រៀននៅឡើយទេ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToCreateClass(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('បង្កើតថ្នាក់ដំបូង'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _classes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final c = _classes[index];
                return _buildClassCard(c);
              },
            ),
        ],
      ),
    );
  }

  // Stat Card Widget
  Widget _buildStatCard({
    required String count,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Class Card Widget for Lecturer
  Widget _buildClassCard(ClassModel c) {
    final isQrActive = _classQrActive[c.id] ?? false;
    final progress = c.completedSessions / (c.totalSessions > 0 ? c.totalSessions : 1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isQrActive ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border,
          width: isQrActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Subject Code & Name + QR Status + More Options
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    c.subjectCode,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.subjectName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                // QR Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: isQrActive ? const Color(0xFFF0FDF4) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isQrActive ? const Color(0xFFBBF7D0) : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 7,
                        color: isQrActive ? const Color(0xFF16A34A) : Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isQrActive ? 'បើក QR' : 'បិទ QR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isQrActive ? const Color(0xFF16A34A) : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Popup Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (val) {
                    if (val == 'fullscreen_qr') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowQrScreen(classModel: c),
                        ),
                      );
                    } else if (val == 'attendance_list') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceListScreen(classModel: c),
                        ),
                      );
                    } else if (val == 'edit') {
                      _navigateToCreateClass(initialClass: c);
                    } else if (val == 'delete') {
                      _confirmDeleteClass(c);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'fullscreen_qr',
                      child: Row(
                        children: [
                          Icon(Icons.fullscreen_rounded, size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('QR ពេញអេក្រង់ (Projector)'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'attendance_list',
                      child: Row(
                        children: [
                          Icon(Icons.fact_check_rounded, size: 18, color: Color(0xFF0D9488)),
                          SizedBox(width: 8),
                          Text('បញ្ជីវត្តមានថ្នាក់នេះ'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                          SizedBox(width: 8),
                          Text('កែប្រែព័ត៌មានថ្នាក់'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('លុបថ្នាក់នេះ', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Class Schedule & Room Info
            Row(
              children: [
                const Icon(Icons.room_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  c.room,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${c.dayOfWeek} ${c.time}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress & Student Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'វគ្គសិក្សា ${c.completedSessions}/${c.totalSessions} (${(progress * 100).toInt()}%)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.people_outline_rounded, size: 15, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${c.studentCount} នាក់',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 5,
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // Card Bottom Actions
            Row(
              children: [
                // Button 1: បង្ហាញ QR Code
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showQrBottomSheet(c),
                    icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                    label: const Text('បង្ហាញ QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isQrActive ? AppColors.primary : const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Button 2: ព័ត៌មានលម្អិត & សិស្ស
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClassDetailScreen(classModel: c),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('មើលលម្អិត'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
  }

  // ==========================================
  // Tab 2: វត្តមាន & របាយការណ៍ (Attendance Tab)
  // ==========================================
  Widget _buildAttendanceTab() {
    // Filter attendance records
    var filteredList = _attendanceRecords;
    if (_selectedClassFilterId != null) {
      filteredList = filteredList.where((a) => a.classId == _selectedClassFilterId).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      filteredList = filteredList.where((a) {
        final q = _searchQuery.toLowerCase();
        return a.studentName.toLowerCase().contains(q) ||
            a.studentCode.toLowerCase().contains(q) ||
            (a.note?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'របាយការណ៍វត្តមាន',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'មើលបញ្ជីពេញលេញ',
                    onPressed: () {
                      final selectedClass = _selectedClassFilterId != null
                          ? _classes.firstWhere(
                              (c) => c.id == _selectedClassFilterId,
                              orElse: () => _classes.first,
                            )
                          : null;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceListScreen(classModel: selectedClass),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded, color: AppColors.primary),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.download_done_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text('បានទាញយករបាយការណ៍ Excel រួចរាល់'),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                    tooltip: 'ទាញយក Excel',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Search Field
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'ស្វែងរកសិស្ស ឬអត្តលេខ...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'ទាំងអស់',
                  isSelected: _selectedClassFilterId == null,
                  onSelected: () => setState(() => _selectedClassFilterId = null),
                ),
                const SizedBox(width: 8),
                for (var c in _classes) ...[
                  _buildFilterChip(
                    label: c.subjectName,
                    isSelected: _selectedClassFilterId == c.id,
                    onSelected: () => setState(() => _selectedClassFilterId = c.id),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Attendance Records List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_late_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'មិនមានទិន្នន័យវត្តមានទេ',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];

                      Color badgeColor;
                      Color badgeBg;
                      if (item.isPresent) {
                        badgeColor = const Color(0xFF16A34A);
                        badgeBg = const Color(0xFFF0FDF4);
                      } else if (item.isLate) {
                        badgeColor = const Color(0xFFD97706);
                        badgeBg = const Color(0xFFFFFBEB);
                      } else {
                        badgeColor = const Color(0xFFDC2626);
                        badgeBg = const Color(0xFFFEF2F2);
                      }

                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _showEditStudentAttendanceModal(item),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.35),
                                  child: Text(
                                    item.studentName.isNotEmpty ? item.studentName[0] : 'S',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.studentName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.studentCode} · ${item.note ?? 'វត្តមាន'}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.statusKhmer,
                                        style: TextStyle(
                                          color: badgeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Icon(Icons.arrow_drop_down, color: badgeColor, size: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // ==========================================
  // Tab 3: គណនីខ្ញុំ (Profile Tab)
  // ==========================================
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Profile Avatar & Identity Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 14),
                Text(
                  lecturer.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'អត្តលេខបុគ្គលិក៖ ${lecturer.staffId ?? 'STF001'}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    lecturer.department ?? 'ដេប៉ាតឺម៉ង់ព័ត៌មានវិទ្យា',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Contact Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  title: 'អ៊ីមែល',
                  value: lecturer.email,
                ),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  title: 'លេខទូរស័ព្ទ',
                  value: lecturer.phone ?? '098 765 432',
                ),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                _buildInfoTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'ឆ្នាំសិក្សា',
                  value: '2026-2027 (ឆមាសទី ១)',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('ចាកចេញពីគណនី'),
                    content: const Text('តើលោកគ្រូពិតជាចង់ចាកចេញពីកម្មវិធីមែនទេ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('បោះបង់'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Back to Login
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('ចាកចេញ'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: const Text(
                'ចាកចេញពីគណនី',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
