import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_routes.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/class_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarBg = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B);
    final contentBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final topBarBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final isLecturer = _currentUser?.role == 'lecturer';

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 900;
    final sidebarWidth = isCompact ? 72.0 : 260.0;
    const double headerHeight = 70.0; // Fixed identical height for both sidebar header and top bar

    return Scaffold(
      backgroundColor: contentBg,
      body: Row(
        children: [
          // Left Sidebar (Responsive: 72px on tablets/narrow, 260px on wide desktops)
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
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
                      : Row(
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
                                    isLecturer ? 'ScanIn Lecturer' : 'ScanIn Admin',
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
                                    isLecturer ? 'Laptop Workspace' : 'System Administration',
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

                // Footer Profile & Logout
                Container(
                  padding: EdgeInsets.all(isCompact ? 10 : 16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                  ),
                  child: isCompact
                      ? Column(
                          children: [
                            Tooltip(
                              message: '${_currentUser?.name ?? "User"}\n(${isLecturer ? "Lecturer" : "Admin"})',
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: isLecturer ? const Color(0xFF0284C7) : AppColors.primary,
                                child: Text(
                                  _currentUser?.name.isNotEmpty == true ? _currentUser!.name[0].toUpperCase() : 'A',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              tooltip: AppLanguage.tr('ចាកចេញ (Sign Out)', 'Sign Out'),
                              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
                              onPressed: _handleLogout,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isLecturer ? const Color(0xFF0284C7) : AppColors.primary,
                              child: Text(
                                _currentUser?.name.isNotEmpty == true ? _currentUser!.name[0].toUpperCase() : 'A',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentUser?.name ?? (isLecturer ? 'សាស្រ្តាចារ្យ' : 'អ្នកគ្រប់គ្រង'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isLecturer
                                          ? const Color(0xFF0284C7).withValues(alpha: 0.25)
                                          : AppColors.primary.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isLecturer ? 'គ្រូបង្រៀន (Lecturer)' : 'អ្នកគ្រប់គ្រង (Admin)',
                                      style: TextStyle(
                                        color: isLecturer ? const Color(0xFF38BDF8) : const Color(0xFF93C5FD),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: AppLanguage.tr('ចាកចេញ (Sign Out)', 'Sign Out'),
                              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                              onPressed: _handleLogout,
                            ),
                          ],
                        ),
                ),
              ],
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
                              margin: const EdgeInsets.only(right: 8),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cloud_done_rounded, color: Color(0xFF16A34A), size: 16),
                                if (!isCompact) ...[
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Laravel API Connected',
                                    style: TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ],
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


