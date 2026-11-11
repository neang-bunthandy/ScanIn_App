import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/api_config.dart';
import '../services/auth_service.dart';
import 'student/student_home_screen.dart';
import 'lecturer/lecturer_home_screen.dart';

enum UserRole { student, teacher }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  UserRole _selectedRole = UserRole.student;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRoleChanged(UserRole role) {
    if (_selectedRole == role) return;
    setState(() {
      _selectedRole = role;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final roleString = _selectedRole == UserRole.student ? 'student' : 'lecturer';

    final result = await AuthService.login(
      email: email,
      password: password,
      role: roleString,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success && result.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${AppLanguage.tr('សូមស្វាគមន៍ ', 'Welcome ')}${result.user!.name}!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );

      if (result.user!.isStudent) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentHomeScreen(
              studentEmail: result.user!.email,
              user: result.user,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LecturerHomeScreen(
              lecturerEmail: result.user!.email,
              user: result.user,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.message,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showServerConfigDialog() {
    final hostController = TextEditingController(text: ApiConfig.host);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.dns_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                AppLanguage.tr('កំណត់ Server IP', 'Set Server IP'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.tr('សូមជ្រើសរើស ឬបញ្ចូល IP ម៉ាស៊ីន Server (Laravel)៖', 'Select or enter Laravel Server IP:'),
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hostController,
                  decoration: InputDecoration(
                    labelText: 'Host IP',
                    hintText: 'ឧ. 10.0.2.2 ឬ 192.168.42.165',
                    prefixIcon: const Icon(Icons.router_rounded),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: 12)),
                      onPressed: () => hostController.text = '10.0.2.2',
                    ),
                    ActionChip(
                      label: const Text('Wi-Fi PC (192.168.42.165)', style: TextStyle(fontSize: 12)),
                      onPressed: () => hostController.text = '192.168.42.165',
                    ),
                    ActionChip(
                      label: const Text('Localhost (127.0.0.1)', style: TextStyle(fontSize: 12)),
                      onPressed: () => hostController.text = '127.0.0.1',
                    ),
                  ],
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
                setState(() {
                  ApiConfig.customHost = hostController.text.trim();
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLanguage.tr('បានប្តូរ Server ទៅកាន់៖ ${ApiConfig.baseUrl}', 'Server changed to: ${ApiConfig.baseUrl}')),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(AppLanguage.tr('រក្សាទុក', 'Save'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLanguage,
      builder: (context, currentLang, _) {
        final isStudent = _selectedRole == UserRole.student;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final borderCol = isDark ? const Color(0xFF334155) : AppColors.border;
        final textCol = isDark ? Colors.white : AppColors.textPrimary;
        final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
        final inputBg = isDark ? const Color(0xFF0F172A) : AppColors.inputBg;
        final pillBg = isDark ? const Color(0xFF1E293B) : AppColors.pillBg;
        final appBarBg = isDark ? const Color(0xFF1E293B) : AppColors.primary;

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            title: Text(
              AppLanguage.tr('ចូលប្រើប្រាស់', 'Sign In'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: appBarBg,
            elevation: 0,
            bottom: isDark
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(height: 1, color: Color(0xFF334155)),
                  )
                : null,
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: const Icon(Icons.language_rounded, size: 18, color: Colors.white),
                label: Text(
                  AppLanguage.isKhmer ? 'EN' : 'ខ្មែរ',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: () async {
                  final newLang = AppLanguage.isKhmer ? 'en' : 'km';
                  await AppLanguage.changeLanguage(newLang);
                  if (mounted) setState(() {});
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_ethernet_rounded, color: Colors.white),
                tooltip: AppLanguage.tr('កំណត់ Server IP (${ApiConfig.host})', 'Set Server IP (${ApiConfig.host})'),
                onPressed: _showServerConfigDialog,
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // --- Card Container (Email & Password) ---
                          Container(
                            padding: const EdgeInsets.all(22.0),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderCol,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.3)
                                      : Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Label: អ៊ីមែល
                                Text(
                                  AppLanguage.tr('អ៊ីមែល', 'Email'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textCol,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // TextFormField: Email
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(color: textCol, fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: AppLanguage.tr('បញ្ចូលអ៊ីមែលរបស់អ្នក', 'Enter your email'),
                                    hintStyle: TextStyle(
                                      color: subTextCol,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.mail_outline_rounded,
                                      color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                                      size: 22,
                                    ),
                                    filled: true,
                                    fillColor: inputBg,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: borderCol),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: borderCol),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.6,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: AppColors.error),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppLanguage.tr('សូមបញ្ចូលអ៊ីមែល', 'Please enter your email');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),

                                // Label: ពាក្យសម្ងាត់
                                Text(
                                  AppLanguage.tr('ពាក្យសម្ងាត់', 'Password'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textCol,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // TextFormField: Password
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  style: TextStyle(color: textCol, fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: AppLanguage.tr('បញ្ចូលពាក្យសម្ងាត់', 'Enter your password'),
                                    hintStyle: TextStyle(
                                      color: subTextCol,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                                      size: 22,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: subTextCol,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: inputBg,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: borderCol),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: borderCol),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.6,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: AppColors.error),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppLanguage.tr('សូមបញ្ចូលពាក្យសម្ងាត់', 'Please enter your password');
                                    }
                                    if (value.length < 6) {
                                      return AppLanguage.tr('ពាក្យសម្ងាត់ត្រូវមានយ៉ាងហោចណាស់ ៦ តួអក្សរ', 'Password must be at least 6 characters');
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // --- Text: ចូលជា ---
                          Center(
                            child: Text(
                              AppLanguage.tr('ចូលជា', 'Sign In As'),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textCol,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // --- Segmented Role Selector: [ 🎓 សិស្ស  |  👤 គ្រូ / បុគ្គលិក ] ---
                          Container(
                            height: 50,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: pillBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderCol),
                            ),
                            child: Row(
                              children: [
                                // Tab 1: 🎓 សិស្ស
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _handleRoleChanged(UserRole.student),
                                    borderRadius: BorderRadius.circular(9),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isStudent
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      alignment: Alignment.center,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.school_outlined,
                                              size: 19,
                                              color: isStudent
                                                  ? Colors.white
                                                  : subTextCol,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              AppLanguage.tr('សិស្ស', 'Student'),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: isStudent
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: isStudent
                                                    ? Colors.white
                                                    : subTextCol,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Tab 2: 👤 គ្រូ / បុគ្គលិក
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _handleRoleChanged(UserRole.teacher),
                                    borderRadius: BorderRadius.circular(9),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: !isStudent
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      alignment: Alignment.center,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person_outline_rounded,
                                              size: 19,
                                              color: !isStudent
                                                  ? Colors.white
                                                  : subTextCol,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              AppLanguage.tr('គ្រូ / បុគ្គលិក', 'Lecturer / Staff'),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: !isStudent
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: !isStudent
                                                    ? Colors.white
                                                    : subTextCol,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // --- Button: ចូលប្រើ ---
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      AppLanguage.tr('ចូលប្រើ', 'Sign In'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
