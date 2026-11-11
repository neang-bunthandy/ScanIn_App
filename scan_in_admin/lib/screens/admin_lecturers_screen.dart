import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_routes.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/class_service.dart';
import 'admin_scaffold.dart';

class AdminLecturersScreen extends StatefulWidget {
  const AdminLecturersScreen({super.key});

  @override
  State<AdminLecturersScreen> createState() => _AdminLecturersScreenState();
}

class _AdminLecturersScreenState extends State<AdminLecturersScreen> {
  List<Map<String, dynamic>> _lecturers = [];
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = AuthService.cachedUser;
    final cached = ClassService.cachedLecturers;
    if (cached != null && cached.isNotEmpty) {
      _lecturers = cached;
      _isLoading = false;
      _loadLecturers();
    } else {
      _initData();
    }
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    final user = await AuthService.getCurrentUser();
    final lecs = await ClassService.getLecturers();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _lecturers = lecs;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLecturers() async {
    final lecs = await ClassService.getLecturers();
    if (mounted) {
      setState(() {
        _lecturers = lecs;
      });
    }
  }

  /// បើកផ្ទាំង Admin បង្កើតគណនីគ្រូបង្រៀនថ្មី (Name, Email, Password, Department, Phone)
  Future<void> _openCreateLecturerDialog() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: 'password123');
    final deptCtrl = TextEditingController(text: 'វិទ្យាសាស្ត្រកុំព្យូទ័រ (Computer Science)');
    final staffIdCtrl = TextEditingController(text: 'LEC-0${_lecturers.length + 1}');
    final phoneCtrl = TextEditingController(text: '012 345 678');

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textCol = isDark ? Colors.white : AppColors.textPrimary;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF0284C7), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                AppLanguage.tr('បង្កើតគណនីគ្រូបង្រៀនថ្មី', 'Create New Lecturer Account'),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textCol),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLanguage.tr(
                      'Admin ជាអ្នកបង្កើតគណនី និងកំណត់ពាក្យសម្ងាត់ដំបូងឱ្យគ្រូ៖',
                      'Admin sets up email and initial password for the lecturer:',
                    ),
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // ឈ្មោះគ្រូ
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: AppLanguage.tr('ឈ្មោះគ្រូបង្រៀន (Full Name)', 'Lecturer Name'),
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // អ៊ីមែល & ពាក្យសម្ងាត់
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('អ៊ីមែល (Email)', 'Email Address'),
                            hintText: 'teacher@scanin.app',
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: passwordCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ពាក្យសម្ងាត់ (Password)', 'Initial Password'),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ដេប៉ាតឺម៉ង់
                  TextField(
                    controller: deptCtrl,
                    decoration: InputDecoration(
                      labelText: AppLanguage.tr('ដេប៉ាតឺម៉ង់ / មហាវិទ្យាល័យ', 'Department / Faculty'),
                      prefixIcon: const Icon(Icons.account_balance_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // អត្តលេខ & ទូរស័ព្ទ
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: staffIdCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('អត្តលេខគ្រូ (Staff ID)', 'Staff ID'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('លេខទូរស័ព្ទ (Phone)', 'Phone Number'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLanguage.tr('បោះបង់', 'Cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty || passwordCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLanguage.tr(
                        'សូមបញ្ចូលឈ្មោះ អ៊ីមែល និងពាក្យសម្ងាត់ឱ្យបានត្រឹមត្រូវ!',
                        'Please fill in Name, Email and Password!',
                      )),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final result = await ClassService.createLecturer(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  password: passwordCtrl.text,
                  department: deptCtrl.text.trim(),
                  staffId: staffIdCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                );

                if (ctx.mounted) {
                  if (result['success'] == true) {
                    Navigator.pop(ctx, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] as String),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: Text(AppLanguage.tr('បង្កើតគណនីគ្រូ', 'Create Account')),
            ),
          ],
        );
      },
    );

    if (created == true) {
      await _loadLecturers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLanguage.tr(
              'បានបង្កើតគណនីគ្រូបង្រៀនចូល Database ដោយជោគជ័យ!',
              'Lecturer account created in database successfully!',
            )),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// បើកផ្ទាំង Admin កែសម្រួលព័ត៌មានគ្រូបង្រៀន
  Future<void> _openEditLecturerDialog(Map<String, dynamic> lec) async {
    final id = lec['id'] as int;
    final nameCtrl = TextEditingController(text: lec['name'] ?? '');
    final emailCtrl = TextEditingController(text: lec['email'] ?? '');
    final passwordCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: lec['department'] ?? '');
    final staffIdCtrl = TextEditingController(text: lec['staff_id'] ?? '');
    final phoneCtrl = TextEditingController(text: lec['phone'] ?? '');

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textCol = isDark ? Colors.white : AppColors.textPrimary;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                AppLanguage.tr('កែសម្រួលគណនីគ្រូបង្រៀន', 'Edit Lecturer Account'),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textCol),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLanguage.tr(
                      'កែសម្រួលព័ត៌មានគ្រូ (ទុកប្រអប់ Password ទទេ ប្រសិនបើមិនចង់ប្តូរ Password ថ្មី)៖',
                      'Edit lecturer info (Leave password empty to keep current password):',
                    ),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: AppLanguage.tr('ឈ្មោះគ្រូបង្រៀន (Full Name)', 'Lecturer Name'),
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('អ៊ីមែល (Email)', 'Email Address'),
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: passwordCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ពាក្យសម្ងាត់ថ្មី (Password)', 'New Password (Optional)'),
                            hintText: AppLanguage.tr('(មិនប្តូរទុកទទេ)', '(Keep current)'),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: deptCtrl,
                    decoration: InputDecoration(
                      labelText: AppLanguage.tr('ដេប៉ាតឺម៉ង់ / មហាវិទ្យាល័យ', 'Department / Faculty'),
                      prefixIcon: const Icon(Icons.account_balance_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: staffIdCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('អត្តលេខគ្រូ (Staff ID)', 'Staff ID'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('លេខទូរស័ព្ទ (Phone)', 'Phone Number'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLanguage.tr('បោះបង់', 'Cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLanguage.tr(
                        'សូមបញ្ចូលឈ្មោះ និងអ៊ីមែលឱ្យបានត្រឹមត្រូវ!',
                        'Please fill in Name and Email!',
                      )),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final result = await ClassService.updateLecturer(
                  id: id,
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  password: passwordCtrl.text.isNotEmpty ? passwordCtrl.text : null,
                  department: deptCtrl.text.trim(),
                  staffId: staffIdCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                );

                if (ctx.mounted) {
                  if (result['success'] == true) {
                    Navigator.pop(ctx, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] as String),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: Text(AppLanguage.tr('រក្សាទុកការកែប្រែ', 'Save Changes')),
            ),
          ],
        );
      },
    );

    if (updated == true) {
      await _loadLecturers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLanguage.tr(
              'បានកែប្រែគណនីគ្រូបង្រៀនបានជោគជ័យ!',
              'Lecturer account updated successfully!',
            )),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// បញ្ជាក់ការលុបគណនីគ្រូបង្រៀន
  Future<void> _confirmDeleteLecturer(Map<String, dynamic> lec) async {
    final id = lec['id'] as int;
    final name = lec['name'] ?? 'Lecturer #$id';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
              const SizedBox(width: 10),
              Text(
                AppLanguage.tr('បញ្ជាក់ការលុបគណនីគ្រូ', 'Confirm Delete Lecturer'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            AppLanguage.tr(
              'តើអ្នកពិតជាចង់លុបគណនីគ្រូ "$name" នេះចេញពីប្រព័ន្ធមែនទេ?',
              'Are you sure you want to delete lecturer "$name" from the system?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLanguage.tr('បោះបង់', 'Cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLanguage.tr('លុបគណនី', 'Delete Account')),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final result = await ClassService.deleteLecturer(id);
      if (result['success'] == true) {
        await _loadLecturers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLanguage.tr('បានលុបគណនីគ្រូដោយជោគជ័យ!', 'Lecturer deleted successfully!')),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] as String? ?? 'មិនអាចលុបបានទេ'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final isAdmin = _currentUser?.role == 'admin';

    if (!isAdmin && !_isLoading) {
      return AdminScaffold(
        title: AppLanguage.tr('គ្មានសិទ្ធិ (Access Denied)', 'Access Denied'),
        currentRoute: AppRoutes.lecturers,
        body: Center(
          child: Text(
            AppLanguage.tr(
              'ទំព័រនេះសម្រាប់តែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះ។ គ្រូមិនមានសិទ្ធិចូលទំព័រនេះឡើយ។',
              'This page is for Admins only. Lecturers cannot access this page.',
            ),
            style: const TextStyle(color: AppColors.error, fontSize: 15),
          ),
        ),
      );
    }

    return AdminScaffold(
      title: AppLanguage.tr('គ្រប់គ្រងគ្រូបង្រៀន (Lecturers Management)', 'Lecturers Management'),
      currentRoute: AppRoutes.lecturers,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadLecturers,
              child: ListView(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 16 : 32),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Bar
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isNarrow = constraints.maxWidth < 700;
                              final actionButtons = [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                                  label: Text(AppLanguage.tr('+ បង្កើតគណនីគ្រូថ្មី', 'Add Lecturer')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0284C7),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: _openCreateLecturerDialog,
                                ),
                                IconButton(
                                  tooltip: 'Refresh',
                                  icon: const Icon(Icons.refresh_rounded),
                                  onPressed: _loadLecturers,
                                ),
                              ];

                              if (isNarrow) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLanguage.tr('បញ្ជីសាស្រ្តាចារ្យ និងគ្រូបង្រៀនទាំងអស់', 'All Lecturers in University'),
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textCol),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLanguage.tr(
                                        'Admin ជាអ្នកបង្កើតគណនី (Email/Password) ឱ្យគ្រូដើម្បីប្រើប្រាស់ប្រព័ន្ធ',
                                        'Admin creates lecturer accounts with email & password for system access',
                                      ),
                                      style: TextStyle(fontSize: 12, color: subTextCol),
                                    ),
                                    const SizedBox(height: 14),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: actionButtons,
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLanguage.tr('បញ្ជីសាស្រ្តាចារ្យ និងគ្រូបង្រៀនទាំងអស់', 'All Lecturers in University'),
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textCol),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppLanguage.tr(
                                            'Admin ជាអ្នកបង្កើតគណនី (Email/Password) ឱ្យគ្រូដើម្បីប្រើប្រាស់ប្រព័ន្ធ',
                                            'Admin creates lecturer accounts with email & password for system access',
                                          ),
                                          style: TextStyle(fontSize: 12, color: subTextCol),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: actionButtons,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const Divider(height: 1),

                        if (_lecturers.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.people_outline_rounded, size: 48, color: subTextCol),
                                  const SizedBox(height: 12),
                                  Text(
                                    AppLanguage.tr('មិនទាន់មានគណនីគ្រូបង្រៀននៅឡើយទេ', 'No lecturers found'),
                                    style: TextStyle(color: subTextCol, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          LayoutBuilder(
                            builder: (context, tableConstraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: tableConstraints.maxWidth),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                    ),
                                    columns: [
                                      DataColumn(label: Text(AppLanguage.tr('ID', 'ID'))),
                                      DataColumn(label: Text(AppLanguage.tr('អត្តលេខ (Staff ID)', 'Staff ID'))),
                                      DataColumn(label: Text(AppLanguage.tr('ឈ្មោះគ្រូបង្រៀន', 'Lecturer Name'))),
                                      DataColumn(label: Text(AppLanguage.tr('អ៊ីមែល', 'Email'))),
                                      DataColumn(label: Text(AppLanguage.tr('ដេប៉ាតឺម៉ង់', 'Department'))),
                                      DataColumn(label: Text(AppLanguage.tr('លេខទូរស័ព្ទ', 'Phone'))),
                                      DataColumn(label: Text(AppLanguage.tr('ថ្នាក់បង្រៀន', 'Classes'))),
                                      DataColumn(label: Text(AppLanguage.tr('សកម្មភាព (Actions)', 'Actions'))),
                                    ],
                                    rows: _lecturers.map((lec) {
                                      final id = lec['id'];
                                      final staffId = lec['staff_id'] ?? '-';
                                      final name = lec['name'] ?? 'Lecturer #$id';
                                      final email = lec['email'] ?? '-';
                                      final dept = lec['department'] ?? 'ទូទៅ (General)';
                                      final phone = lec['phone'] ?? '-';
                                      final classCount = lec['classes_count'] ?? 0;

                                      return DataRow(
                                        cells: [
                                          DataCell(Text('#$id')),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                staffId.toString(),
                                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: const Color(0xFF0284C7),
                                                  child: Text(
                                                    name.isNotEmpty ? name[0].toUpperCase() : 'L',
                                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: textCol)),
                                              ],
                                            ),
                                          ),
                                          DataCell(Text(email)),
                                          DataCell(Text(dept)),
                                          DataCell(Text(phone)),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '$classCount ${AppLanguage.tr('ថ្នាក់', 'classes')}',
                                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  tooltip: AppLanguage.tr('កែសម្រួលគណនីគ្រូ', 'Edit Lecturer'),
                                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                                  onPressed: () => _openEditLecturerDialog(lec),
                                                ),
                                                IconButton(
                                                  tooltip: AppLanguage.tr('លុបគណនីគ្រូ', 'Delete Lecturer'),
                                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                                  onPressed: () => _confirmDeleteLecturer(lec),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

