import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_routes.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/class_service.dart';
import '../widgets/editable_combo_field.dart';
import 'admin_scaffold.dart';

class AdminClassesScreen extends StatefulWidget {
  const AdminClassesScreen({super.key});

  @override
  State<AdminClassesScreen> createState() => _AdminClassesScreenState();
}

class _AdminClassesScreenState extends State<AdminClassesScreen> {
  List<ClassModel> _classes = [];
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _filterAcademicYear;
  int? _filterYearLevel;
  String? _filterGeneration;
  String? _filterDepartment;

  List<ClassModel> get _filteredClasses {
    return _classes.where((c) {
      if (_filterAcademicYear != null && c.academicYear != _filterAcademicYear) {
        return false;
      }
      if (_filterYearLevel != null && c.yearLevel != _filterYearLevel) {
        return false;
      }
      if (_filterGeneration != null && (c.generation ?? '') != _filterGeneration) {
        return false;
      }
      if (_filterDepartment != null && (c.department ?? '') != _filterDepartment) {
        return false;
      }
      return true;
    }).toList();
  }

  List<ClassModel> _filterForRole(List<ClassModel> allClasses, UserModel? user) {
    if (user?.role == 'lecturer' && user?.id != null) {
      return allClasses.where((c) => c.lecturerId == user!.id).toList();
    }
    return allClasses;
  }

