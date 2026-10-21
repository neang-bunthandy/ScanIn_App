import 'package:flutter/material.dart';
import '../core/app_colors.dart';
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

  UserRole _selectedRole = UserRole.teacher; // តាមរូបភាព screenshot គឺ គ្រូ / បុគ្គលិក
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
                  'សូមស្វាគមន៍ ${result.user!.name}!',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.dns_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('កំណត់ Server IP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'សូមជ្រើសរើស ឬបញ្ចូល IP ម៉ាស៊ីន Server (Laravel)៖',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hostController,
                decoration: InputDecoration(
                  labelText: 'Host IP',
                  hintText: 'ឧ. 10.0.2.2 ឬ 192.168.42.165',
                  prefixIcon: const Icon(Icons.router_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Emulator (10.0.2.2)'),
                    onPressed: () => hostController.text = '10.0.2.2',
                  ),
                  ActionChip(
                    label: const Text('Wi-Fi PC (192.168.42.165)'),
                    onPressed: () => hostController.text = '192.168.42.165',
                  ),
                  ActionChip(
                    label: const Text('Localhost (127.0.0.1)'),
                    onPressed: () => hostController.text = '127.0.0.1',
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('បោះបង់'),
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
                    content: Text('បានប្តូរ Server ទៅកាន់៖ ${ApiConfig.baseUrl}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('រក្សាទុក', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = _selectedRole == UserRole.student;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ចូលប្រើប្រាស់',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet_rounded, color: Colors.white),
            tooltip: 'កំណត់ Server IP (${ApiConfig.host})',
            onPressed: _showServerConfigDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Card Container (Email & Password) ---
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label: អ៊ីមែល
                          const Text(
                            'អ៊ីមែល',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
          
                          // TextFormField: Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: 'បញ្ចូលអ៊ីមែលរបស់អ្នក',
                              hintStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.mail_outline_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              filled: true,
                              fillColor: AppColors.inputBg,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
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
                                return 'សូមបញ្ចូលអ៊ីមែល';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
          
                          // Label: ពាក្យសម្ងាត់
                          const Text(
                            'ពាក្យសម្ងាត់',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
          
                          // TextFormField: Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            decoration: InputDecoration(
                              hintText: 'បញ្ចូលពាក្យសម្ងាត់',
                              hintStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: AppColors.inputBg,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
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
                                return 'សូមបញ្ចូលពាក្យសម្ងាត់';
                              }
                              if (value.length < 6) {
                                return 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងហោចណាស់ ៦ តួអក្សរ';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
          
                    const SizedBox(height: 24),
          
                    // --- Text: ចូលជា ---
                    const Center(
                      child: Text(
                        'ចូលជា',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
          
                    // --- Segmented Role Selector: [ 🎓 សិស្ស  |  👤 គ្រូ / បុគ្គលិក ] ---
                    Container(
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.pillBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
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
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'សិស្ស',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isStudent
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isStudent
                                              ? Colors.white
                                              : AppColors.textSecondary,
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
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'គ្រូ / បុគ្គលិក',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: !isStudent
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: !isStudent
                                              ? Colors.white
                                              : AppColors.textSecondary,
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
                            : const Text(
                                'ចូលប្រើ',
                                style: TextStyle(
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
    );
  }
}
