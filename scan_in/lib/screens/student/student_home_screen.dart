import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../../data/mock_data.dart';
import '../../models/user_model.dart';
import '../../models/class_model.dart';
import '../lecturer/class_detail_screen.dart';
import '../../services/auth_service.dart';
import '../../services/class_service.dart';
import '../../services/attendance_service.dart';
import '../login_screen.dart';

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
    showModalBottomSheet(
      context: context,
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'កាមេរ៉ាស្កេន QR វត្តមាន',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'សូមដាក់កាមេរ៉ាឱ្យចំ QR Code របស់គ្រូដើម្បីកត់វត្តមាន',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
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
                    child: const Text(
                      'សាកល្បងស្កេនជោគជ័យ',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            _buildHistoryTab(),
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
              label: 'ប្រវត្តិ',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Header (សួស្តី & កាលបរិច្ឆេទ) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'សួស្តី, ${student.name} 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ថ្ងៃព្រហស្បតិ៍ 15 តុលា 2026',
                      style: TextStyle(
                        fontSize: 14,
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
                  student.name.substring(0, 1),
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

          // --- 2. Big Action Button (📷 ស្កេនវត្តមាន) ---
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _handleScanQr,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: AppColors.primary.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded, size: 26, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'ស្កេនវត្តមាន',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- 3. Monthly Attendance Summary (វត្តមានខែនេះ) ---
          const Text(
            'វត្តមានខែនេះ',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // មក (Present)
              Expanded(
                child: _buildStatCard(
                  count: MockData.presentCount.toString(),
                  label: 'មក',
                  bgColor: const Color(0xFFF0FDF4),
                  borderColor: const Color(0xFFBBF7D0),
                  textColor: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),

              // យឺត (Late)
              Expanded(
                child: _buildStatCard(
                  count: MockData.lateCount.toString(),
                  label: 'យឺត',
                  bgColor: const Color(0xFFFFFBEB),
                  borderColor: const Color(0xFFFDE68A),
                  textColor: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 12),

              // អវត្តមាន (Absent)
              Expanded(
                child: _buildStatCard(
                  count: MockData.absentCount.toString(),
                  label: 'អវត្តមាន',
                  bgColor: const Color(0xFFFEF2F2),
                  borderColor: const Color(0xFFFECACA),
                  textColor: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // --- 4. My Classes (ថ្នាក់របស់ខ្ញុំ) ---
          const Text(
            'ថ្នាក់របស់ខ្ញុំ',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: classes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final c = classes[index];
              return _buildClassCard(c);
            },
          ),
        ],
      ),
    );
  }

  // Card សង្ខេបវត្តមាន
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
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Card ថ្នាក់រៀន
  Widget _buildClassCard(ClassModel c) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassDetailScreen(classModel: c),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.subjectName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${c.lecturerName ?? 'គ្រូបង្រៀន'} · ${c.dayOfWeek} ${c.time}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                c.room.contains('Lab') ? 'Lab 3' : 'A204',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Tab 2: ប្រវត្តិវត្តមាន (History Tab)
  // ==========================================
  Widget _buildHistoryTab() {
    final attendances = MockData.sampleAttendances;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ប្រវត្តិវត្តមានទាំងអស់',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: attendances.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = attendances[index];
                Color badgeColor;
                if (item.isPresent) {
                  badgeColor = AppColors.success;
                } else if (item.isLate) {
                  badgeColor = AppColors.warning;
                } else {
                  badgeColor = AppColors.error;
                }

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.note ?? 'វត្តមាន',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'កាលបរិច្ឆេទ៖ ${item.date}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.statusKhmer,
                          style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Tab 3: ព័ត៌មានខ្ញុំ (Profile Tab)
  // ==========================================
  void _showChangeAvatarSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ប្តូររូបថត Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  ),
                  title: const Text('ថតរូបផ្ទាល់ (Camera)'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('មុខងារ Camera នឹងដំណើរការជាមួយកាមេរ៉ាពិត'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.photo_library_rounded, color: AppColors.primary),
                  ),
                  title: const Text('ជ្រើសរើសពីរូបភាព (Gallery)'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('មុខងារ Gallery នឹងដំណើរការជាមួយរូបថត'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('ប្តូរពាក្យសម្ងាត់', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'ពាក្យសម្ងាត់ចាស់',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (v) => v == null || v.isEmpty ? 'សូមបញ្ចូលពាក្យសម្ងាត់ចាស់' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'ពាក្យសម្ងាត់ថ្មី',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (v) => v == null || v.length < 6 ? 'ត្រូវមានយ៉ាងហោចណាស់ ៦ តួអក្សរ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'បញ្ជាក់ពាក្យសម្ងាត់ថ្មី',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (v) => v != newPasswordController.text ? 'ពាក្យសម្ងាត់មិនត្រូវគ្នាទេ' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('បានប្តូរពាក្យសម្ងាត់ដោយជោគជ័យ!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('រក្សាទុក', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ជ្រើសរើសភាសា (Language)', style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          SimpleDialogOption(
            onPressed: () {
              setState(() => _selectedLanguage = 'ខ្មែរ (Khmer)');
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                const Text('🇰🇭  ខ្មែរ (Khmer)', style: TextStyle(fontSize: 16)),
                const Spacer(),
                if (_selectedLanguage.contains('Khmer'))
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              setState(() => _selectedLanguage = 'English (US)');
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                const Text('🇺🇸  English (US)', style: TextStyle(fontSize: 16)),
                const Spacer(),
                if (_selectedLanguage.contains('English'))
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('អំពីកម្មវិធី ScanIn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ScanIn Attendance App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text('កំណែទម្រង់៖ v1.0.0 (Build 2026)', style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 12),
            Text(
              'កម្មវិធីស្កេនវត្តមានទំនើប និងឆាប់រហ័សសម្រាប់សាកលវិទ្យាល័យ និងស្ថាប័នអប់រំ។ គាំទ្រការស្កេន Dynamic QR Code ជាមួយប្រព័ន្ធសុវត្ថិភាពខ្ពស់។',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 12),
            Text('ជំនួយបច្ចេកទេស៖ support@scanin.app', style: TextStyle(fontSize: 12, color: AppColors.primary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('យល់ព្រម'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.border;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final dividerCol = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final avatarBg = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- ១. Header Card ព័ត៌មានសិស្ស ---
          Card(
            color: cardBg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: borderCol),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                  // Avatar with Camera Badge
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person, size: 52, color: AppColors.primary),
                      ),
                      InkWell(
                        onTap: _showChangeAvatarSheet,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    student.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'អត្តលេខ៖ ${student.studentCode ?? 'STU001'}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : AppColors.primaryLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          student.department ?? 'ព័ត៌មានវិទ្យា (IT)',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

          const SizedBox(height: 16),

          // --- ២. ស្ថិតិវត្តមានសង្ខេប (Attendance Quick Stats) ---
          Card(
            color: cardBg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderCol),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'ស្ថិតិវត្តមានសរុប (ឆមាសនេះ)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textCol),
                      ),
                      const Spacer(),
                      const Text(
                        'អត្រាវត្តមាន ៩០%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStatBox(
                          title: 'វត្តមាន',
                          count: '18',
                          color: AppColors.success,
                          icon: Icons.check_circle_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniStatBox(
                          title: 'យឺត',
                          count: '2',
                          color: AppColors.warning,
                          icon: Icons.access_time_filled_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniStatBox(
                          title: 'អវត្តមាន',
                          count: '1',
                          color: AppColors.error,
                          icon: Icons.cancel_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- ៣. ព័ត៌មានការសិក្សា & ទំនាក់ទំនង (Academic Details) ---
          Card(
            color: cardBg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderCol),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ព័ត៌មានសិក្សា និងទំនាក់ទំនង',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textCol),
                  ),
                  const SizedBox(height: 12),
                  _buildProfileDetailRow(
                    icon: Icons.email_outlined,
                    title: 'អ៊ីមែល',
                    value: student.email,
                    isDark: isDark,
                  ),
                  Divider(height: 18, color: dividerCol),
                  _buildProfileDetailRow(
                    icon: Icons.phone_outlined,
                    title: 'លេខទូរស័ព្ទ',
                    value: student.phone ?? '012 345 678',
                    isDark: isDark,
                  ),
                  Divider(height: 18, color: dividerCol),
                  _buildProfileDetailRow(
                    icon: Icons.domain_rounded,
                    title: 'មហាវិទ្យាល័យ / ដេប៉ាតឺម៉ង់',
                    value: student.department ?? 'វិទ្យាសាស្ត្រកុំព្យូទ័រ',
                    isDark: isDark,
                  ),
                  Divider(height: 18, color: dividerCol),
                  _buildProfileDetailRow(
                    icon: Icons.calendar_today_outlined,
                    title: 'ឆ្នាំសិក្សា',
                    value: '2026-2027 (ឆមាសទី ១)',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- ៤. ការកំណត់ និងសុវត្ថិភាព (Settings & Security) ---
          Card(
            color: cardBg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderCol),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ការកំណត់ និងសុវត្ថិភាព',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textCol),
                  ),
                  const SizedBox(height: 8),

                  // មុខងារ Dark Mode
                  Material(
                    color: Colors.transparent,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: avatarBg,
                          child: Icon(
                            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          'មុខងារងងឹត (Dark Mode)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textCol),
                        ),
                        subtitle: Text(
                          isDark ? 'កំពុងបើកប្រើពណ៌ងងឹត' : 'កំពុងប្រើពណ៌ធម្មតា (Light)',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: Switch(
                          value: isDark,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            AppTheme.toggleTheme(val);
                            setState(() {});
                          },
                        ),
                        onTap: () {
                          AppTheme.toggleTheme(!isDark);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Divider(height: 12, color: dividerCol),

                  // Notifications switch
                  Material(
                    color: Colors.transparent,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: avatarBg,
                          child: const Icon(Icons.notifications_active_outlined, size: 20, color: AppColors.primary),
                        ),
                        title: Text(
                          'ការជូនដំណឹងម៉ោងរៀន',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textCol),
                        ),
                        subtitle: const Text('រំលឹកមុនពេលចូលរៀន ១៥ នាទី', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        trailing: Switch(
                          value: _notificationsEnabled,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() => _notificationsEnabled = val);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(val ? 'បានបើកការជូនដំណឹង' : 'បានបិទការជូនដំណឹង'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          final newVal = !_notificationsEnabled;
                          setState(() => _notificationsEnabled = newVal);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(newVal ? 'បានបើកការជូនដំណឹង' : 'បានបិទការជូនដំណឹង'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Divider(height: 12, color: dividerCol),

                  // Change Password
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: avatarBg,
                        child: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.primary),
                      ),
                      title: Text(
                        'ប្តូរពាក្យសម្ងាត់',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textCol),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: _showChangePasswordDialog,
                    ),
                  ),
                  Divider(height: 12, color: dividerCol),

                  // Language
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: avatarBg,
                        child: const Icon(Icons.language_rounded, size: 20, color: AppColors.primary),
                      ),
                      title: Text(
                        'ភាសា (Language)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textCol),
                      ),
                      trailing: Text(
                        _selectedLanguage,
                        style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                      onTap: _showLanguageDialog,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- ៥. ជំនួយ និងព័ត៌មានកម្មវិធី (Support & About) ---
          Card(
            color: cardBg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderCol),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ជំនួយ និងព័ត៌មានកម្មវិធី',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textCol),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: avatarBg,
                        child: const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary),
                      ),
                      title: Text(
                        'អំពីកម្មវិធី ScanIn',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textCol),
                      ),
                      trailing: const Text(
                        'v1.0.0',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      onTap: _showAboutDialog,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- ៦. ប៊ូតុងចាកចេញ (Logout Button) ---
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('ចាកចេញពីគណនី'),
                    content: const Text('តើអ្នកពិតជាចង់ចាកចេញពីកម្មវិធីមែនទេ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('បោះបង់'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          Navigator.pop(dialogContext); // Close dialog
                          await AuthService.logout();
                          if (!mounted) return;
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
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
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMiniStatBox({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow({
    required IconData icon,
    required String title,
    required String value,
    bool isDark = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