  @override
  void initState() {
    super.initState();
    _currentUser = AuthService.cachedUser;
    final cached = ClassService.cachedClasses;
    if (cached != null) {
      _classes = _filterForRole(cached, _currentUser);
      _isLoading = false;
      _loadClasses();
    } else {
      _initData();
    }
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    final user = await AuthService.getCurrentUser();
    final allClasses = await ClassService.getStudentClasses();
    final displayClasses = _filterForRole(allClasses, user);
    if (mounted) {
      setState(() {
        _currentUser = user;
        _classes = displayClasses;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadClasses() async {
    final allClasses = await ClassService.getStudentClasses();
    final displayClasses = _filterForRole(allClasses, _currentUser);
    if (mounted) {
      setState(() {
        _classes = displayClasses;
      });
    }
  }

  static const List<String> _presetDepartments = ClassService.presetDepartments;

  /// បើកផ្ទាំង Admin បង្កើតថ្នាក់រៀនថ្មី និងចាត់តាំងគ្រូបង្រៀន
  Future<void> _openCreateClassDialog() async {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final roomCtrl = TextEditingController(text: 'Room A-101');
    final timeCtrl = TextEditingController(text: '08:00 - 11:00');
    final totalSessionsCtrl = TextEditingController(text: '15');
    final academicYearOptions = ClassService.buildAcademicYearOptions(
      _classes.map((c) => c.academicYear),
    );
    final genOptions = ClassService.buildGenerationOptions(
      _classes.map((c) => c.generation ?? ''),
    );
    final nowYear = DateTime.now().year;
    final academicYearCtrl = TextEditingController(text: '$nowYear-${nowYear + 1}');
    final generationCtrl = TextEditingController();
    String selectedSemester = '1';
    String selectedDay = 'ច័ន្ទ (Mon)';
    String selectedDepartment = _presetDepartments.first;
    int selectedYearLevel = 1;
    int? selectedLecturerId;

    // ទាញយកបញ្ជីគ្រូបង្រៀនពី Backend
    final lecturers = await ClassService.getLecturers();
    if (lecturers.isNotEmpty) {
      selectedLecturerId = lecturers.first['id'] as int?;
    }

    if (!mounted) return;

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
                    child: const Icon(Icons.add_task_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLanguage.tr('បង្កើតថ្នាក់រៀន និងចាត់តាំងគ្រូ', 'Create Class & Assign Lecturer'),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textCol),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ឆ្នាំសិក្សា (វាយដោយដៃ ឬរើសរហ័ស) & ឆមាស
                      Row(
                        children: [
                          Expanded(
                            child: EditableComboField(
                              controller: academicYearCtrl,
                              labelText: AppLanguage.tr('ឆ្នាំសិក្សា (Academic Year)', 'Academic Year'),
                              hintText: 'ឧ. 2026-2027',
                              suggestions: academicYearOptions,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedSemester,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('ឆមាស (Semester)', 'Semester'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(value: '1', child: Text('ឆមាសទី ១ (Sem 1)')),
                                DropdownMenuItem(value: '2', child: Text('ឆមាសទី ២ (Sem 2)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDlgState(() => selectedSemester = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // កូដមុខវិជ្ជា & ឈ្មោះមុខវិជ្ជា
                      Row(
                        children: [
                          SizedBox(
                            width: 150,
                            child: TextField(
                              controller: codeCtrl,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('កូដមុខវិជ្ជា', 'Subject Code'),
                                hintText: 'CS101',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: nameCtrl,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('ឈ្មោះមុខវិជ្ជា', 'Subject Name'),
                                hintText: 'Mobile App Development',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // បន្ទប់រៀន & ម៉ោង
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: roomCtrl,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('បន្ទប់រៀន (Room)', 'Room'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: timeCtrl,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('ម៉ោងរៀន (Time)', 'Time'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ថ្ងៃរៀន (Day of week) & ចំនួនសប្តាហ៍សរុប (Total Weeks - Default 15)
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: selectedDay,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('ថ្ងៃរៀន (Day of Week)', 'Day of Week'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'ច័ន្ទ (Mon)', child: Text('ច័ន្ទ (Monday)')),
                                DropdownMenuItem(value: 'អង្គារ (Tue)', child: Text('អង្គារ (Tuesday)')),
                                DropdownMenuItem(value: 'ពុធ (Wed)', child: Text('ពុធ (Wednesday)')),
                                DropdownMenuItem(value: 'ព្រហស្បតិ៍ (Thu)', child: Text('ព្រហស្បតិ៍ (Thursday)')),
                                DropdownMenuItem(value: 'សុក្រ (Fri)', child: Text('សុក្រ (Friday)')),
                                DropdownMenuItem(value: 'សៅរ៍ (Sat)', child: Text('សៅរ៍ (Saturday)')),
                                DropdownMenuItem(value: 'អាទិត្យ (Sun)', child: Text('អាទិត្យ (Sunday)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDlgState(() => selectedDay = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 165,
                            child: TextField(
                              controller: totalSessionsCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('សប្តាហ៍សរុប (Default 15)', 'Total Weeks'),
                                hintText: '15',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ជ្រើសរើសគ្រូបង្រៀន (Lecturer Selection)
                      DropdownButtonFormField<int>(
                        initialValue: selectedLecturerId,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('ចាត់តាំងគ្រូបង្រៀន (Assign Lecturer)', 'Assign Lecturer'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          prefixIcon: const Icon(Icons.person_pin_rounded, color: AppColors.primary),
                        ),
                        items: lecturers.isEmpty
                            ? [
                                const DropdownMenuItem(
                                  value: 1,
                                  child: Text('គ្រូគំរូ (Default Lecturer)'),
                                ),
                              ]
                            : lecturers.map((lec) {
                                final id = lec['id'] as int;
                                final name = lec['name'] ?? 'Lecturer #$id';
                                final dept = lec['department'] != null ? ' (${lec['department']})' : '';
                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text('$name$dept', overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                        onChanged: (val) {
                          if (val != null) setDlgState(() => selectedLecturerId = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedDepartment,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('សម្រាប់ដេប៉ាតឺម៉ង់ / ជំនាញ (Department)', 'Target Department'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          prefixIcon: const Icon(Icons.account_balance_outlined, color: AppColors.primary),
                        ),
                        items: _presetDepartments.map((dept) {
                          return DropdownMenuItem<String>(
                            value: dept,
                            child: Text(dept, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDlgState(() => selectedDepartment = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              initialValue: selectedYearLevel,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('សម្រាប់ឆ្នាំទី (Year Level)', 'Target Year Level'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: const [1, 2, 3, 4]
                                  .map((y) => DropdownMenuItem<int>(
                                        value: y,
                                        child: Text(ClassService.yearLevelLabel(y), overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setDlgState(() => selectedYearLevel = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: EditableComboField(
                              controller: generationCtrl,
                              labelText: AppLanguage.tr('ជំនាន់ (ស្រេចចិត្ត)', 'Generation (Optional)'),
                              hintText: AppLanguage.tr('ទុកទទេ = គ្រប់ជំនាន់', 'Empty = Any generation'),
                              clearOptionLabel: AppLanguage.tr('គ្រប់ជំនាន់ក្នុងឆ្នាំនេះ', 'Any Generation'),
                              suggestions: genOptions,
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
                    if (nameCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLanguage.tr(
                            'សូមបញ្ចូលកូដ និងឈ្មោះមុខវិជ្ជាឱ្យបានត្រឹមត្រូវ!',
                            'Please fill in Subject Code and Name!',
                          )),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final totalWeeks = int.tryParse(totalSessionsCtrl.text.trim()) ?? 15;
                    if (totalWeeks < 1 || totalWeeks > 60) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLanguage.tr(
                            'ចំនួនសប្តាហ៍ត្រូវនៅចន្លោះពី 1 ដល់ 60 សប្តាហ៍!',
                            'Total weeks must be between 1 and 60!',
                          )),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final success = await ClassService.createClassAdmin(
                      subjectName: nameCtrl.text.trim(),
                      subjectCode: codeCtrl.text.trim().toUpperCase(),
                      department: selectedDepartment,
                      generation: generationCtrl.text.trim(),
                      yearLevel: selectedYearLevel,
                      lecturerId: selectedLecturerId ?? 1,
                      academicYear: academicYearCtrl.text.trim().isNotEmpty
                          ? academicYearCtrl.text.trim()
                          : '$nowYear-${nowYear + 1}',
                      semester: selectedSemester,
                      room: roomCtrl.text.trim(),
                      dayOfWeek: selectedDay,
                      time: timeCtrl.text.trim(),
                      totalSessions: totalWeeks,
                    );

                    if (context.mounted) {
                      Navigator.pop(ctx, success);
                    }
                  },
                  child: Text(AppLanguage.tr('រក្សាទុកថ្នាក់រៀន', 'Save Class')),
                ),
              ],
            );
          },
        );
      },
    );

    if (created == true) {
      await _loadClasses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLanguage.tr(
              'បានបង្កើតថ្នាក់រៀន និងចាត់តាំងគ្រូបានជោគជ័យ!',
              'Class created and lecturer assigned successfully!',
            )),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// កែប្រែព័ត៌មានថ្នាក់រៀន (Edit Class - Admin Only)
  Future<void> _openEditClassDialog(ClassModel c) async {
    final nameCtrl = TextEditingController(text: c.subjectName);
    final codeCtrl = TextEditingController(text: c.subjectCode);
    final roomCtrl = TextEditingController(text: c.room);
    final timeCtrl = TextEditingController(text: c.time);
    final completedSessionsCtrl = TextEditingController(text: '${c.completedSessions}');
    final totalSessionsCtrl = TextEditingController(text: '${c.totalSessions}');
    final academicYearOptions = ClassService.buildAcademicYearOptions(
      _classes.map((item) => item.academicYear),
    );
    final academicYearCtrl = TextEditingController(
      text: c.academicYear.isNotEmpty ? c.academicYear : academicYearOptions.first,
    );
    String selectedSemester = c.semester.isNotEmpty ? c.semester : '1';
    String selectedDay = c.dayOfWeek.isNotEmpty ? c.dayOfWeek : 'ច័ន្ទ (Mon)';
    final deptOptions = List<String>.from(_presetDepartments);
    if (c.department != null && c.department!.isNotEmpty && !deptOptions.contains(c.department)) {
      deptOptions.insert(0, c.department!);
    }
    String selectedDepartment = (c.department != null && c.department!.isNotEmpty)
        ? c.department!
        : deptOptions.first;
    int selectedYearLevel = (c.yearLevel != null && c.yearLevel! >= 1 && c.yearLevel! <= 4)
        ? c.yearLevel!
        : 1;
    final genOptions = ClassService.buildGenerationOptions(
      _classes.map((item) => item.generation ?? ''),
    );
    final generationCtrl = TextEditingController(text: c.generation ?? '');
    int selectedLecturerId = c.lecturerId;

    final lecturers = await ClassService.getLecturers();
    if (selectedLecturerId <= 0 && lecturers.isNotEmpty) {
      selectedLecturerId = (lecturers.first['id'] as int?) ?? 1;
    }

    if (!mounted) return;

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
                    AppLanguage.tr('កែសម្រួលព័ត៌មានថ្នាក់រៀន', 'Edit Class Details'),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textCol),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: EditableComboField(
                              controller: academicYearCtrl,
                              labelText: AppLanguage.tr('ឆ្នាំសិក្សា (Academic Year)', 'Academic Year'),
                              hintText: 'ឧ. 2026-2027',
                              suggestions: academicYearOptions,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: ['1', '2'].contains(selectedSemester) ? selectedSemester : '1',
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('ឆមាស (Semester)', 'Semester'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(value: '1', child: Text('ឆមាសទី ១ (Sem 1)')),
                                DropdownMenuItem(value: '2', child: Text('ឆមាសទី ២ (Sem 2)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDlgState(() => selectedSemester = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          SizedBox(
                            width: 150,
                            child: TextField(
                              controller: codeCtrl,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('កូដមុខវិជ្ជា', 'Subject Code'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: nameCtrl,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('ឈ្មោះមុខវិជ្ជា', 'Subject Name'),
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
                              controller: roomCtrl,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('បន្ទប់រៀន (Room)', 'Room'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: timeCtrl,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('ម៉ោងរៀន (Time)', 'Time'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: ['ច័ន្ទ (Mon)', 'អង្គារ (Tue)', 'ពុធ (Wed)', 'ព្រហស្បតិ៍ (Thu)', 'សុក្រ (Fri)', 'សៅរ៍ (Sat)', 'អាទិត្យ (Sun)'].contains(selectedDay)
                            ? selectedDay
                            : 'ច័ន្ទ (Mon)',
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('ថ្ងៃរៀន (Day of Week)', 'Day of Week'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'ច័ន្ទ (Mon)', child: Text('ច័ន្ទ (Monday)')),
                          DropdownMenuItem(value: 'អង្គារ (Tue)', child: Text('អង្គារ (Tuesday)')),
                          DropdownMenuItem(value: 'ពុធ (Wed)', child: Text('ពុធ (Wednesday)')),
                          DropdownMenuItem(value: 'ព្រហស្បតិ៍ (Thu)', child: Text('ព្រហស្បតិ៍ (Thursday)')),
                          DropdownMenuItem(value: 'សុក្រ (Fri)', child: Text('សុក្រ (Friday)')),
                          DropdownMenuItem(value: 'សៅរ៍ (Sat)', child: Text('សៅរ៍ (Saturday)')),
                          DropdownMenuItem(value: 'អាទិត្យ (Sun)', child: Text('អាទិត្យ (Sunday)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDlgState(() => selectedDay = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        initialValue: selectedLecturerId,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('ចាត់តាំងគ្រូបង្រៀន (Assign Lecturer)', 'Assign Lecturer'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          prefixIcon: const Icon(Icons.person_pin_rounded, color: AppColors.primary),
                        ),
                        items: lecturers.map((lec) {
                          final id = lec['id'] as int;
                          final name = lec['name'] ?? 'Lecturer #$id';
                          final dept = lec['department'] != null ? ' (${lec['department']})' : '';
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text('$name$dept', overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDlgState(() => selectedLecturerId = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedDepartment,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('សម្រាប់ដេប៉ាតឺម៉ង់ / ជំនាញ (Department)', 'Target Department'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          prefixIcon: const Icon(Icons.account_balance_outlined, color: AppColors.primary),
                        ),
                        items: deptOptions.map((dept) {
                          return DropdownMenuItem<String>(
                            value: dept,
                            child: Text(dept, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDlgState(() => selectedDepartment = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              initialValue: selectedYearLevel,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('សម្រាប់ឆ្នាំទី (Year Level)', 'Target Year Level'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: const [1, 2, 3, 4]
                                  .map((y) => DropdownMenuItem<int>(
                                        value: y,
                                        child: Text(ClassService.yearLevelLabel(y), overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setDlgState(() => selectedYearLevel = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: EditableComboField(
                              controller: generationCtrl,
                              labelText: AppLanguage.tr('ជំនាន់ (ស្រេចចិត្ត)', 'Generation (Optional)'),
                              hintText: AppLanguage.tr('ទុកទទេ = គ្រប់ជំនាន់', 'Empty = Any generation'),
                              clearOptionLabel: AppLanguage.tr('គ្រប់ជំនាន់ក្នុងឆ្នាំនេះ', 'Any Generation'),
                              suggestions: genOptions,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: completedSessionsCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('សប្តាហ៍បានរៀន (Completed)', 'Completed Weeks'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: totalSessionsCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('សប្តាហ៍សរុប (Default 15)', 'Total Weeks'),
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
                    if (nameCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLanguage.tr(
                            'សូមបញ្ចូលកូដ និងឈ្មោះមុខវិជ្ជាឱ្យបានត្រឹមត្រូវ!',
                            'Please fill in Subject Code and Name!',
                          )),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final totalWeeks = int.tryParse(totalSessionsCtrl.text.trim()) ?? 15;
                    final completedWeeks = int.tryParse(completedSessionsCtrl.text.trim()) ?? 0;
                    if (totalWeeks < 1 || totalWeeks > 60 || completedWeeks < 0 || completedWeeks > 60) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLanguage.tr(
                            'ចំនួនសប្តាហ៍សរុបត្រូវនៅចន្លោះ 1-60 និងសប្តាហ៍បានរៀន 0-60!',
                            'Total weeks must be 1-60 and completed weeks 0-60!',
                          )),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final success = await ClassService.updateClassAdmin(
                      id: c.id,
                      subjectName: nameCtrl.text.trim(),
                      subjectCode: codeCtrl.text.trim().toUpperCase(),
                      department: selectedDepartment,
                      generation: generationCtrl.text.trim(),
                      yearLevel: selectedYearLevel,
                      lecturerId: selectedLecturerId,
                      academicYear: academicYearCtrl.text.trim().isNotEmpty
                          ? academicYearCtrl.text.trim()
                          : c.academicYear,
                      semester: selectedSemester,
                      room: roomCtrl.text.trim(),
                      dayOfWeek: selectedDay,
                      time: timeCtrl.text.trim(),
                      totalSessions: totalWeeks,
                      completedSessions: completedWeeks,
                    );

                    if (context.mounted) {
                      Navigator.pop(ctx, success);
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
      await _loadClasses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLanguage.tr(
              'បានកែប្រែព័ត៌មានថ្នាក់រៀនបានជោគជ័យ!',
              'Class updated successfully!',
            )),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// លុបថ្នាក់រៀន (Delete Class - Admin Only)
  Future<void> _confirmDeleteClass(ClassModel c) async {
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
                AppLanguage.tr('បញ្ជាក់ការលុបថ្នាក់រៀន', 'Confirm Delete Class'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            AppLanguage.tr(
              'តើអ្នកពិតជាចង់លុបថ្នាក់រៀន "${c.subjectName} (${c.subjectCode})" នេះមែនទេ? រាល់ទិន្នន័យវត្តមានទាំងអស់ដែលពាក់ព័ន្ធនឹងត្រូវលុបចេញពីប្រព័ន្ធផងដែរ!',
              'Are you sure you want to delete class "${c.subjectName} (${c.subjectCode})"? All associated attendance records will be removed!',
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
              child: Text(AppLanguage.tr('លុបថ្នាក់រៀន', 'Delete Class')),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await ClassService.deleteClassAdmin(c.id);
      if (success) {
        await _loadClasses();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLanguage.tr('បានលុបថ្នាក់រៀនដោយជោគជ័យ!', 'Class deleted successfully!')),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLanguage.tr('មិនអាចលុបថ្នាក់រៀនបានទេ!', 'Failed to delete class!')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// បើកផ្ទាំង Projector Fullscreen QR Code សម្រាប់គ្រូ ឬ Admin បញ្ចាំងក្នុងថ្នាក់
  void _openProjectorModal(ClassModel c) {
    showDialog(
      context: context,
      builder: (ctx) => _ProjectorDialog(
        classModel: c,
        onStatusChanged: () => _loadClasses(),
      ),
    );
  }

  /// បើកផ្ទាំងមើលបញ្ជីឈ្មោះនិស្សិតក្នុងថ្នាក់ (Enrolled Students Roster Dialog)
  void _openClassRosterDialog(ClassModel c) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        final textCol = isDark ? Colors.white : AppColors.textPrimary;
        final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.people_alt_rounded, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLanguage.tr('បញ្ជីឈ្មោះសិស្សក្នុងថ្នាក់', 'Class Student Roster'),
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textCol),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${c.subjectName} (${c.subjectCode}) · ${c.department ?? "គ្មានដេប៉ាតឺម៉ង់"}${c.yearLevel != null ? " · ឆ្នាំទី ${c.yearLevel}" : ""}${c.generation != null && c.generation!.isNotEmpty ? " · ${c.generation}" : ""}',
                      style: TextStyle(fontSize: 12, color: subTextCol),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          content: SizedBox(
            width: 820,
            height: 480,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: ClassService.getClassStudents(c.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final students = snapshot.data ?? [];
                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 48, color: subTextCol),
                        const SizedBox(height: 12),
                        Text(
                          AppLanguage.tr(
                            'មិនទាន់មាននិស្សិតក្នុងថ្នាក់នេះនៅឡើយទេ',
                            'No students enrolled in this class yet',
                          ),
                          style: TextStyle(fontSize: 14, color: textCol, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLanguage.tr(
                            'ប្រព័ន្ធច្រោះតាម ដេប៉ាតឺម៉ង់ (${c.department ?? "មិនទាន់កំណត់"}) ឆ្នាំទី (${c.yearLevel ?? "ទាំងអស់"}) និងស្ថានភាព Active',
                            'Filtered by Department (${c.department ?? "None"}), Year (${c.yearLevel ?? "All"}), and Active status',
                          ),
                          style: TextStyle(fontSize: 12, color: subTextCol),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Summary bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: subTextCol),
                          const SizedBox(width: 8),
                          Text(
                            '${AppLanguage.tr("សិស្សសរុប៖", "Total Students:")} ${students.length} ${AppLanguage.tr("នាក់", "students")}',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textCol),
                          ),
                          const Spacer(),
                          Text(
                            '${AppLanguage.tr("វត្តមានថ្ងៃនេះ៖", "Present Today:")} ${students.where((s) => (s["today_status"] ?? "").toString() == "present").length} ${AppLanguage.tr("នាក់", "students")}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              ),
                              border: TableBorder.all(color: borderCol, width: 0.5, borderRadius: BorderRadius.circular(8)),
                              columns: [
                                const DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text(AppLanguage.tr('អត្តលេខ', 'Code'), style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text(AppLanguage.tr('ឈ្មោះនិស្សិត', 'Student Name'), style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text(AppLanguage.tr('ភេទ', 'Gender'), style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text(AppLanguage.tr('លេខទូរស័ព្ទ', 'Phone'), style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text(AppLanguage.tr('វត្តមានថ្ងៃនេះ', 'Today Status'), style: const TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: List.generate(students.length, (index) {
                                final s = students[index];
                                final name = (s['name'] ?? '').toString();
                                final latinName = (s['latin_name'] ?? '').toString();
                                final code = (s['student_code'] ?? '-').toString();
                                final gender = (s['gender'] ?? '-').toString();
                                final phone = (s['phone'] ?? '-').toString();
                                final todayStatus = (s['today_status'] ?? '').toString();

                                final bool isPresent = todayStatus == 'present';
                                final bool isLate = todayStatus == 'late';

                                final Color badgeBg = isPresent
                                    ? const Color(0xFF16A34A).withValues(alpha: 0.15)
                                    : isLate
                                        ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                                        : (isDark ? const Color(0xFF334155).withValues(alpha: 0.3) : const Color(0xFFE2E8F0));
                                final Color badgeText = isPresent
                                    ? const Color(0xFF16A34A)
                                    : isLate
                                        ? const Color(0xFFD97706)
                                        : subTextCol;
                                final String statusLabel = isPresent
                                    ? AppLanguage.tr('✓ វត្តមាន', '✓ Present')
                                    : isLate
                                        ? AppLanguage.tr('⏰ យឺត', '⏰ Late')
                                        : AppLanguage.tr('○ មិនទាន់ស្កេន', '○ Not Scanned');

                                return DataRow(
                                  cells: [
                                    DataCell(Text('${index + 1}', style: TextStyle(color: subTextCol, fontSize: 12))),
                                    DataCell(Text(code, style: TextStyle(fontWeight: FontWeight.w600, color: textCol, fontSize: 12.5))),
                                    DataCell(
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: textCol, fontSize: 13)),
                                          if (latinName.isNotEmpty)
                                            Text(latinName, style: TextStyle(fontSize: 11, color: subTextCol)),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(gender, style: TextStyle(color: textCol, fontSize: 12))),
                                    DataCell(Text(phone, style: TextStyle(color: textCol, fontSize: 12))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: badgeBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          statusLabel,
                                          style: TextStyle(color: badgeText, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLanguage.tr('បិទ', 'Close'), style: TextStyle(color: textCol)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final isAdmin = _currentUser?.role == 'admin';

    return AdminScaffold(
      title: isAdmin
          ? AppLanguage.tr('គ្រប់គ្រងថ្នាក់រៀន (Classes Management)', 'Classes Management')
          : AppLanguage.tr('ថ្នាក់បង្រៀនរបស់ខ្ញុំ (My Teaching Classes)', 'My Teaching Classes'),
      currentRoute: AppRoutes.classes,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadClasses,
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
                                if (isAdmin)
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add_rounded, size: 18),
                                    label: Text(AppLanguage.tr('បង្កើតថ្នាក់រៀនថ្មី', 'Add New Class')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: _openCreateClassDialog,
                                  ),
                                IconButton(
                                  tooltip: 'Refresh',
                                  icon: const Icon(Icons.refresh_rounded),
                                  onPressed: _loadClasses,
                                ),
                              ];

                              if (isNarrow) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAdmin
                                          ? AppLanguage.tr('បញ្ជីមុខវិជ្ជា និងថ្នាក់រៀនទាំងអស់ទូទាំងសាលា', 'All Classes in University')
                                          : AppLanguage.tr('បញ្ជីមុខវិជ្ជាដែលអ្នកទទួលបន្ទុកបង្រៀន', 'Classes Assigned to You'),
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textCol),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isAdmin
                                          ? AppLanguage.tr('បង្កើត និងចាត់តាំងមុខវិជ្ជាទៅគ្រូបង្រៀនតាមឆ្នាំ/ឆមាស', 'Create and assign classes to lecturers')
                                          : AppLanguage.tr('ចុច "បញ្ចាំង QR" ដើម្បីដាក់លើ Projector ឬតាមដានវត្តមាន', 'Click Projector QR to display on classroom screen'),
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
                                          isAdmin
                                              ? AppLanguage.tr('បញ្ជីមុខវិជ្ជា និងថ្នាក់រៀនទាំងអស់ទូទាំងសាលា', 'All Classes in University')
                                              : AppLanguage.tr('បញ្ជីមុខវិជ្ជាដែលអ្នកទទួលបន្ទុកបង្រៀន', 'Classes Assigned to You'),
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textCol),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isAdmin
                                              ? AppLanguage.tr('បង្កើត និងចាត់តាំងមុខវិជ្ជាទៅគ្រូបង្រៀនតាមឆ្នាំ/ឆមាស', 'Create and assign classes to lecturers')
                                              : AppLanguage.tr('ចុច "បញ្ចាំង QR" ដើម្បីដាក់លើ Projector ឬតាមដានវត្តមាន', 'Click Projector QR to display on classroom screen'),
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

                        // របារច្រោះថ្នាក់រៀនតាម ឆ្នាំសិក្សា, ឆ្នាំទី, ជំនាន់, ដេប៉ាតឺម៉ង់
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SizedBox(
                                width: 165,
                                child: DropdownButtonFormField<String?>(
                                  isExpanded: true,
                                  initialValue: _filterAcademicYear,
                                  decoration: InputDecoration(
                                    labelText: AppLanguage.tr('ឆ្នាំសិក្សា', 'Academic Year'),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(AppLanguage.tr('គ្រប់ឆ្នាំសិក្សា', 'All Years')),
                                    ),
                                    ...ClassService.buildAcademicYearOptions(
                                      _classes.map((c) => c.academicYear),
                                    ).map(
                                      (y) => DropdownMenuItem<String?>(value: y, child: Text(y)),
                                    ),
                                  ],
                                  onChanged: (val) => setState(() => _filterAcademicYear = val),
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
                                width: 205,
                                child: DropdownButtonFormField<String?>(
                                  isExpanded: true,
                                  initialValue: _filterGeneration,
                                  decoration: InputDecoration(
                                    labelText: AppLanguage.tr('ជំនាន់', 'Generation'),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(AppLanguage.tr('គ្រប់ជំនាន់', 'All Generations')),
                                    ),
                                    ...ClassService.buildGenerationOptions(
                                      _classes.map((c) => c.generation ?? ''),
                                    ).map(
                                      (g) => DropdownMenuItem<String?>(value: g, child: Text(g, overflow: TextOverflow.ellipsis)),
                                    ),
                                  ],
                                  onChanged: (val) => setState(() => _filterGeneration = val),
                                ),
                              ),
                              SizedBox(
                                width: 215,
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
                              if (_filterAcademicYear != null ||
                                  _filterYearLevel != null ||
                                  _filterGeneration != null ||
                                  _filterDepartment != null)
                                TextButton.icon(
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  label: Text(AppLanguage.tr('សម្អាត', 'Clear')),
                                  onPressed: () {
                                    setState(() {
                                      _filterAcademicYear = null;
                                      _filterYearLevel = null;
                                      _filterGeneration = null;
                                      _filterDepartment = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        if (_filteredClasses.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.class_outlined, size: 48, color: subTextCol),
                                  const SizedBox(height: 12),
                                  Text(
                                    AppLanguage.tr('មិនទាន់មានទិន្នន័យថ្នាក់រៀននៅឡើយទេ', 'No classes found in system'),
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
                                      DataColumn(label: Text(AppLanguage.tr('កូដ', 'Code'))),
                                      DataColumn(label: Text(AppLanguage.tr('ឈ្មោះមុខវិជ្ជា', 'Subject Name'))),
                                      DataColumn(label: Text(AppLanguage.tr('ដេប៉ាតឺម៉ង់ / ឆ្នាំទី', 'Department / Year'))),
                                      DataColumn(label: Text(AppLanguage.tr('បន្ទប់', 'Room'))),
                                      DataColumn(label: Text(AppLanguage.tr('កាលវិភាគ', 'Schedule'))),
                                      DataColumn(label: Text(AppLanguage.tr('ឆមាស/ឆ្នាំ', 'Semester/Year'))),
                                      DataColumn(label: Text(AppLanguage.tr('ស្ថានភាព QR', 'QR Status'))),
                                      DataColumn(label: Text(AppLanguage.tr('សកម្មភាព (Actions)', 'Actions'))),
                                    ],
                              rows: _filteredClasses.map((c) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          c.subjectCode,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        c.subjectName,
                                        style: TextStyle(fontWeight: FontWeight.w600, color: textCol),
                                      ),
                                    ),
                                    DataCell(
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: (c.department != null && c.department!.isNotEmpty)
                                                  ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                                                  : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              (c.department != null && c.department!.isNotEmpty)
                                                  ? c.department!
                                                  : AppLanguage.tr('មិនទាន់កំណត់', 'Unassigned'),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: (c.department != null && c.department!.isNotEmpty)
                                                    ? const Color(0xFF0284C7)
                                                    : const Color(0xFFD97706),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            [
                                              c.yearLevel != null ? 'ឆ្នាំទី ${c.yearLevel}' : 'មិនទាន់កំណត់ឆ្នាំទី',
                                              if (c.generation != null && c.generation!.isNotEmpty) c.generation!,
                                            ].join(' · '),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: c.yearLevel != null ? subTextCol : const Color(0xFFD97706),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(c.room.isNotEmpty ? c.room : '-')),
                                    DataCell(Text('${c.dayOfWeek} (${c.time})')),
                                    DataCell(
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('ឆមាស ${c.semester} (${c.academicYear})'),
                                          Text(
                                            '${c.completedSessions}/${c.totalSessions} ${AppLanguage.tr('សប្តាហ៍', 'weeks')}',
                                            style: TextStyle(fontSize: 11, color: subTextCol),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: c.isQrActive
                                              ? const Color(0xFF16A34A).withValues(alpha: 0.15)
                                              : const Color(0xFFDC2626).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          c.isQrActive
                                              ? AppLanguage.tr('● កំពុងបើក', '● Active')
                                              : AppLanguage.tr('○ បានបិទ', '○ Closed'),
                                          style: TextStyle(
                                            color: c.isQrActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // ប៊ូតុងបញ្ចាំងលើ Projector ពេញអេក្រង់
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.tv_rounded, size: 16),
                                            label: Text(AppLanguage.tr('បញ្ចាំង QR', 'Project QR')),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0284C7),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              elevation: 0,
                                            ),
                                            onPressed: () => _openProjectorModal(c),
                                          ),
                                          const SizedBox(width: 8),
                                          // ប៊ូតុងមើលបញ្ជីសិស្សក្នុងថ្នាក់ (Class Roster)
                                          OutlinedButton.icon(
                                            icon: const Icon(Icons.people_alt_outlined, size: 16),
                                            label: Text(AppLanguage.tr('បញ្ជីសិស្ស', 'Roster')),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFF10B981),
                                              side: const BorderSide(color: Color(0xFF10B981)),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () => _openClassRosterDialog(c),
                                          ),
                                          const SizedBox(width: 8),
                                          // ប៊ូតុងមើលវត្តមាន
                                          OutlinedButton.icon(
                                            icon: const Icon(Icons.fact_check_outlined, size: 16),
                                            label: Text(AppLanguage.tr('វត្តមាន', 'Attendance')),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () {
                                              Navigator.pushReplacementNamed(context, AppRoutes.attendances, arguments: c.id);
                                            },
                                          ),
                                          if (isAdmin) ...[
                                            const SizedBox(width: 4),
                                            IconButton(
                                              tooltip: AppLanguage.tr('កែប្រែថ្នាក់រៀន', 'Edit Class'),
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                              onPressed: () => _openEditClassDialog(c),
                                            ),
                                            IconButton(
                                              tooltip: AppLanguage.tr('លុបថ្នាក់រៀន', 'Delete Class'),
                                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                              onPressed: () => _confirmDeleteClass(c),
                                            ),
                                          ],
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

/// ផ្ទាំង Modal បញ្ចាំង QR Code ទំហំធំសម្រាប់ Projector / HDMI
class _ProjectorDialog extends StatefulWidget {
  final ClassModel classModel;
  final VoidCallback onStatusChanged;

  const _ProjectorDialog({
    required this.classModel,
    required this.onStatusChanged,
  });

  @override
  State<_ProjectorDialog> createState() => _ProjectorDialogState();
}

class _ProjectorDialogState extends State<_ProjectorDialog> {
  late ClassModel _class;
  late bool _isActive;
  late String _currentToken;
  int _countdown = 240; // 4 minutes
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _class = widget.classModel;
    _isActive = widget.classModel.isQrActive;
    _currentToken = widget.classModel.qrToken ?? 'SCANIN-${_class.subjectCode}-${DateTime.now().year}';
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_countdown > 0 && _isActive) {
        setState(() => _countdown--);
      } else if (_countdown <= 0 && _isActive) {
        _regenerateToken();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _regenerateToken() async {
    final newToken = 'SCANIN-${_class.subjectCode}-${DateTime.now().millisecondsSinceEpoch % 10000}';
    setState(() {
      _currentToken = newToken;
      _countdown = 240;
    });
    await ClassService.toggleQr(_class.id, _isActive, qrToken: newToken);
    widget.onStatusChanged();
  }

  Future<void> _toggleStatus() async {
    final newStatus = !_isActive;
    setState(() => _isActive = newStatus);
    await ClassService.toggleQr(_class.id, newStatus, qrToken: _currentToken);
    widget.onStatusChanged();
  }

  String _formatTimer(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A), // Dark slate presentation background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 680,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _class.subjectCode,
                        style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _class.subjectName,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'បិទ',
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Class info
            Text(
              '${_class.room} • ${_class.dayOfWeek} (${_class.time}) • ឆមាស ${_class.semester} (${_class.academicYear})',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Big QR Frame for Projector
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withValues(alpha: 0.25),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (!_isActive)
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pause_circle_outline_rounded, size: 56, color: Color(0xFFEF4444)),
                          const SizedBox(height: 12),
                          Text(
                            AppLanguage.tr('QR Code ត្រូវបានផ្អាក', 'QR Code is Paused'),
                            style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLanguage.tr('ចុច "បើកដំណើរការ" ដើម្បីបន្ត', 'Click Resume to activate'),
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else
                    // QR Visual Mockup Box with Scanner Styling
                    Container(
                      width: 240,
                      height: 240,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF0F172A), width: 3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildQrCorner(),
                              _buildQrCorner(),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.qr_code_2_rounded, size: 80, color: Color(0xFF0F172A)),
                              const SizedBox(height: 4),
                              Text(
                                _currentToken,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildQrCorner(),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Token and Countdown
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: Color(0xFF38BDF8), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'ផុតកំណត់ក្នុង៖ ${_formatTimer(_countdown)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(AppLanguage.tr('ប្តូរ Token ថ្មី', 'Regenerate')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334155),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _regenerateToken,
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(_isActive ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 18),
                  label: Text(_isActive ? AppLanguage.tr('ផ្អាក QR', 'Pause') : AppLanguage.tr('បើក QR', 'Resume')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isActive ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _toggleStatus,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppLanguage.tr(
                'និស្សិតបើកកម្មវិធី ScanIn លើទូរស័ព្ទដើម្បីស្កេនកត់ត្រាវត្តមានភ្លាមៗ',
                'Students open ScanIn mobile app to scan and check-in instantly',
              ),
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCorner() {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0F172A), width: 4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}




