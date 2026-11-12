import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_routes.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/class_service.dart';
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

  /// បើកផ្ទាំង Admin បង្កើតថ្នាក់រៀនថ្មី និងចាត់តាំងគ្រូបង្រៀន
  Future<void> _openCreateClassDialog() async {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final roomCtrl = TextEditingController(text: 'Room A-101');
    final timeCtrl = TextEditingController(text: '08:00 - 11:00');
    String selectedYear = '2025-2026';
    String selectedSemester = '1';
    String selectedDay = 'ច័ន្ទ (Mon)';
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
                      // ឆ្នាំសិក្សា & ឆមាស
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedYear,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('ឆ្នាំសិក្សា (Academic Year)', 'Academic Year'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(value: '2024-2025', child: Text('2024-2025')),
                                DropdownMenuItem(value: '2025-2026', child: Text('2025-2026')),
                                DropdownMenuItem(value: '2026-2027', child: Text('2026-2027')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDlgState(() => selectedYear = val);
                              },
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

                      // ថ្ងៃរៀន (Day of week)
                      DropdownButtonFormField<String>(
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

                    final success = await ClassService.createClassAdmin(
                      subjectName: nameCtrl.text.trim(),
                      subjectCode: codeCtrl.text.trim().toUpperCase(),
                      lecturerId: selectedLecturerId ?? 1,
                      academicYear: selectedYear,
                      semester: selectedSemester,
                      room: roomCtrl.text.trim(),
                      dayOfWeek: selectedDay,
                      time: timeCtrl.text.trim(),
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
    String selectedYear = c.academicYear.isNotEmpty ? c.academicYear : '2025-2026';
    String selectedSemester = c.semester.isNotEmpty ? c.semester : '1';
    String selectedDay = c.dayOfWeek.isNotEmpty ? c.dayOfWeek : 'ច័ន្ទ (Mon)';
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
                            child: DropdownButtonFormField<String>(
                              initialValue: ['2024-2025', '2025-2026', '2026-2027'].contains(selectedYear)
                                  ? selectedYear
                                  : '2025-2026',
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('ឆ្នាំសិក្សា (Academic Year)', 'Academic Year'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(value: '2024-2025', child: Text('2024-2025')),
                                DropdownMenuItem(value: '2025-2026', child: Text('2025-2026')),
                                DropdownMenuItem(value: '2026-2027', child: Text('2026-2027')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDlgState(() => selectedYear = val);
                              },
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

                    final success = await ClassService.updateClassAdmin(
                      id: c.id,
                      subjectName: nameCtrl.text.trim(),
                      subjectCode: codeCtrl.text.trim().toUpperCase(),
                      lecturerId: selectedLecturerId,
                      academicYear: selectedYear,
                      semester: selectedSemester,
                      room: roomCtrl.text.trim(),
                      dayOfWeek: selectedDay,
                      time: timeCtrl.text.trim(),
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

                        if (_classes.isEmpty)
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
                                      DataColumn(label: Text(AppLanguage.tr('បន្ទប់', 'Room'))),
                                      DataColumn(label: Text(AppLanguage.tr('កាលវិភាគ', 'Schedule'))),
                                      DataColumn(label: Text(AppLanguage.tr('ឆមាស/ឆ្នាំ', 'Semester/Year'))),
                                      DataColumn(label: Text(AppLanguage.tr('ស្ថានភាព QR', 'QR Status'))),
                                      DataColumn(label: Text(AppLanguage.tr('សកម្មភាព (Actions)', 'Actions'))),
                                    ],
                              rows: _classes.map((c) {
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
                                    DataCell(Text(c.room.isNotEmpty ? c.room : '-')),
                                    DataCell(Text('${c.dayOfWeek} (${c.time})')),
                                    DataCell(Text('ឆមាស ${c.semester} (${c.academicYear})')),
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




