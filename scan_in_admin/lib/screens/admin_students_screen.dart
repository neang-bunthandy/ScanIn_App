import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_routes.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/class_service.dart';
import 'admin_scaffold.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  List<Map<String, dynamic>> _students = [];
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _filterGeneration;
  String? _filterIntakeYear;
  int? _filterYearLevel;
  String? _filterDepartment;

  List<Map<String, dynamic>> get _filteredStudents {
    return _students.where((stu) {
      if (_filterGeneration != null && (stu['generation'] ?? '').toString() != _filterGeneration) {
        return false;
      }
      if (_filterIntakeYear != null && (stu['intake_year'] ?? '').toString() != _filterIntakeYear) {
        return false;
      }
      if (_filterYearLevel != null) {
        final yl = stu['year_level'] is int
            ? stu['year_level'] as int
            : int.tryParse(stu['year_level']?.toString() ?? '');
        if (yl != _filterYearLevel) return false;
      }
      if (_filterDepartment != null && (stu['department'] ?? '').toString() != _filterDepartment) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _currentUser = AuthService.cachedUser;
    final cached = ClassService.cachedStudents;
    if (cached != null && cached.isNotEmpty) {
      _students = cached;
      _isLoading = false;
      _loadStudents();
    } else {
      _initData();
    }
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    final user = await AuthService.getCurrentUser();
    final stus = await ClassService.getStudents();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _students = stus;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStudents() async {
    final stus = await ClassService.getStudents();
    if (mounted) {
      setState(() {
        _students = stus;
      });
    }
  }

  /// បើកផ្ទាំង Admin បង្កើតគណនីសិស្សថ្មី (Khmer Name, Latin Name, Email, Password, StudentCode, Department, Phone)
  Future<void> _openCreateStudentDialog() async {
    final nameCtrl = TextEditingController();
    final latinNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: 'password123');
    final codeCtrl = TextEditingController(text: 'STU00${_students.length + 1}');
    String selectedDepartment = ClassService.presetDepartments.first;
    String selectedGeneration = ClassService.presetGenerations[2]; // Gen 16 default
    String selectedIntakeYear = '${DateTime.now().year}';
    if (!ClassService.presetIntakeYears.contains(selectedIntakeYear)) {
      selectedIntakeYear = ClassService.presetIntakeYears.last;
    }
    int selectedYearLevel = ClassService.suggestYearLevelFromIntake(selectedIntakeYear);
    final phoneCtrl = TextEditingController(text: '098 765 432');
    String selectedGender = 'ប្រុស (Male)';
    final dobCtrl = TextEditingController(text: '2004-01-01');

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
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
                child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                AppLanguage.tr('បង្កើតគណនីសិស្សថ្មី', 'Create New Student Account'),
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
                      'សាលាជាអ្នកបង្កើតគណនី (Email/Password) ឱ្យសិស្សយកទៅ Login លើ Mobile App៖',
                      'School admin creates student accounts for mobile login:',
                    ),
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // ឈ្មោះជាអក្សរខ្មែរ & ឈ្មោះជាអក្សរឡាតាំង
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ឈ្មោះជាអក្សរខ្មែរ *', 'Khmer Name *'),
                            hintText: 'ឧ. សុខា ម៉េង',
                            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: latinNameCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ឈ្មោះជាអក្សរឡាតាំង', 'Latin Name'),
                            hintText: 'e.g. Sokha Meng',
                            prefixIcon: const Icon(Icons.translate_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // អត្តលេខសិស្ស & ដេប៉ាតឺម៉ង់
                  Row(
                    children: [
                      SizedBox(
                        width: 160,
                        child: TextField(
                          controller: codeCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('អត្តលេខសិស្ស', 'Student ID'),
                            hintText: 'STU001',
                            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedDepartment,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ដេប៉ាតឺម៉ង់ / មហាវិទ្យាល័យ', 'Department'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: ClassService.presetDepartments
                              .map((d) => DropdownMenuItem<String>(
                                    value: d,
                                    child: Text(d, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) selectedDepartment = val;
                          },
                        ),
                      ),
                    ],
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
                            hintText: 'student@scanin.app',
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

                  // ភេទ & ថ្ងៃខែឆ្នាំកំណើត
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedGender,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ភេទ (Gender)', 'Gender'),
                            prefixIcon: const Icon(Icons.wc_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'ប្រុស (Male)', child: Text('ប្រុស (Male)')),
                            DropdownMenuItem(value: 'ស្រី (Female)', child: Text('ស្រី (Female)')),
                          ],
                          onChanged: (val) {
                            if (val != null) selectedGender = val;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: dobCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ថ្ងៃកំណើត (YYYY-MM-DD)', 'Date of Birth'),
                            hintText: '2004-01-01',
                            prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // លេខទូរស័ព្ទ
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: AppLanguage.tr('លេខទូរស័ព្ទ (Phone Number)', 'Phone Number'),
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ជំនាន់ & ចាប់ពីឆ្នាំ & ឆ្នាំទីបច្ចុប្បន្ន
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedGeneration,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ជំនាន់ (Generation)', 'Generation'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: ClassService.presetGenerations
                              .map((g) => DropdownMenuItem<String>(
                                    value: g,
                                    child: Text(g, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setDlgState(() => selectedGeneration = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedIntakeYear,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ចាប់ពីឆ្នាំ', 'Start Year'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: ClassService.presetIntakeYears
                              .map((y) => DropdownMenuItem<String>(value: y, child: Text(y)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDlgState(() {
                                selectedIntakeYear = val;
                                selectedYearLevel = ClassService.suggestYearLevelFromIntake(val);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    key: ValueKey('create-yl-$selectedYearLevel'),
                    isExpanded: true,
                    initialValue: selectedYearLevel,
                    decoration: InputDecoration(
                      labelText: AppLanguage.tr('ឆ្នាំសិក្សាបច្ចុប្បន្ន (Year Level)', 'Current Year Level'),
                      prefixIcon: const Icon(Icons.stairs_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: const [1, 2, 3, 4]
                        .map((y) => DropdownMenuItem<int>(
                              value: y,
                              child: Text(ClassService.yearLevelLabel(y)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDlgState(() => selectedYearLevel = val);
                    },
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
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty || passwordCtrl.text.isEmpty || codeCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLanguage.tr(
                        'សូមបញ្ចូលឈ្មោះ អត្តលេខ អ៊ីមែល និងពាក្យសម្ងាត់ឱ្យបានត្រឹមត្រូវ!',
                        'Please fill in Name, Student ID, Email and Password!',
                      )),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final result = await ClassService.createStudent(
                  name: nameCtrl.text.trim(),
                  latinName: latinNameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  password: passwordCtrl.text,
                  studentCode: codeCtrl.text.trim(),
                  gender: selectedGender.contains('ស្រី') ? 'ស្រី' : 'ប្រុស',
                  dateOfBirth: dobCtrl.text.trim(),
                  department: selectedDepartment,
                  generation: selectedGeneration,
                  intakeYear: selectedIntakeYear,
                  yearLevel: selectedYearLevel,
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
              child: Text(AppLanguage.tr('បង្កើតគណនីសិស្ស', 'Create Account')),
            ),
          ],
        );
          },
        );
      },
    );

    if (created == true) {
      await _loadStudents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLanguage.tr(
              'បានបង្កើតគណនីសិស្សចូល Database ដោយជោគជ័យ!',
              'Student account created in database successfully!',
            )),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// បើកផ្ទាំង Admin កែសម្រួលព័ត៌មានសិស្ស
  Future<void> _openEditStudentDialog(Map<String, dynamic> stu) async {
    final id = stu['id'] as int;
    final nameCtrl = TextEditingController(text: stu['name'] ?? '');
    final latinNameCtrl = TextEditingController(text: stu['latin_name'] ?? '');
    final emailCtrl = TextEditingController(text: stu['email'] ?? '');
    final passwordCtrl = TextEditingController();
    final codeCtrl = TextEditingController(text: stu['student_code'] ?? '');
    final existingDept = (stu['department'] ?? '').toString().trim();
    final deptOptions = [
      ...ClassService.presetDepartments,
      if (existingDept.isNotEmpty && !ClassService.presetDepartments.contains(existingDept)) existingDept,
    ];
    String selectedDepartment = existingDept.isNotEmpty ? existingDept : deptOptions.first;
    final existingGen = (stu['generation'] ?? '').toString().trim();
    final genOptions = [
      ...ClassService.presetGenerations,
      if (existingGen.isNotEmpty && !ClassService.presetGenerations.contains(existingGen)) existingGen,
    ];
    String selectedGeneration = existingGen.isNotEmpty ? existingGen : genOptions[2];
    final existingIntake = (stu['intake_year'] ?? '').toString().trim();
    final intakeOptions = [
      ...ClassService.presetIntakeYears,
      if (existingIntake.isNotEmpty && !ClassService.presetIntakeYears.contains(existingIntake)) existingIntake,
    ];
    String selectedIntakeYear = existingIntake.isNotEmpty ? existingIntake : '2026';
    final existingYear = stu['year_level'] is int
        ? stu['year_level'] as int
        : int.tryParse(stu['year_level']?.toString() ?? '');
    int selectedYearLevel = (existingYear != null && existingYear >= 1 && existingYear <= 4)
        ? existingYear
        : ClassService.suggestYearLevelFromIntake(selectedIntakeYear);
    final phoneCtrl = TextEditingController(text: stu['phone'] ?? '');
    String selectedGender = (stu['gender'] != null && stu['gender'].toString().contains('ស្រី')) ? 'ស្រី (Female)' : 'ប្រុស (Male)';
    final dobCtrl = TextEditingController(text: stu['date_of_birth'] ?? '');

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
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
                AppLanguage.tr('កែសម្រួលគណនីសិស្ស', 'Edit Student Account'),
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
                      'កែសម្រួលព័ត៌មានសិស្ស (ទុកប្រអប់ Password ទទេ ប្រសិនបើមិនចង់ប្តូរ Password ថ្មី)៖',
                      'Edit student info (Leave password empty to keep current password):',
                    ),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ឈ្មោះជាអក្សរខ្មែរ *', 'Khmer Name *'),
                            hintText: 'ឧ. សុខា ម៉េង',
                            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: latinNameCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ឈ្មោះជាអក្សរឡាតាំង', 'Latin Name'),
                            hintText: 'e.g. Sokha Meng',
                            prefixIcon: const Icon(Icons.translate_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: codeCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('អត្តលេខសិស្ស (Student ID)', 'Student ID'),
                            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
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
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
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

                  // ភេទ & ថ្ងៃខែឆ្នាំកំណើត
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedGender,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ភេទ (Gender)', 'Gender'),
                            prefixIcon: const Icon(Icons.wc_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'ប្រុស (Male)', child: Text('ប្រុស (Male)')),
                            DropdownMenuItem(value: 'ស្រី (Female)', child: Text('ស្រី (Female)')),
                          ],
                          onChanged: (val) {
                            if (val != null) selectedGender = val;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: dobCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ថ្ងៃកំណើត (YYYY-MM-DD)', 'Date of Birth'),
                            hintText: '2004-01-01',
                            prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: selectedDepartment,
                    decoration: InputDecoration(
                      labelText: AppLanguage.tr('ដេប៉ាតឺម៉ង់ / មហាវិទ្យាល័យ', 'Department / Faculty'),
                      prefixIcon: const Icon(Icons.account_balance_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: deptOptions
                        .map((d) => DropdownMenuItem<String>(
                              value: d,
                              child: Text(d, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDlgState(() => selectedDepartment = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedGeneration,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ជំនាន់ (Generation)', 'Generation'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: genOptions
                              .map((g) => DropdownMenuItem<String>(
                                    value: g,
                                    child: Text(g, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setDlgState(() => selectedGeneration = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedIntakeYear,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ចាប់ពីឆ្នាំ', 'Start Year'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: intakeOptions
                              .map((y) => DropdownMenuItem<String>(value: y, child: Text(y)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDlgState(() {
                                selectedIntakeYear = val;
                                selectedYearLevel = ClassService.suggestYearLevelFromIntake(val);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    key: ValueKey('edit-yl-$selectedYearLevel'),
                    isExpanded: true,
                    initialValue: selectedYearLevel,
                    decoration: InputDecoration(
                      labelText: AppLanguage.tr('ឆ្នាំសិក្សាបច្ចុប្បន្ន (Year Level)', 'Current Year Level'),
                      prefixIcon: const Icon(Icons.stairs_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: const [1, 2, 3, 4]
                        .map((y) => DropdownMenuItem<int>(
                              value: y,
                              child: Text(ClassService.yearLevelLabel(y)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDlgState(() => selectedYearLevel = val);
                    },
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
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLanguage.tr(
                        'សូមបញ្ចូលឈ្មោះ អត្តលេខ និងអ៊ីមែលឱ្យបានត្រឹមត្រូវ!',
                        'Please fill in Name, Student ID and Email!',
                      )),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final result = await ClassService.updateStudent(
                  id: id,
                  name: nameCtrl.text.trim(),
                  latinName: latinNameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  studentCode: codeCtrl.text.trim(),
                  gender: selectedGender.contains('ស្រី') ? 'ស្រី' : 'ប្រុស',
                  dateOfBirth: dobCtrl.text.trim(),
                  password: passwordCtrl.text.isNotEmpty ? passwordCtrl.text : null,
                  department: selectedDepartment,
                  generation: selectedGeneration,
                  intakeYear: selectedIntakeYear,
                  yearLevel: selectedYearLevel,
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
      },
    );

    if (updated == true) {
      await _loadStudents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLanguage.tr(
              'បានកែប្រែគណនីសិស្សបានជោគជ័យ!',
              'Student account updated successfully!',
            )),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// បើកផ្ទាំង Admin Import សិស្សជាក្រុមពី Excel / CSV
  Future<void> _openImportStudentsDialog() async {
    final csvTextCtrl = TextEditingController();
    List<Map<String, dynamic>> parsedStudents = [];

    void parseCsv(String text, void Function(void Function()) setDlgState) {
      final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
      final list = <Map<String, dynamic>>[];
      if (lines.isEmpty) {
        setDlgState(() => parsedStudents = []);
        return;
      }

      int startIndex = 0;
      final firstLineLower = lines.first.toLowerCase();
      if (firstLineLower.contains('name') || firstLineLower.contains('code') || firstLineLower.contains('id') || firstLineLower.contains('ឈ្មោះ')) {
        startIndex = 1;
      }

      for (int i = startIndex; i < lines.length; i++) {
        final parts = lines[i].split(',').map((p) => p.trim()).toList();
        if (parts.length >= 2) {
          final code = parts[0];
          final name = parts[1];
          final gender = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : 'ប្រុស';
          final dob = parts.length > 3 ? parts[3] : '';
          final email = parts.length > 4 && parts[4].isNotEmpty ? parts[4] : '${code.toLowerCase()}@student.scanin.app';
          final dept = parts.length > 5 && parts[5].isNotEmpty ? parts[5] : 'វិទ្យាសាស្ត្រកុំព្យូទ័រ (CS)';
          final phone = parts.length > 6 ? parts[6] : '';
          final latinName = parts.length > 7 ? parts[7] : '';

          if (code.isNotEmpty && name.isNotEmpty) {
            list.add({
              'student_code': code,
              'name': name,
              if (latinName.isNotEmpty) 'latin_name': latinName,
              'gender': gender,
              'date_of_birth': dob,
              'email': email,
              'department': dept,
              'phone': phone,
            });
          }
        }
      }
      setDlgState(() => parsedStudents = list);
    }

    final imported = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
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
                      color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.file_upload_outlined, color: Color(0xFF16A34A), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLanguage.tr('Import បញ្ជីសិស្សពី Excel / CSV', 'Import Students from Excel/CSV'),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textCol),
                  ),
                ],
              ),
              content: SizedBox(
                width: 580,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLanguage.tr('ទម្រង់ជួរឈរ Excel / CSV៖', 'Excel / CSV Column Format:'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.copy_rounded, size: 14),
                                  label: Text(AppLanguage.tr('ចម្លងទម្រង់គំរូ', 'Copy Template'), style: const TextStyle(fontSize: 12)),
                                  onPressed: () {
                                    const template = 'Student Code,Full Name,Gender,Date of Birth,Email,Department,Phone\n'
                                        'STU101,សុខ ចាន់ដារ៉ា,ប្រុស,2004-05-15,dara@student.scanin.app,Computer Science,012345678\n'
                                        'STU102,គង់ ស្រីមុំ,ស្រី,2005-02-20,sreymom@student.scanin.app,Computer Science,098765432\n'
                                        'STU103,ហេង វិបុល,ប្រុស,2004-11-08,vibol@student.scanin.app,Information Technology,011223344';
                                    csvTextCtrl.text = template;
                                    parseCsv(template, setDlgState);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Student Code, Full Name, Gender, Date of Birth, Email, Department, Phone',
                              style: const TextStyle(fontSize: 12, color: AppColors.primary, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLanguage.tr(
                          'បិទភ្ជាប់ (Paste) ទិន្នន័យពី Excel ឬ CSV ចូលក្នុងប្រអប់ខាងក្រោម៖',
                          'Paste CSV rows or exported Excel data below:',
                        ),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: csvTextCtrl,
                        maxLines: 7,
                        onChanged: (val) => parseCsv(val, setDlgState),
                        decoration: InputDecoration(
                          hintText: 'STU101,សុខ ចាន់ដារ៉ា,ប្រុស,2004-05-15,dara@student.scanin.app,Computer Science,012345678\nSTU102,គង់ ស្រីមុំ,ស្រី,2005-02-20,sreymom@student.scanin.app,Computer Science,098765432',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            parsedStudents.isNotEmpty ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                            color: parsedStudents.isNotEmpty ? const Color(0xFF16A34A) : AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLanguage.tr(
                              'រកឃើញសិស្សត្រឹមត្រូវ៖ ${parsedStudents.length} នាក់',
                              'Detected valid students: ${parsedStudents.length}',
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: parsedStudents.isNotEmpty ? const Color(0xFF16A34A) : AppColors.textSecondary,
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
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                  label: Text(AppLanguage.tr('បញ្ជាក់ការ Import', 'Confirm Import')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: parsedStudents.isEmpty
                      ? null
                      : () async {
                          final result = await ClassService.importStudents(parsedStudents);
                          if (ctx.mounted) {
                            if (result['success'] == true) {
                              Navigator.pop(ctx, true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] as String),
                                  backgroundColor: AppColors.success,
                                ),
                              );
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
                ),
              ],
            );
          },
        );
      },
    );

    if (imported == true) {
      await _loadStudents();
    }
  }

  /// ដំឡើងឆ្នាំសិក្សាសិស្ស +1 ឆ្នាំ (Promote Year Level)
  Future<void> _confirmPromoteStudents() async {
    final filterDesc = [
      ?_filterGeneration,
      if (_filterIntakeYear != null) 'ចាប់ពី $_filterIntakeYear',
      if (_filterYearLevel != null) 'ឆ្នាំទី $_filterYearLevel',
      ?_filterDepartment,
    ].join(' · ');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 26),
              const SizedBox(width: 10),
              Text(
                AppLanguage.tr('ដំឡើងឆ្នាំសិក្សាសិស្ស', 'Promote Student Year Level'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ],
          ),
          content: Text(
            filterDesc.isEmpty
                ? AppLanguage.tr(
                    'តើអ្នកចង់ដំឡើងឆ្នាំសិក្សា +1 ឆ្នាំ (ឆ្នាំទី ១→២, ២→៣, ៣→៤) សម្រាប់សិស្សទាំងអស់ក្នុងប្រព័ន្ធមែនទេ?',
                    'Promote all students in Year 1-3 up by 1 year?',
                  )
                : AppLanguage.tr(
                    'តើអ្នកចង់ដំឡើងឆ្នាំសិក្សា +1 ឆ្នាំ សម្រាប់សិស្សតាមលក្ខខណ្ឌ ($filterDesc) មែនទេ?',
                    'Promote students matching ($filterDesc) up by 1 year?',
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
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLanguage.tr('បញ្ជាក់ដំឡើងឆ្នាំ', 'Promote Now')),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final result = await ClassService.promoteStudents(
        generation: _filterGeneration,
        intakeYear: _filterIntakeYear,
        department: _filterDepartment,
        fromYearLevel: _filterYearLevel,
      );
      if (result['success'] == true) {
        await _loadStudents();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']?.toString() ?? ''),
            backgroundColor: result['success'] == true ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  /// បញ្ជាក់ការលុបគណនីសិស្ស
  Future<void> _confirmDeleteStudent(Map<String, dynamic> stu) async {
    final id = stu['id'] as int;
    final name = stu['name'] ?? 'Student #$id';
    final code = stu['student_code'] ?? '';

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
                AppLanguage.tr('បញ្ជាក់ការលុបគណនីសិស្ស', 'Confirm Delete Student'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            AppLanguage.tr(
              'តើអ្នកពិតជាចង់លុបគណនីសិស្ស "$name ($code)" នេះមែនទេ? រាល់កំណត់ត្រាវត្តមានទាំងអស់របស់សិស្សនេះនឹងត្រូវលុបចេញពីប្រព័ន្ធផងដែរ!',
              'Are you sure you want to delete student "$name ($code)"? All attendance records belonging to this student will also be removed!',
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
      final result = await ClassService.deleteStudent(id);
      if (result['success'] == true) {
        await _loadStudents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLanguage.tr('បានលុបគណនីសិស្សដោយជោគជ័យ!', 'Student deleted successfully!')),
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
        currentRoute: AppRoutes.students,
        body: Center(
          child: Text(
            AppLanguage.tr(
              'ទំព័រនេះសម្រាប់តែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះ។',
              'This page is for Admins only.',
            ),
            style: const TextStyle(color: AppColors.error, fontSize: 15),
          ),
        ),
      );
    }

    return AdminScaffold(
      title: AppLanguage.tr('គ្រប់គ្រងសិស្ស/និស្សិត (Students Management)', 'Students Management'),
      currentRoute: AppRoutes.students,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadStudents,
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
                              final isNarrow = constraints.maxWidth < 750;
                              final actionButtons = [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.trending_up_rounded, size: 18),
                                  label: Text(AppLanguage.tr('ដំឡើងឆ្នាំសិក្សា', 'Promote Year')),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: _confirmPromoteStudents,
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                                  label: Text(AppLanguage.tr('Import Excel / CSV', 'Import Excel/CSV')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: _openImportStudentsDialog,
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                                  label: Text(AppLanguage.tr('+ បង្កើតគណនីសិស្សថ្មី', 'Add Student')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: _openCreateStudentDialog,
                                ),
                                IconButton(
                                  tooltip: 'Refresh',
                                  icon: const Icon(Icons.refresh_rounded),
                                  onPressed: _loadStudents,
                                ),
                              ];

                              if (isNarrow) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLanguage.tr('បញ្ជីសិស្ស/និស្សិតទាំងអស់', 'All Students in System'),
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textCol),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLanguage.tr(
                                        'សាលាជាអ្នកបង្កើតគណនី (Email/Password) ឱ្យសិស្សយកទៅ Login លើ Mobile App ដើម្បីស្កេនវត្តមាន',
                                        'Admin provisions student accounts with email & password for mobile scanning app',
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
                                          AppLanguage.tr('បញ្ជីសិស្ស/និស្សិតទាំងអស់', 'All Students in System'),
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textCol),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppLanguage.tr(
                                            'សាលាជាអ្នកបង្កើតគណនី (Email/Password) ឱ្យសិស្សយកទៅ Login លើ Mobile App ដើម្បីស្កេនវត្តមាន',
                                            'Admin provisions student accounts with email & password for mobile scanning app',
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

                        // របារច្រោះទិន្នន័យតាម ជំនាន់, ចាប់ពីឆ្នាំ, ឆ្នាំទី, ដេប៉ាតឺម៉ង់
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SizedBox(
                                width: 210,
                                child: DropdownButtonFormField<String?>(
                                  isExpanded: true,
                                  initialValue: _filterGeneration,
                                  decoration: InputDecoration(
                                    labelText: AppLanguage.tr('ច្រោះតាមជំនាន់', 'Filter Generation'),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(AppLanguage.tr('គ្រប់ជំនាន់ (All)', 'All Generations')),
                                    ),
                                    ...ClassService.presetGenerations.map(
                                      (g) => DropdownMenuItem<String?>(value: g, child: Text(g, overflow: TextOverflow.ellipsis)),
                                    ),
                                  ],
                                  onChanged: (val) => setState(() => _filterGeneration = val),
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: DropdownButtonFormField<String?>(
                                  isExpanded: true,
                                  initialValue: _filterIntakeYear,
                                  decoration: InputDecoration(
                                    labelText: AppLanguage.tr('ចាប់ពីឆ្នាំ', 'Start Year'),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(AppLanguage.tr('គ្រប់ឆ្នាំ', 'All Years')),
                                    ),
                                    ...ClassService.presetIntakeYears.map(
                                      (y) => DropdownMenuItem<String?>(value: y, child: Text(y)),
                                    ),
                                  ],
                                  onChanged: (val) => setState(() => _filterIntakeYear = val),
                                ),
                              ),
                              SizedBox(
                                width: 170,
                                child: DropdownButtonFormField<int?>(
                                  isExpanded: true,
                                  initialValue: _filterYearLevel,
                                  decoration: InputDecoration(
                                    labelText: AppLanguage.tr('ឆ្នាំទី', 'Year Level'),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: [
                                    DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text(AppLanguage.tr('គ្រប់ឆ្នាំទី (1-4)', 'All Levels')),
                                    ),
                                    ...[1, 2, 3, 4].map(
                                      (y) => DropdownMenuItem<int?>(value: y, child: Text(ClassService.yearLevelLabel(y))),
                                    ),
                                  ],
                                  onChanged: (val) => setState(() => _filterYearLevel = val),
                                ),
                              ),
                              SizedBox(
                                width: 220,
                                child: DropdownButtonFormField<String?>(
                                  isExpanded: true,
                                  initialValue: _filterDepartment,
                                  decoration: InputDecoration(
                                    labelText: AppLanguage.tr('ដេប៉ាតឺម៉ង់', 'Department'),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(AppLanguage.tr('គ្រប់ដេប៉ាតឺម៉ង់', 'All Departments')),
                                    ),
                                    ...ClassService.presetDepartments.map(
                                      (d) => DropdownMenuItem<String?>(value: d, child: Text(d, overflow: TextOverflow.ellipsis)),
                                    ),
                                  ],
                                  onChanged: (val) => setState(() => _filterDepartment = val),
                                ),
                              ),
                              if (_filterGeneration != null ||
                                  _filterIntakeYear != null ||
                                  _filterYearLevel != null ||
                                  _filterDepartment != null)
                                TextButton.icon(
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  label: Text(AppLanguage.tr('សម្អាត', 'Clear')),
                                  onPressed: () {
                                    setState(() {
                                      _filterGeneration = null;
                                      _filterIntakeYear = null;
                                      _filterYearLevel = null;
                                      _filterDepartment = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        if (_filteredStudents.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.school_outlined, size: 48, color: subTextCol),
                                  const SizedBox(height: 12),
                                  Text(
                                    AppLanguage.tr('មិនទាន់មានទិន្នន័យសិស្សនៅឡើយទេ', 'No students found in system'),
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
                                      DataColumn(label: Text(AppLanguage.tr('អត្តលេខសិស្ស', 'Student ID'))),
                                      DataColumn(label: Text(AppLanguage.tr('ឈ្មោះសិស្ស', 'Student Name'))),
                                      DataColumn(label: Text(AppLanguage.tr('ភេទ', 'Gender'))),
                                      DataColumn(label: Text(AppLanguage.tr('ថ្ងៃកំណើត', 'DOB'))),
                                      DataColumn(label: Text(AppLanguage.tr('អ៊ីមែល', 'Email'))),
                                      DataColumn(label: Text(AppLanguage.tr('ដេប៉ាតឺម៉ង់', 'Department'))),
                                      DataColumn(label: Text(AppLanguage.tr('ជំនាន់ / ឆ្នាំទី', 'Generation / Year'))),
                                      DataColumn(label: Text(AppLanguage.tr('លេខទូរស័ព្ទ', 'Phone'))),
                                      DataColumn(label: Text(AppLanguage.tr('សកម្មភាព (Actions)', 'Actions'))),
                                    ],
                                    rows: _filteredStudents.map((stu) {
                                      final id = stu['id'];
                                      final code = stu['student_code'] ?? '-';
                                      final name = (stu['name'] ?? 'Student #$id').toString();
                                      final latinName = (stu['latin_name'] ?? '').toString();
                                      final gender = stu['gender'] ?? '-';
                                      final dob = stu['date_of_birth'] ?? '-';
                                      final isFemale = gender.toString().contains('ស្រី') || gender.toString().toLowerCase().contains('female');
                                      final email = stu['email'] ?? '-';
                                      final dept = stu['department'] ?? 'ទូទៅ (General)';
                                      final generation = (stu['generation'] ?? '').toString();
                                      final intakeYear = (stu['intake_year'] ?? '').toString();
                                      final yearLevel = stu['year_level'] is int
                                          ? stu['year_level'] as int
                                          : int.tryParse(stu['year_level']?.toString() ?? '');
                                      final phone = stu['phone'] ?? '-';

                                      return DataRow(
                                        cells: [
                                          DataCell(Text('#$id')),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                code.toString(),
                                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: isFemale ? Colors.pink : AppColors.primary,
                                                  child: Text(
                                                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: textCol)),
                                                    if (latinName.isNotEmpty)
                                                      Text(latinName, style: TextStyle(fontSize: 11, color: subTextCol)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isFemale
                                                    ? Colors.pink.withValues(alpha: 0.12)
                                                    : const Color(0xFF0284C7).withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                gender.toString(),
                                                style: TextStyle(
                                                  color: isFemale ? Colors.pink : const Color(0xFF0284C7),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(dob.toString())),
                                          DataCell(Text(email)),
                                          DataCell(Text(dept)),
                                          DataCell(
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  yearLevel != null ? 'ឆ្នាំទី $yearLevel' : 'មិនទាន់កំណត់ឆ្នាំទី',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: yearLevel != null ? AppColors.primary : const Color(0xFFD97706),
                                                  ),
                                                ),
                                                if (generation.isNotEmpty || intakeYear.isNotEmpty)
                                                  Text(
                                                    [
                                                      if (generation.isNotEmpty) generation,
                                                      if (intakeYear.isNotEmpty) 'ចាប់ពី $intakeYear',
                                                    ].join(' · '),
                                                    style: TextStyle(fontSize: 11, color: subTextCol),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          DataCell(Text(phone)),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  tooltip: AppLanguage.tr('កែសម្រួលគណនីសិស្ស', 'Edit Student'),
                                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                                  onPressed: () => _openEditStudentDialog(stu),
                                                ),
                                                IconButton(
                                                  tooltip: AppLanguage.tr('លុបគណនីសិស្ស', 'Delete Student'),
                                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                                  onPressed: () => _confirmDeleteStudent(stu),
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

