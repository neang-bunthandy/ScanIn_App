import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../../core/app_language.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';

/// អេក្រង់ព័ត៌មានផ្ទាល់ខ្លួនសិស្ស (Tab 3: ខ្ញុំ)
/// គាំទ្រទាំង Light Mode និង Dark Mode យ៉ាងពេញលេញ
class StudentProfileScreen extends StatefulWidget {
  final UserModel student;
  final bool notificationsEnabled;
  final String selectedLanguage;
  final ValueChanged<bool> onToggleNotifications;
  final ValueChanged<String> onLanguageChanged;

  const StudentProfileScreen({
    super.key,
    required this.student,
    required this.notificationsEnabled,
    required this.selectedLanguage,
    required this.onToggleNotifications,
    required this.onLanguageChanged,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
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
              Text(
                AppLanguage.tr('ប្តូររូបថត Profile', 'Change Profile Photo'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  ),
                  title: Text(AppLanguage.tr('ថតរូបផ្ទាល់ (Camera)', 'Take Photo (Camera)')),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr('មុខងារ Camera នឹងដំណើរការជាមួយកាមេរ៉ាពិត', 'Camera feature will work on a real device')),
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
                  title: Text(AppLanguage.tr('ជ្រើសរើសពីរូបភាព (Gallery)', 'Choose from Gallery')),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr('មុខងារ Gallery នឹងដំណើរការជាមួយរូបថត', 'Gallery feature will work with photo library')),
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
        title: Row(
          children: [
            const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              AppLanguage.tr('ប្តូរពាក្យសម្ងាត់', 'Change Password'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
                  labelText: AppLanguage.tr('ពាក្យសម្ងាត់ចាស់', 'Current Password'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (v) => v == null || v.isEmpty ? AppLanguage.tr('សូមបញ្ចូលពាក្យសម្ងាត់ចាស់', 'Please enter current password') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLanguage.tr('ពាក្យសម្ងាត់ថ្មី', 'New Password'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (v) => v == null || v.length < 6 ? AppLanguage.tr('ត្រូវមានយ៉ាងហោចណាស់ ៦ តួអក្សរ', 'Must be at least 6 characters') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLanguage.tr('បញ្ជាក់ពាក្យសម្ងាត់ថ្មី', 'Confirm New Password'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (v) => v != newPasswordController.text ? AppLanguage.tr('ពាក្យសម្ងាត់មិនត្រូវគ្នាទេ', 'Passwords do not match') : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLanguage.tr('បោះបង់', 'Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLanguage.tr('បានប្តូរពាក្យសម្ងាត់ដោយជោគជ័យ!', 'Password changed successfully!')),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(AppLanguage.tr('រក្សាទុក', 'Save'), style: const TextStyle(color: Colors.white)),
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
        title: Text(
          AppLanguage.tr('ជ្រើសរើសភាសា (Language)', 'Select Language'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              await AppLanguage.changeLanguage('km');
              widget.onLanguageChanged('ខ្មែរ (Khmer)');
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Row(
              children: [
                const Text('🇰🇭  ខ្មែរ (Khmer)', style: TextStyle(fontSize: 16)),
                const Spacer(),
                if (AppLanguage.isKhmer)
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () async {
              await AppLanguage.changeLanguage('en');
              widget.onLanguageChanged('English (US)');
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Row(
              children: [
                const Text('🇺🇸  English (US)', style: TextStyle(fontSize: 16)),
                const Spacer(),
                if (AppLanguage.isEnglish)
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.border;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              AppLanguage.tr('អំពីកម្មវិធី ScanIn', 'About ScanIn App'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ScanIn Attendance App',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLanguage.tr('កំណែទម្រង់៖ v1.0.0 (Build 2026)', 'Version: v1.0.0 (Build 2026)'),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              AppLanguage.tr(
                'កម្មវិធីស្កេនវត្តមានទំនើប និងឆាប់រហ័សសម្រាប់សាកលវិទ្យាល័យ និងស្ថាប័នអប់រំ។ គាំទ្រការស្កេន Dynamic QR Code ជាមួយប្រព័ន្ធសុវត្ថិភាពខ្ពស់។',
                'Modern and fast attendance scanning application for universities and educational institutions. Supports dynamic QR code scanning with high security.',
              ),
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.code_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        AppLanguage.tr('អ្នកអភិវឌ្ឍន៍៖', 'Developer:'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Jitsu Dev',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        AppLanguage.tr('ទំនាក់ទំនង៖', 'Contact:'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'jitsudev.support@gmail.com',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLanguage.tr('យល់ព្រម', 'OK')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
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
                      '${AppLanguage.tr('អត្តលេខ៖ ', 'ID: ')}${student.studentCode ?? 'STU001'}',
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
                            student.department ?? AppLanguage.tr('ព័ត៌មានវិទ្យា (IT)', 'Information Technology (IT)'),
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
                        AppLanguage.tr('ស្ថិតិវត្តមានសរុប (ឆមាសនេះ)', 'Attendance Statistics (This Semester)'),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textCol),
                      ),
                      const Spacer(),
                      Text(
                        AppLanguage.tr('អត្រាវត្តមាន ៩០%', 'Attendance Rate 90%'),
                        style: const TextStyle(
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
                          title: AppLanguage.tr('វត្តមាន', 'Present'),
                          count: '18',
                          color: AppColors.success,
                          icon: Icons.check_circle_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniStatBox(
                          title: AppLanguage.tr('យឺត', 'Late'),
                          count: '2',
                          color: AppColors.warning,
                          icon: Icons.access_time_filled_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniStatBox(
                          title: AppLanguage.tr('អវត្តមាន', 'Absent'),
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

          // --- ៣. ព័ត៌មានលម្អិតពីការសិក្សា (Academic Details) ---
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
                    AppLanguage.tr('ព័ត៌មានលម្អិតនៃការសិក្សា', 'Academic Details'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textCol),
                  ),
                  const SizedBox(height: 14),
                  _buildProfileDetailRow(
                    icon: Icons.email_outlined,
                    title: AppLanguage.tr('អ៊ីមែល', 'Email'),
                    value: student.email,
                    isDark: isDark,
                  ),
                  Divider(height: 18, color: dividerCol),
                  _buildProfileDetailRow(
                    icon: Icons.phone_outlined,
                    title: AppLanguage.tr('លេខទូរស័ព្ទ', 'Phone Number'),
                    value: student.phone ?? '012 345 678',
                    isDark: isDark,
                  ),
                  Divider(height: 18, color: dividerCol),
                  _buildProfileDetailRow(
                    icon: Icons.domain_rounded,
                    title: AppLanguage.tr('មហាវិទ្យាល័យ / ដេប៉ាតឺម៉ង់', 'Faculty / Department'),
                    value: student.department ?? AppLanguage.tr('វិទ្យាសាស្ត្រកុំព្យូទ័រ', 'Computer Science'),
                    isDark: isDark,
                  ),
                  Divider(height: 18, color: dividerCol),
                  _buildProfileDetailRow(
                    icon: Icons.calendar_today_outlined,
                    title: AppLanguage.tr('ឆ្នាំសិក្សា', 'Academic Year'),
                    value: AppLanguage.tr('2026-2027 (ឆមាសទី ១)', '2026-2027 (Semester 1)'),
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
                    AppLanguage.tr('ការកំណត់ និងសុវត្ថិភាព', 'Settings & Security'),
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
                          AppLanguage.tr('មុខងារងងឹត (Dark Mode)', 'Dark Mode'),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textCol),
                        ),
                        subtitle: Text(
                          isDark
                              ? AppLanguage.tr('កំពុងបើកប្រើពណ៌ងងឹត', 'Dark theme enabled')
                              : AppLanguage.tr('កំពុងប្រើពណ៌ធម្មតា (Light)', 'Light theme enabled'),
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
                          AppLanguage.tr('ការជូនដំណឹងម៉ោងរៀន', 'Class Reminders'),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textCol),
                        ),
                        subtitle: Text(
                          AppLanguage.tr('រំលឹកមុនពេលចូលរៀន ១៥ នាទី', '15 minutes before class starts'),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: Switch(
                          value: widget.notificationsEnabled,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            widget.onToggleNotifications(val);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(val
                                    ? AppLanguage.tr('បានបើកការជូនដំណឹង', 'Notifications enabled')
                                    : AppLanguage.tr('បានបិទការជូនដំណឹង', 'Notifications disabled')),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          final newVal = !widget.notificationsEnabled;
                          widget.onToggleNotifications(newVal);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(newVal
                                  ? AppLanguage.tr('បានបើកការជូនដំណឹង', 'Notifications enabled')
                                  : AppLanguage.tr('បានបិទការជូនដំណឹង', 'Notifications disabled')),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: avatarBg,
                        child: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.primary),
                      ),
                      title: Text(
                        AppLanguage.tr('ប្តូរពាក្យសម្ងាត់', 'Change Password'),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: avatarBg,
                        child: const Icon(Icons.language_rounded, size: 20, color: AppColors.primary),
                      ),
                      title: Text(
                        AppLanguage.tr('ភាសា (Language)', 'Language'),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textCol),
                      ),
                      trailing: Text(
                        AppLanguage.displayName,
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
                    AppLanguage.tr('ជំនួយ និងព័ត៌មានកម្មវិធី', 'Support & About'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textCol),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: avatarBg,
                        child: const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary),
                      ),
                      title: Text(
                        AppLanguage.tr('អំពីកម្មវិធី ScanIn', 'About ScanIn App'),
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
                    title: Text(AppLanguage.tr('ចាកចេញពីគណនី', 'Log Out')),
                    content: Text(AppLanguage.tr('តើអ្នកពិតជាចង់ចាកចេញពីកម្មវិធីមែនទេ?', 'Are you sure you want to log out of the application?')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(AppLanguage.tr('បោះបង់', 'Cancel')),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          Navigator.pop(dialogContext);
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
                        child: Text(AppLanguage.tr('ចាកចេញ', 'Log Out')),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text(
                AppLanguage.tr('ចាកចេញពីគណនី', 'Log Out'),
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 15),
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
