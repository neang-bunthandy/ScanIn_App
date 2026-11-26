import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../core/api_config.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_routes.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/class_service.dart';
import '../utils/web_export_helper.dart';

class AdminScaffold extends StatefulWidget {
  final String title;
  final String currentRoute;
  final Widget body;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.body,
  });

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  UserModel? _currentUser;
  bool _reportsExpanded = false;

  @override
  void initState() {
    super.initState();
    _reportsExpanded = widget.currentRoute == AppRoutes.attendances ||
        widget.currentRoute == AppRoutes.studentStats;
    _currentUser = AuthService.cachedUser;
    if (_currentUser == null) {
      _loadUser();
    }
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) setState(() => _currentUser = user);
  }

  void _navigateTo(String route) {
    if (widget.currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  Future<Uint8List?> _showAvatarCropDialog(Uint8List rawBytes) async {
    final boundaryKey = GlobalKey();
    final transformCtrl = TransformationController();
    double zoom = 1.0;

    return showDialog<Uint8List?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: [
                const Icon(Icons.crop_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  AppLanguage.tr('កាត់តម្រឹមរូបថត Profile', 'Crop Profile Photo'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLanguage.tr(
                      'អូសរូបភាព ឬប្រើរបារខាងក្រោមដើម្បីពង្រីក/បង្រួម',
                      'Drag to reposition or use the slider to zoom',
                    ),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      color: const Color(0xFF0F172A),
                    ),
                    child: ClipOval(
                      child: RepaintBoundary(
                        key: boundaryKey,
                        child: InteractiveViewer(
                          transformationController: transformCtrl,
                          minScale: 1.0,
                          maxScale: 3.5,
                          boundaryMargin: const EdgeInsets.all(80),
                          child: Image.memory(
                            rawBytes,
                            width: 260,
                            height: 260,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.zoom_out_rounded, size: 18),
                      Expanded(
                        child: Slider(
                          value: zoom,
                          min: 1.0,
                          max: 3.5,
                          activeColor: AppColors.primary,
                          onChanged: (v) {
                            setDlgState(() {
                              zoom = v;
                              final offset = (1.0 - zoom) * 130.0;
                              transformCtrl.value = Matrix4.identity()
                                ..translateByDouble(offset, offset, 0.0, 1.0)
                                ..scaleByDouble(zoom, zoom, 1.0, 1.0);
                            });
                          },
                        ),
                      ),
                      const Icon(Icons.zoom_in_rounded, size: 18),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  transformCtrl.dispose();
                  Navigator.pop(ctx, null);
                },
                child: Text(AppLanguage.tr('បោះបង់', 'Cancel')),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded, size: 17),
                label: Text(AppLanguage.tr('រក្សាទុក', 'Save Photo')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
                    if (boundary != null) {
                      final image = await boundary.toImage(pixelRatio: 2.0);
                      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                      if (byteData != null) {
                        final cropped = byteData.buffer.asUint8List();
                        transformCtrl.dispose();
                        if (ctx.mounted) Navigator.pop(ctx, cropped);
                        return;
                      }
                    }
                  } catch (_) {}
                  transformCtrl.dispose();
                  if (ctx.mounted) Navigator.pop(ctx, rawBytes);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleUploadAvatar() async {
    final picked = await pickFileBytes(accept: 'image/*');
    if (picked == null || !mounted) return;

    final croppedBytes = await _showAvatarCropDialog(picked.bytes);
    if (croppedBytes == null || !mounted) return;

    final result = await AuthService.uploadAvatar(
      bytes: croppedBytes,
      filename: 'avatar_cropped.png',
    );
    if (!mounted) return;

    if (result.success && result.user != null) {
      setState(() => _currentUser = result.user);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLanguage.tr('ចាកចេញពីគណនី?', 'Sign Out?')),
        content: Text(
          AppLanguage.tr(
            'តើអ្នកពិតជាចង់ចាកចេញពីប្រព័ន្ធនេះឬទេ?',
            'Are you sure you want to sign out?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLanguage.tr('បោះបង់', 'Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLanguage.tr('ចាកចេញ', 'Sign Out'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ClassService.clearCache();
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;
    String? errorMessage;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
            final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
            final textCol = isDark ? Colors.white : const Color(0xFF0F172A);
            final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
            final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

            Future<void> handleSubmit() async {
              errorMessage = null;
              if (!formKey.currentState!.validate()) return;

              setDialogState(() => isLoading = true);

              final result = await AuthService.changePassword(
                currentPassword: currentPasswordCtrl.text,
                newPassword: newPasswordCtrl.text,
              );

              if (!mounted) return;

              if (result['success'] == true) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppLanguage.tr(
                              'បានប្តូរពាក្យសម្ងាត់ដោយជោគជ័យ!',
                              'Password changed successfully!',
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                setDialogState(() {
                  isLoading = false;
                  errorMessage = result['message']?.toString() ??
                      AppLanguage.tr('ការប្តូរពាក្យសម្ងាត់មិនជោគជ័យ', 'Failed to change password');
                });
              }
            }

            return AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.key_rounded, color: Color(0xFFF59E0B), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLanguage.tr('ប្តូរពាក្យសម្ងាត់', 'Change Password'),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textCol),
                        ),
                        if (_currentUser?.email != null)
                          Text(
                            _currentUser!.email,
                            style: TextStyle(fontSize: 12, color: subTextCol, fontWeight: FontWeight.normal),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Current Password
                        Text(
                          AppLanguage.tr('ពាក្យសម្ងាត់បច្ចុប្បន្ន', 'Current Password'),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textCol),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: currentPasswordCtrl,
                          obscureText: obscureCurrent,
                          style: TextStyle(color: textCol, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: AppLanguage.tr('បញ្ចូលពាក្យសម្ងាត់ចាស់', 'Enter current password'),
                            hintStyle: TextStyle(color: subTextCol, fontSize: 13),
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: subTextCol, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: subTextCol,
                                size: 20,
                              ),
                              onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderCol)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderCol)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppLanguage.tr('សូមបញ្ចូលពាក្យសម្ងាត់បច្ចុប្បន្ន', 'Current password is required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // New Password
                        Text(
                          AppLanguage.tr('ពាក្យសម្ងាត់ថ្មី (យ៉ាងតិច ៦ ខ្ទង់)', 'New Password (min 6 chars)'),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textCol),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: newPasswordCtrl,
                          obscureText: obscureNew,
                          style: TextStyle(color: textCol, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: AppLanguage.tr('បញ្ចូលពាក្យសម្ងាត់ថ្មី', 'Enter new password'),
                            hintStyle: TextStyle(color: subTextCol, fontSize: 13),
                            prefixIcon: Icon(Icons.lock_rounded, color: subTextCol, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: subTextCol,
                                size: 20,
                              ),
                              onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderCol)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderCol)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppLanguage.tr('សូមបញ្ចូលពាក្យសម្ងាត់ថ្មី', 'New password is required');
                            }
                            if (val.trim().length < 6) {
                              return AppLanguage.tr('ពាក្យសម្ងាត់ត្រូវមានយ៉ាងតិច ៦ ខ្ទង់', 'Password must be at least 6 characters');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Confirm New Password
                        Text(
                          AppLanguage.tr('ផ្ទៀងផ្ទាត់ពាក្យសម្ងាត់ថ្មី', 'Confirm New Password'),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textCol),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: confirmPasswordCtrl,
                          obscureText: obscureConfirm,
                          style: TextStyle(color: textCol, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: AppLanguage.tr('វាយពាក្យសម្ងាត់ថ្មីម្តងទៀត', 'Re-enter new password'),
                            hintStyle: TextStyle(color: subTextCol, fontSize: 13),
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: subTextCol, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: subTextCol,
                                size: 20,
                              ),
                              onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderCol)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderCol)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppLanguage.tr('សូមផ្ទៀងផ្ទាត់ពាក្យសម្ងាត់ថ្មី', 'Please confirm new password');
                            }
                            if (val.trim() != newPasswordCtrl.text.trim()) {
                              return AppLanguage.tr('ពាក្យសម្ងាត់ទាំងពីរមិនដូចគ្នាទេ!', 'Passwords do not match');
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogCtx),
                  child: Text(AppLanguage.tr('បោះបង់', 'Cancel')),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onPressed: isLoading ? null : handleSubmit,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(
                    isLoading
                        ? AppLanguage.tr('កំពុងរក្សាទុក...', 'Saving...')
                        : AppLanguage.tr('ប្តូរពាក្យសម្ងាត់', 'Change Password'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarBg = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B);
    final contentBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final topBarBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final isLecturer = _currentUser?.role == 'lecturer';
    final isMasterAdmin = _currentUser?.isMasterAdmin == true;

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 900;
    final sidebarWidth = isCompact ? 72.0 : 260.0;
    const double headerHeight = 70.0; // Fixed identical height for both sidebar header and top bar

    return Scaffold(
      backgroundColor: contentBg,
      body: Row(
        children: [
          // Left Sidebar (Responsive: 72px on tablets/narrow, 260px on wide desktops)
          ClipRect(
            child: Container(
              width: sidebarWidth,
              color: sidebarBg,
              child: Column(
              children: [
                // Header Logo
                Container(
                  height: headerHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 16 : 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? const Color(0xFF334155) : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isCompact
                      ? Center(
                          child: Tooltip(
                            message: isLecturer ? 'ScanIn Lecturer' : 'ScanIn Admin',
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isLecturer
                                      ? [const Color(0xFF0284C7), const Color(0xFF06B6D4)]
                                      : [AppColors.primary, const Color(0xFF6366F1)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  isLecturer ? Icons.laptop_chromebook_rounded : Icons.admin_panel_settings_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 220,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isLecturer
                                          ? [const Color(0xFF0284C7), const Color(0xFF06B6D4)]
                                          : [AppColors.primary, const Color(0xFF6366F1)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isLecturer ? Icons.laptop_chromebook_rounded : Icons.admin_panel_settings_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isLecturer
                                            ? 'ScanIn Lecturer'
                                            : (_currentUser?.isSubAdmin == true
                                                ? 'ScanIn Academic'
                                                : 'ScanIn Admin'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        isLecturer
                                            ? 'Laptop Workspace'
                                            : (_currentUser?.isSubAdmin == true
                                                ? 'Academic Affairs'
                                                : 'System Administration'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 11,
                                          height: 1.2,
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

                // Navigation Items: ញែកឱ្យដាច់រវាង Admin និង គ្រូ
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 8 : 12,
                      vertical: 20,
                    ),
                    children: [
                      // Admin មានសិទ្ធិមើល Dashboard និងគ្រប់គ្រងគណនី (គ្រូមិនអាចមើលបានទេ)
                      if (!isLecturer) ...[
                        _buildNavItem(
                          icon: Icons.dashboard_rounded,
                          title: AppLanguage.tr('ទំព័រដើម (Dashboard)', 'Dashboard'),
                          route: AppRoutes.dashboard,
                          isCompact: isCompact,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem(
                          icon: Icons.badge_outlined,
                          title: AppLanguage.tr('គ្រប់គ្រងគណនីគ្រូ', 'Lecturers Management'),
                          route: AppRoutes.lecturers,
                          isCompact: isCompact,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem(
                          icon: Icons.school_outlined,
                          title: AppLanguage.tr('គ្រប់គ្រងគណនីសិស្ស', 'Students Management'),
                          route: AppRoutes.students,
                          isCompact: isCompact,
                        ),
                        const SizedBox(height: 6),
                        if (isMasterAdmin) ...[
                          _buildNavItem(
                            icon: Icons.admin_panel_settings_outlined,
                            title: AppLanguage.tr('គ្រប់គ្រង Sub-Admin', 'Sub-Admins'),
                            route: AppRoutes.subAdmins,
                            isCompact: isCompact,
                          ),
                          const SizedBox(height: 6),
                        ],
                      ],

                      _buildNavItem(
                        icon: Icons.class_outlined,
                        title: isLecturer
                            ? AppLanguage.tr('ថ្នាក់បង្រៀនរបស់ខ្ញុំ', 'My Teaching Classes')
                            : AppLanguage.tr('គ្រប់គ្រងថ្នាក់រៀន', 'Classes Management'),
                        route: AppRoutes.classes,
                        isCompact: isCompact,
                      ),
                      const SizedBox(height: 6),

                      if (isLecturer)
                        _buildNavItem(
                          icon: Icons.fact_check_outlined,
                          title: AppLanguage.tr('វត្តមានសិស្សក្នុងថ្នាក់', 'Class Attendance'),
                          route: AppRoutes.attendances,
                          isCompact: isCompact,
                        )
                      else
                        _buildReportsMenuGroup(isCompact: isCompact),
                    ],
                  ),
                ),

                // Footer: Change Password & Logout
                Container(
                  padding: EdgeInsets.all(isCompact ? 10 : 14),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                  ),
                  child: isCompact
                      ? Column(
                          children: [
                            IconButton(
                              tooltip: AppLanguage.tr('ប្តូរពាក្យសម្ងាត់', 'Change Password'),
                              icon: const Icon(Icons.key_rounded, color: Color(0xFFF59E0B), size: 19),
                              onPressed: _showChangePasswordDialog,
                            ),
                            const SizedBox(height: 4),
                            IconButton(
                              tooltip: AppLanguage.tr('ចាកចេញ (Sign Out)', 'Sign Out'),
                              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                              onPressed: _handleLogout,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _showChangePasswordDialog,
                                icon: const Icon(Icons.key_rounded, color: Color(0xFFF59E0B), size: 17),
                                label: Text(
                                  AppLanguage.tr('ប្តូរពាក្យសម្ងាត់', 'Change Password'),
                                  style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _handleLogout,
                                icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
                                label: Text(
                                  AppLanguage.tr('ចាកចេញ (Logout)', 'Logout'),
                                  style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.35)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),

          // Right Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                Container(
                  height: headerHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 16 : 32,
                  ),
                  decoration: BoxDecoration(
                    color: topBarBg,
                    border: Border(bottom: BorderSide(color: borderCol)),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isCompact ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: textCol,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLecturer)
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.tv_rounded, color: Color(0xFF0284C7), size: 16),
                                      if (!isCompact) ...[
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Projector Mode Ready',
                                          style: TextStyle(color: Color(0xFF0284C7), fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              // Top-Right User Profile (Avatar Upload + Name + Role + Change Password)
                              InkWell(
                                onTap: _handleUploadAvatar,
                                borderRadius: BorderRadius.circular(24),
                                child: Tooltip(
                                  message: AppLanguage.tr('ចុចដើម្បីប្តូររូបថត Profile', 'Click to change profile photo'),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            CircleAvatar(
                                              radius: 17,
                                              backgroundColor: isLecturer ? const Color(0xFF0284C7) : AppColors.primary,
                                              backgroundImage: _currentUser?.avatarUrl != null && _currentUser!.avatarUrl!.isNotEmpty
                                                  ? NetworkImage(ApiConfig.resolveImageUrl(_currentUser!.avatarUrl) ?? _currentUser!.avatarUrl!)
                                                  : null,
                                              child: _currentUser?.avatarUrl == null || _currentUser!.avatarUrl!.isEmpty
                                                  ? Text(
                                                      _currentUser?.name.isNotEmpty == true ? _currentUser!.name[0].toUpperCase() : 'A',
                                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                                    )
                                                  : null,
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: topBarBg,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.camera_alt_rounded, size: 10, color: AppColors.primary),
                                            ),
                                          ],
                                        ),
                                        if (!isCompact) ...[
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _currentUser?.name ?? (isLecturer ? 'សាស្រ្តាចារ្យ' : 'អ្នកគ្រប់គ្រង'),
                                                style: TextStyle(color: textCol, fontSize: 13, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                isLecturer
                                                    ? 'គ្រូបង្រៀន (Lecturer)'
                                                    : (_currentUser?.isSubAdmin == true
                                                        ? 'ការិយាល័យសិក្សា (Sub-Admin)'
                                                        : 'Master Admin'),
                                                style: TextStyle(
                                                  color: isLecturer
                                                      ? const Color(0xFF0284C7)
                                                      : (_currentUser?.isSubAdmin == true
                                                          ? const Color(0xFF10B981)
                                                          : AppColors.primary),
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
                ),

                // Main Page Body
                Expanded(
                  child: widget.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required String route,
    bool isCompact = false,
  }) {
    final isActive = widget.currentRoute == route;
    final navContent = InkWell(
      onTap: () => _navigateTo(route),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 0 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isCompact
            ? Center(
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : const Color(0xFFCBD5E1),
                  size: 20,
                ),
              )
            : Row(
                children: [
                  Icon(icon, color: isActive ? Colors.white : const Color(0xFFCBD5E1), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? Colors.white : const Color(0xFFCBD5E1),
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );

    if (isCompact) {
      return Tooltip(
        message: title,
        waitDuration: const Duration(milliseconds: 100),
        child: navContent,
      );
    }
    return navContent;
  }

  Widget _buildReportsMenuGroup({required bool isCompact}) {
    final isReportRoute = widget.currentRoute == AppRoutes.attendances ||
        widget.currentRoute == AppRoutes.studentStats;

    if (isCompact) {
      return Column(
        children: [
          _buildNavItem(
            icon: Icons.analytics_outlined,
            title: AppLanguage.tr('ស្ថិតិនិស្សិត & ប្រវត្តិតាមឆ្នាំ', 'Student Yearly Stats'),
            route: AppRoutes.studentStats,
            isCompact: true,
          ),
          const SizedBox(height: 6),
          _buildNavItem(
            icon: Icons.fact_check_outlined,
            title: AppLanguage.tr('របាយការណ៍វត្តមាន', 'Attendance Reports'),
            route: AppRoutes.attendances,
            isCompact: true,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _reportsExpanded = !_reportsExpanded),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isReportRoute ? AppColors.primary.withValues(alpha: 0.18) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  color: isReportRoute ? Colors.white : const Color(0xFFCBD5E1),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLanguage.tr('របាយការណ៍', 'Reports'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isReportRoute ? Colors.white : const Color(0xFFCBD5E1),
                      fontSize: 14,
                      fontWeight: isReportRoute ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  _reportsExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_reportsExpanded) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: [
                _buildNavItem(
                  icon: Icons.analytics_outlined,
                  title: AppLanguage.tr('ស្ថិតិតាមឆ្នាំ & ជំនាញ', 'Yearly & Dept Stats'),
                  route: AppRoutes.studentStats,
                  isCompact: false,
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  icon: Icons.fact_check_outlined,
                  title: AppLanguage.tr('របាយការណ៍វត្តមាន', 'Attendance Reports'),
                  route: AppRoutes.attendances,
                  isCompact: false,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}


