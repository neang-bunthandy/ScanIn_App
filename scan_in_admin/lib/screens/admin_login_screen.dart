import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_routes.dart';
import '../services/auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  String _selectedRole = 'admin'; // 'admin' or 'lecturer'
  final _emailController = TextEditingController(text: 'admin@scanin.app');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;
  String? _errorMessage;

  void _onRoleChanged(String role) {
    setState(() {
      _selectedRole = role;
      _errorMessage = null;
      if (role == 'admin') {
        _emailController.text = 'admin@scanin.app';
      } else {
        _emailController.text = 'lecturer@scanin.app';
      }
      _passwordController.text = 'password123';
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await AuthService.login(
      email: email,
      password: password,
      role: _selectedRole, // ផ្ទៀងផ្ទាត់ Role ផ្ទាល់ពី Backend
    );

    if (!mounted) return;

    if (result.success) {
      final userRole = result.user?.role;

      // ញែកសិទ្ធិដាច់ដោយឡែក៖ គ្រូមិនអាចចូលជា Admin បានដាច់ខាត!
      if (_selectedRole == 'admin' && userRole != 'admin') {
        await AuthService.logout();
        setState(() {
          _isLoading = false;
          _errorMessage = AppLanguage.tr(
            'គណនីនេះជាគណនីគ្រូបង្រៀន! គ្រូមិនអាចចូលជាអ្នកគ្រប់គ្រង (Admin) បានឡើយ។ សូមជ្រើសរើសផ្ទាំង "គ្រូបង្រៀន"។',
            'This is a Lecturer account! Lecturers cannot access the Admin Panel. Please select the "Lecturer" tab.',
          );
        });
        return;
      }

      // សិស្សមិនអាចចូលប្រើប្រាស់ Web បានឡើយ
      if (userRole == 'student') {
        await AuthService.logout();
        setState(() {
          _isLoading = false;
          _errorMessage = AppLanguage.tr(
            'គណនីសិស្សមិនអាចចូលប្រើលើ Web បានឡើយ។ សូមប្រើប្រាស់ Mobile App ដើម្បីស្កេនវត្តមាន។',
            'Student accounts cannot access the Web Portal. Please use the Mobile App to scan attendance.',
          );
        });
        return;
      }

      // ប្រសិនបើជាគ្រូ បញ្ជូនត្រង់ទៅកាន់ផ្ទាំងថ្នាក់បង្រៀន (Classes & Projector)
      if (userRole == 'lecturer') {
        Navigator.pushReplacementNamed(context, AppRoutes.classes);
      } else {
        // ប្រសិនបើជា Admin បញ្ជូនទៅកាន់ Admin Dashboard
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final isAdminMode = _selectedRole == 'admin';

    return Scaffold(
      backgroundColor: bgCol,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Tab Selector: ញែកឱ្យដាច់រវាង Admin និង គ្រូបង្រៀន
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _onRoleChanged('admin'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isAdminMode ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.admin_panel_settings_rounded,
                                  size: 16,
                                  color: isAdminMode ? Colors.white : subTextCol,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppLanguage.tr('Admin (រដ្ឋបាល)', 'Admin'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isAdminMode ? Colors.white : subTextCol,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => _onRoleChanged('lecturer'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !isAdminMode ? const Color(0xFF0284C7) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  size: 16,
                                  color: !isAdminMode ? Colors.white : subTextCol,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppLanguage.tr('គ្រូបង្រៀន (Lecturer)', 'Lecturer'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: !isAdminMode ? Colors.white : subTextCol,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logo Icon
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isAdminMode
                            ? [AppColors.primary, const Color(0xFF6366F1)]
                            : [const Color(0xFF0284C7), const Color(0xFF06B6D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        isAdminMode ? Icons.shield_rounded : Icons.laptop_chromebook_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isAdminMode ? 'ScanIn Admin Panel' : 'ScanIn Lecturer Web',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: textCol,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isAdminMode
                      ? AppLanguage.tr(
                          'ផ្ទាំងគ្រប់គ្រងសម្រាប់អ្នកគ្រប់គ្រងសាលា (Admin Only)',
                          'Administrative Management Panel for School Admins',
                        )
                      : AppLanguage.tr(
                          'ផ្ទាំងបញ្ចាំង Projector និងស្រង់វត្តមានសម្រាប់គ្រូ (Laptop Web)',
                          'Classroom Projector & Attendance Workspace for Lecturers',
                        ),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: subTextCol),
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textCol, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: isAdminMode
                        ? AppLanguage.tr('អ៊ីមែលអ្នកគ្រប់គ្រង (Admin Email)', 'Admin Email')
                        : AppLanguage.tr('អ៊ីមែលគ្រូបង្រៀន (Lecturer Email)', 'Lecturer Email'),
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: textCol, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: AppLanguage.tr('ពាក្យសម្ងាត់ (Password)', 'Password'),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdminMode ? AppColors.primary : const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isAdminMode
                              ? AppLanguage.tr('ចូលគ្រប់គ្រង Admin (Sign In)', 'Sign In as Admin')
                              : AppLanguage.tr('ចូលផ្ទាំងគ្រូបង្រៀន (Sign In)', 'Sign In as Lecturer'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 18),

                // Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    isAdminMode
                        ? AppLanguage.tr(
                            '⚠️ គ្រូមិនអាចចូលជា Admin បានឡើយ។ Admin ជាអ្នកបង្កើតថ្នាក់ និងចាត់តាំងគ្រូ។',
                            '⚠️ Lecturers cannot access Admin. Admins create classes and assign staff.',
                          )
                        : AppLanguage.tr(
                            '💡 គ្រូអាចបញ្ចាំង QR លើ Projector និងកែប្រែវត្តមានជាក់ស្តែងរបស់សិស្សក្នុងថ្នាក់។',
                            '💡 Lecturers can project QR codes and edit classroom attendances.',
                          ),
                    style: TextStyle(fontSize: 11, color: subTextCol),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
