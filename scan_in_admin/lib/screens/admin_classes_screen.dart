// Classes management, auto-fill, and live Projector QR screen.
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_routes.dart';
import '../models/class_model.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/class_service.dart';
import '../services/attendance_service.dart';
import '../widgets/admin_search_field.dart';
import '../widgets/editable_combo_field.dart';
import 'admin_scaffold.dart';

class AdminClassesScreen extends StatefulWidget {
  const AdminClassesScreen({super.key});

  @override
  State<AdminClassesScreen> createState() => _AdminClassesScreenState();
}

class _AdminClassesScreenState extends State<AdminClassesScreen> {
  final ScrollController _horizontalScrollCtrl = ScrollController();
  List<ClassModel> _classes = [];
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _filterAcademicYear;
  int? _filterYearLevel;
  String? _filterGeneration;
  String? _filterDepartment;
  final TextEditingController _searchCtrl = TextEditingController();
  String? _searchQuery;

  @override
  void dispose() {
    _horizontalScrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ClassModel> get _filteredClasses {
    final q = (_searchQuery ?? '').trim().toLowerCase();
    return _classes.where((c) {
      if (q.isNotEmpty) {
        final code = c.subjectCode.toLowerCase();
        final name = c.subjectName.toLowerCase();
        final lec = (c.lecturerName ?? '').toLowerCase();
        final room = c.room.toLowerCase();
        if (!code.contains(q) && !name.contains(q) && !lec.contains(q) && !room.contains(q)) {
          return false;
        }
      }
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

  List<_GroupedClass> get _groupedClasses {
    final Map<String, List<ClassModel>> map = {};
    for (final c in _filteredClasses) {
      final codeKey = c.subjectCode.trim().toUpperCase();
      final key = codeKey.isNotEmpty
          ? '${codeKey}_${c.department ?? ''}_${c.generation ?? ''}'
          : 'ID_${c.id}';
      map.putIfAbsent(key, () => []).add(c);
    }
    return map.entries.map((entry) {
      final list = entry.value;
      list.sort((a, b) => (a.classDate ?? '').compareTo(b.classDate ?? ''));
      final first = list.first;
      return _GroupedClass(
        key: entry.key,
        subjectCode: first.subjectCode,
        subjectName: first.subjectName,
        department: first.department,
        generation: first.generation,
        yearLevel: first.yearLevel,
        room: first.room,
        time: first.time,
        dayOfWeek: first.dayOfWeek,
        semester: first.semester,
        academicYear: first.academicYear,
        totalSessions: first.totalSessions,
        sessions: list,
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _currentUser = AuthService.cachedUser;
    ClassService.fetchDepartments().then((_) {
      if (mounted) setState(() {});
    });
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

  Widget _buildSessionChip({
    required String label,
    required String timeVal,
    required TextEditingController ctrl,
    required void Function(void Function()) setDlgState,
    required bool isDark,
  }) {
    final isSelected = ctrl.text.trim() == timeVal;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        setDlgState(() {
          ctrl.text = timeVal;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateClassDialog() async {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final roomCtrl = TextEditingController(text: 'Room A-101');
    final timeCtrl = TextEditingController(text: '07:00 - 08:30');
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
    DateTime? selectedDate = DateTime.now();
    const weekDaysKhmer = [
      'ច័ន្ទ (Mon)',
      'អង្គារ (Tue)',
      'ពុធ (Wed)',
      'ព្រហស្បតិ៍ (Thu)',
      'សុក្រ (Fri)',
      'សៅរ៍ (Sat)',
      'អាទិត្យ (Sun)',
    ];
    String selectedDay = weekDaysKhmer[selectedDate.weekday - 1];
    final deptCtrl = TextEditingController(text: ClassService.presetDepartments.first);
    final deptOptions = ClassService.buildDepartmentOptions(
      _classes.map((c) => c.department ?? ''),
    );
    final existingSubjectCodes = _classes
        .map((c) => c.subjectCode.trim())
        .where((code) => code.isNotEmpty)
        .toSet()
        .toList();
    final existingSubjectNames = _classes
        .map((c) => c.subjectName.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    int selectedYearLevel = 1;
    int? selectedLecturerId;

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

            String? autoFilledFromCode;

            void autoFillByCode(String code) {
              final clean = code.trim().toLowerCase();
              if (clean.isEmpty) return;

              final matches = _classes
                  .where((c) => c.subjectCode.trim().toLowerCase() == clean)
                  .toList();

              if (matches.isNotEmpty) {
                matches.sort((a, b) => (a.classDate ?? '').compareTo(b.classDate ?? ''));
                final latest = matches.last;

                setDlgState(() {
                  autoFilledFromCode = latest.subjectCode;
                  if (latest.subjectName.isNotEmpty) {
                    nameCtrl.text = latest.subjectName;
                  }
                  if (latest.room.isNotEmpty) {
                    roomCtrl.text = latest.room;
                  }
                  if (latest.time.isNotEmpty) {
                    timeCtrl.text = latest.time;
                  }
                  if (latest.department != null && latest.department!.isNotEmpty) {
                    deptCtrl.text = latest.department!;
                  }
                  if (latest.generation != null && latest.generation!.isNotEmpty) {
                    generationCtrl.text = latest.generation!;
                  }
                  if (latest.yearLevel != null) {
                    selectedYearLevel = latest.yearLevel!;
                  }
                  if (latest.lecturerId > 0) {
                    selectedLecturerId = latest.lecturerId;
                  }
                  if (latest.dayOfWeek.isNotEmpty) {
                    selectedDay = latest.dayOfWeek;
                  }
                  if (latest.semester.isNotEmpty) {
                    selectedSemester = latest.semester;
                  }
                  if (latest.academicYear.isNotEmpty) {
                    academicYearCtrl.text = latest.academicYear;
                  }
                  if (latest.totalSessions > 0) {
                    totalSessionsCtrl.text = '${latest.totalSessions}';
                  }

                  if (latest.classDate != null && latest.classDate!.isNotEmpty) {
                    final parsed = DateTime.tryParse(latest.classDate!);
                    if (parsed != null) {
                      final nextDate = parsed.add(const Duration(days: 7));
                      selectedDate = nextDate;
                      if (nextDate.weekday >= 1 && nextDate.weekday <= 7) {
                        selectedDay = weekDaysKhmer[nextDate.weekday - 1];
                      }
                    }
                  }
                });
              }
            }

            void autoFillByName(String name) {
              final clean = name.trim().toLowerCase();
              if (clean.isEmpty) return;

              final matches = _classes
                  .where((c) => c.subjectName.trim().toLowerCase() == clean)
                  .toList();

              if (matches.isNotEmpty) {
                matches.sort((a, b) => (a.classDate ?? '').compareTo(b.classDate ?? ''));
                final latest = matches.last;

                setDlgState(() {
                  autoFilledFromCode = latest.subjectCode;
                  if (latest.subjectCode.isNotEmpty && codeCtrl.text.isEmpty) {
                    codeCtrl.text = latest.subjectCode;
                  }
                  if (latest.room.isNotEmpty) {
                    roomCtrl.text = latest.room;
                  }
                  if (latest.time.isNotEmpty) {
                    timeCtrl.text = latest.time;
                  }
                  if (latest.department != null && latest.department!.isNotEmpty) {
                    deptCtrl.text = latest.department!;
                  }
                  if (latest.generation != null && latest.generation!.isNotEmpty) {
                    generationCtrl.text = latest.generation!;
                  }
                  if (latest.yearLevel != null) {
                    selectedYearLevel = latest.yearLevel!;
                  }
                  if (latest.lecturerId > 0) {
                    selectedLecturerId = latest.lecturerId;
                  }
                  if (latest.dayOfWeek.isNotEmpty) {
                    selectedDay = latest.dayOfWeek;
                  }
                  if (latest.semester.isNotEmpty) {
                    selectedSemester = latest.semester;
                  }
                  if (latest.academicYear.isNotEmpty) {
                    academicYearCtrl.text = latest.academicYear;
                  }
                  if (latest.totalSessions > 0) {
                    totalSessionsCtrl.text = '${latest.totalSessions}';
                  }

                  if (latest.classDate != null && latest.classDate!.isNotEmpty) {
                    final parsed = DateTime.tryParse(latest.classDate!);
                    if (parsed != null) {
                      final nextDate = parsed.add(const Duration(days: 7));
                      selectedDate = nextDate;
                      if (nextDate.weekday >= 1 && nextDate.weekday <= 7) {
                        selectedDay = weekDaysKhmer[nextDate.weekday - 1];
                      }
                    }
                  }
                });
              }
            }

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
                              key: ValueKey('sem_$selectedSemester'),
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
                            width: 175,
                            child: EditableComboField(
                              controller: codeCtrl,
                              labelText: AppLanguage.tr('កូដមុខវិជ្ជា', 'Subject Code'),
                              hintText: 'ឧ. HMA-Y4',
                              suggestions: existingSubjectCodes,
                              onChanged: (val) => autoFillByCode(val),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: EditableComboField(
                              controller: nameCtrl,
                              labelText: AppLanguage.tr('ឈ្មោះមុខវិជ្ជា', 'Subject Name'),
                              hintText: 'ឧ. Hybrid Mobile App',
                              suggestions: existingSubjectNames,
                              onChanged: (val) => autoFillByName(val),
                            ),
                          ),
                        ],
                      ),
                      if (autoFilledFromCode != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  AppLanguage.tr(
                                    'ទាញយកទិន្នន័យគំរូពី $autoFilledFromCode រួចរាល់! (អាចកែប្រែកាលបរិច្ឆេទ ឬទិន្នន័យបានតាមចិត្ត)',
                                    'Auto-filled defaults from $autoFilledFromCode! (You can modify date or any fields)',
                                  ),
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                      const SizedBox(height: 8),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLanguage.tr(
                              'រើសម៉ោង Session គំរូ (១ QR = ១ Session = ៩០ នាទី)៖',
                              'Quick University Sessions (1 QR = 1 Session = 90 mins):',
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildSessionChip(label: 'S1: 07:00 - 08:30', timeVal: '07:00 - 08:30', ctrl: timeCtrl, setDlgState: setDlgState, isDark: isDark),
                              _buildSessionChip(label: 'S2: 08:50 - 10:20', timeVal: '08:50 - 10:20', ctrl: timeCtrl, setDlgState: setDlgState, isDark: isDark),
                              _buildSessionChip(label: 'S3: 10:30 - 12:00', timeVal: '10:30 - 12:00', ctrl: timeCtrl, setDlgState: setDlgState, isDark: isDark),
                              _buildSessionChip(label: 'S4: 13:00 - 14:30', timeVal: '13:00 - 14:30', ctrl: timeCtrl, setDlgState: setDlgState, isDark: isDark),
                              _buildSessionChip(label: 'S5: 14:40 - 16:10', timeVal: '14:40 - 16:10', ctrl: timeCtrl, setDlgState: setDlgState, isDark: isDark),
                              _buildSessionChip(label: 'S6: 16:20 - 17:50', timeVal: '16:20 - 17:50', ctrl: timeCtrl, setDlgState: setDlgState, isDark: isDark),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) {
                                  setDlgState(() {
                                    selectedDate = picked;
                                    if (picked.weekday >= 1 && picked.weekday <= 7) {
                                      selectedDay = weekDaysKhmer[picked.weekday - 1];
                                    }
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: AppLanguage.tr('កាលបរិច្ឆេទ (Session Date)', 'Session Date'),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  suffixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                                ),
                                child: Text(
                                  selectedDate != null
                                      ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                                      : AppLanguage.tr('ជ្រើសរើសថ្ងៃខែឆ្នាំ', 'Select Date'),
                                  style: TextStyle(
                                    color: selectedDate != null ? textCol : Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              key: ValueKey('day_$selectedDay'),
                              isExpanded: true,
                              initialValue: weekDaysKhmer.contains(selectedDay) ? selectedDay : weekDaysKhmer.first,
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
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
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

                      DropdownButtonFormField<int>(
                        key: ValueKey('lec_$selectedLecturerId'),
                        initialValue: (lecturers.any((l) => l['id'] == selectedLecturerId)) ? selectedLecturerId : (lecturers.isNotEmpty ? lecturers.first['id'] as int? : null),
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
                      EditableComboField(
                        controller: deptCtrl,
                        labelText: AppLanguage.tr('សម្រាប់ដេប៉ាតឺម៉ង់ / ជំនាញ (Department)', 'Target Department'),
                        hintText: 'ឧ. ព័ត៌មានវិទ្យា (IT) ឬវាយបញ្ចូលថ្មី',
                        prefixIcon: Icons.account_balance_outlined,
                        suggestions: deptOptions,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              key: ValueKey('year_$selectedYearLevel'),
                              isExpanded: true,
                              initialValue: ClassService.yearLevels.contains(selectedYearLevel) ? selectedYearLevel : 1,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('សម្រាប់ឆ្នាំទី (Year Level)', 'Target Year Level'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: ClassService.yearLevels
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

                    final deptVal = deptCtrl.text.trim().isNotEmpty
                        ? deptCtrl.text.trim()
                        : ClassService.presetDepartments.first;
                    ClassService.registerCustomDepartment(deptVal);

                    final success = await ClassService.createClassAdmin(
                      subjectName: nameCtrl.text.trim(),
                      subjectCode: codeCtrl.text.trim().toUpperCase(),
                      department: deptVal,
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
                      classDate: selectedDate != null
                          ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                          : null,
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
    DateTime? selectedDate = (c.classDate != null && c.classDate!.isNotEmpty)
        ? DateTime.tryParse(c.classDate!)
        : null;
    const weekDaysKhmer = [
      'ច័ន្ទ (Mon)',
      'អង្គារ (Tue)',
      'ពុធ (Wed)',
      'ព្រហស្បតិ៍ (Thu)',
      'សុក្រ (Fri)',
      'សៅរ៍ (Sat)',
      'អាទិត្យ (Sun)',
    ];
    String selectedDay = c.dayOfWeek.isNotEmpty ? c.dayOfWeek : 'ច័ន្ទ (Mon)';
    final deptOptions = ClassService.buildDepartmentOptions(
      _classes.map((item) => item.department ?? ''),
    );
    final deptCtrl = TextEditingController(
      text: (c.department != null && c.department!.isNotEmpty)
          ? c.department!
          : ClassService.presetDepartments.first,
    );
    int selectedYearLevel = (c.yearLevel != null && c.yearLevel! >= 1 && c.yearLevel! <= 5)
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
                      const SizedBox(height: 8),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLanguage.tr(
                              'រើសម៉ោង Session គំរូ (១ QR = ១ Session = ៩០ នាទី)៖',
                              'Quick University Sessions (1 QR = 1 Session = 90 mins):',
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildSessionChip(label: 'S1: 07:00 - 08:30', timeVal: '07:00 - 08:30', ctrl: timeCtrl, setDlgState: setDlgState, isDark: isDark),
                              _buildSessionChip(label: 'S2: 08:50 - 10:20', timeVal: '08:50 - 10:20', ctrl: timeCtrl, setDlgState: setDlgState, isDark: isDark),
                              _buildSessionChip(label: 'S3: 10:30 - 12:00', timeVal: '10:30 - 12:00', ctrl: timeCtrl, setDlgState: setDlgState, isDark: isDark),
                              _buildSessionChip(label: 'S4: 13:00 - 14:30', timeVal: '13:00 - 14:30', ctrl: timeCtrl, setDlgState: setDlgState, isDark: isDark),
                              _buildSessionChip(label: 'S5: 14:40 - 16:10', timeVal: '14:40 - 16:10', ctrl: timeCtrl, setDlgState: setDlgState, isDark: isDark),
                              _buildSessionChip(label: 'S6: 16:20 - 17:50', timeVal: '16:20 - 17:50', ctrl: timeCtrl, setDlgState: setDlgState, isDark: isDark),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) {
                                  setDlgState(() {
                                    selectedDate = picked;
                                    if (picked.weekday >= 1 && picked.weekday <= 7) {
                                      selectedDay = weekDaysKhmer[picked.weekday - 1];
                                    }
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: AppLanguage.tr('កាលបរិច្ឆេទ (Session Date)', 'Session Date'),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  suffixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                                ),
                                child: Text(
                                  selectedDate != null
                                      ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                                      : AppLanguage.tr('ជ្រើសរើសថ្ងៃខែឆ្នាំ', 'Select Date'),
                                  style: TextStyle(
                                    color: selectedDate != null ? textCol : Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
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
                          ),
                        ],
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
                      EditableComboField(
                        controller: deptCtrl,
                        labelText: AppLanguage.tr('សម្រាប់ដេប៉ាតឺម៉ង់ / ជំនាញ (Department)', 'Target Department'),
                        hintText: 'ឧ. ព័ត៌មានវិទ្យា (IT) ឬវាយបញ្ចូលថ្មី',
                        prefixIcon: Icons.account_balance_outlined,
                        suggestions: deptOptions,
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
                              items: ClassService.yearLevels
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

                    final deptVal = deptCtrl.text.trim().isNotEmpty
                        ? deptCtrl.text.trim()
                        : ClassService.presetDepartments.first;
                    ClassService.registerCustomDepartment(deptVal);

                    final success = await ClassService.updateClassAdmin(
                      id: c.id,
                      subjectName: nameCtrl.text.trim(),
                      subjectCode: codeCtrl.text.trim().toUpperCase(),
                      department: deptVal,
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
                      classDate: selectedDate != null
                          ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                          : null,
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

  void _showSessionsDialog(_GroupedClass grouped) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final isAdmin = _currentUser?.isAdmin ?? false;

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF0284C7) : AppColors.primary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.date_range_rounded, color: isDark ? const Color(0xFF38BDF8) : AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${grouped.subjectCode} - ${grouped.subjectName}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textCol),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppLanguage.tr(
                      'កាលវិភាគបង្រៀនទាំងអស់ (${grouped.sessions.length} កាលបរិច្ឆេទ)',
                      'All Scheduled Dates (${grouped.sessions.length} Sessions)',
                    ),
                    style: TextStyle(fontSize: 12, color: subTextCol),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: grouped.sessions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final session = grouped.sessions[index];
                    final dateLabel = (session.classDate != null && session.classDate!.isNotEmpty)
                        ? session.classDate!
                        : (session.dayOfWeek.isNotEmpty ? session.dayOfWeek : '-');

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 13, color: textCol),
                                    const SizedBox(width: 5),
                                    Text(
                                      dateLabel,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textCol),
                                    ),
                                    if (session.dayOfWeek.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Text('(${session.dayOfWeek})', style: TextStyle(fontSize: 11, color: subTextCol)),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 12, color: subTextCol),
                                    const SizedBox(width: 4),
                                    Text(session.time, style: TextStyle(fontSize: 11, color: subTextCol)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: session.isQrActive
                                            ? const Color(0xFF16A34A).withValues(alpha: 0.15)
                                            : const Color(0xFFDC2626).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        session.isQrActive
                                            ? AppLanguage.tr('● QR បើក', '● Active')
                                            : AppLanguage.tr('○ QR បិទ', '○ Closed'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: session.isQrActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            tooltip: AppLanguage.tr('បញ្ចាំង QR', 'Project QR'),
                            icon: const Icon(Icons.tv_rounded, size: 20, color: Color(0xFF0284C7)),
                            onPressed: () {
                              Navigator.pop(dCtx);
                              _openProjectorModal(session);
                            },
                          ),

                          IconButton(
                            tooltip: AppLanguage.tr('វត្តមាន', 'Attendance'),
                            icon: const Icon(Icons.fact_check_outlined, size: 20, color: Color(0xFF10B981)),
                            onPressed: () {
                              Navigator.pop(dCtx);
                              Navigator.pushReplacementNamed(context, AppRoutes.attendances, arguments: session.id);
                            },
                          ),
                          if (isAdmin)
                            IconButton(
                              tooltip: AppLanguage.tr('លុបកាលបរិច្ឆេទនេះ', 'Delete this date'),
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                              onPressed: () async {
                                Navigator.pop(dCtx);
                                await _confirmDeleteClass(session);
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text(AppLanguage.tr('បិទ', 'Close')),
          ),
        ],
      ),
    );
  }

  void _handleProjectQr(_GroupedClass grouped) {
    if (grouped.sessions.length == 1) {
      _openProjectorModal(grouped.sessions.first);
      return;
    }
    final active = grouped.sessions.where((s) => s.isQrActive).firstOrNull;
    if (active != null) {
      _openProjectorModal(active);
      return;
    }
    _showSessionsDialog(grouped);
  }

  void _handleViewAttendance(_GroupedClass grouped) {
    if (grouped.sessions.length == 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.attendances, arguments: grouped.sessions.first.id);
      return;
    }
    _showSessionsDialog(grouped);
  }

  Future<void> _handleDeleteGroupedClass(_GroupedClass grouped) async {
    if (grouped.sessions.length == 1) {
      await _confirmDeleteClass(grouped.sessions.first);
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 10),
            Text(
              AppLanguage.tr('ជម្រើសនៃការលុបថ្នាក់រៀន', 'Delete Class Options'),
              style: TextStyle(fontWeight: FontWeight.bold, color: textCol),
            ),
          ],
        ),
        content: Text(
          AppLanguage.tr(
            'មុខវិជ្ជា "${grouped.subjectName} (${grouped.subjectCode})" មានកាលបរិច្ឆេទបង្រៀនចំនួន ${grouped.sessions.length} ក្នុងប្រព័ន្ធ។\n\nតើលោកអ្នកចង់លុបមុខវិជ្ជានេះទាំងមូល (គ្រប់កាលបរិច្ឆេទ) ឬចង់លុបតែកាលបរិច្ឆេទជាក់លាក់ណាមួយ?',
            'Course "${grouped.subjectName} (${grouped.subjectCode})" has ${grouped.sessions.length} scheduled dates.\n\nDo you want to delete all dates for this course, or choose a specific date?',
          ),
          style: TextStyle(color: textCol),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: Text(AppLanguage.tr('បោះបង់', 'Cancel')),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'single'),
            child: Text(AppLanguage.tr('ជ្រើសរើសថ្ងៃលុប...', 'Select date to delete...')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, 'all'),
            child: Text(AppLanguage.tr('លុបទាំងអស់ (${grouped.sessions.length} ថ្ងៃ)', 'Delete All (${grouped.sessions.length} dates)')),
          ),
        ],
      ),
    );

    if (result == 'single') {
      _showSessionsDialog(grouped);
    } else if (result == 'all') {
      for (final s in grouped.sessions) {
        await ClassService.deleteClassAdmin(s.id);
      }
      _loadClasses();
    }
  }

  void _openProjectorModal(ClassModel c) {
    showDialog(
      context: context,
      builder: (ctx) => _ProjectorDialog(
        classModel: c,
        onStatusChanged: () => _loadClasses(),
      ),
    );
  }

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

                return StatefulBuilder(
                  builder: (sCtx, setDlgState) {
                    return Column(
                      children: [

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
                                final bool isAbsent = todayStatus == 'absent';

                                final Color badgeBg = isPresent
                                    ? const Color(0xFF16A34A).withValues(alpha: 0.15)
                                    : isLate
                                        ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                                        : isAbsent
                                            ? const Color(0xFFDC2626).withValues(alpha: 0.15)
                                            : (isDark ? const Color(0xFF334155).withValues(alpha: 0.3) : const Color(0xFFE2E8F0));
                                final Color badgeText = isPresent
                                    ? const Color(0xFF16A34A)
                                    : isLate
                                        ? const Color(0xFFD97706)
                                        : isAbsent
                                            ? const Color(0xFFDC2626)
                                            : subTextCol;
                                final String statusLabel = isPresent
                                    ? AppLanguage.tr('✓ វត្តមាន', '✓ Present')
                                    : isLate
                                        ? AppLanguage.tr('⏰ យឺត', '⏰ Late')
                                        : isAbsent
                                            ? AppLanguage.tr('✗ អវត្តមាន', '✗ Absent')
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
                                      InkWell(
                                        onTap: () async {
                                          final studentId = s['id'] as int;
                                          final selected = await showDialog<String>(
                                            context: context,
                                            builder: (dCtx) => SimpleDialog(
                                              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                              title: Text(
                                                AppLanguage.tr('កែសម្រួលវត្តមាន៖ $name', 'Change Attendance: $name'),
                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textCol),
                                              ),
                                              children: [
                                                SimpleDialogOption(
                                                  onPressed: () => Navigator.pop(dCtx, 'present'),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                                                      const SizedBox(width: 10),
                                                      Text(AppLanguage.tr('មករៀន (Present)', 'Present'), style: TextStyle(color: textCol)),
                                                    ],
                                                  ),
                                                ),
                                                SimpleDialogOption(
                                                  onPressed: () => Navigator.pop(dCtx, 'late'),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.access_time_filled_rounded, color: Color(0xFFD97706), size: 18),
                                                      const SizedBox(width: 10),
                                                      Text(AppLanguage.tr('មកយឺត (Late)', 'Late'), style: TextStyle(color: textCol)),
                                                    ],
                                                  ),
                                                ),
                                                SimpleDialogOption(
                                                  onPressed: () => Navigator.pop(dCtx, 'absent'),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 18),
                                                      const SizedBox(width: 10),
                                                      Text(AppLanguage.tr('អវត្តមាន (Absent)', 'Absent'), style: TextStyle(color: textCol)),
                                                    ],
                                                  ),
                                                ),
                                                const Divider(),
                                                SimpleDialogOption(
                                                  onPressed: () => Navigator.pop(dCtx, 'reset'),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.restart_alt_rounded, color: Color(0xFF64748B), size: 18),
                                                      const SizedBox(width: 10),
                                                      Text(AppLanguage.tr('កំណត់ឡើងវិញ (មិនទាន់ស្កេន)', 'Reset (Not Scanned)'), style: TextStyle(color: textCol)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (selected != null) {
                                            final res = await AttendanceService.recordManualAttendance(
                                              classId: c.id,
                                              studentId: studentId,
                                              status: selected,
                                            );
                                            if (res['success'] == true) {
                                              setDlgState(() {
                                                s['today_status'] = selected == 'reset' ? null : selected;
                                              });
                                            }
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: badgeBg,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: badgeText.withValues(alpha: 0.3)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                statusLabel,
                                                style: TextStyle(color: badgeText, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(Icons.arrow_drop_down_rounded, size: 14, color: badgeText),
                                            ],
                                          ),
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
    final isAdmin = _currentUser?.isAdmin == true;

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

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              AdminSearchField(
                                controller: _searchCtrl,
                                hintText: AppLanguage.tr('ស្វែងរកកូដ, មុខវិជ្ជា, គ្រូ, បន្ទប់...', 'Search code, subject, lecturer...'),
                                onChanged: (val) => setState(() => _searchQuery = val),
                                onClear: () => setState(() {
                                  _searchCtrl.clear();
                                  _searchQuery = '';
                                }),
                              ),
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
                                      child: Text(AppLanguage.tr('គ្រប់ឆ្នាំទី (1-5)', 'All Levels')),
                                    ),
                                    ...ClassService.yearLevels.map(
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

                        if (_groupedClasses.isEmpty)
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
                              return ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context).copyWith(
                                  dragDevices: {
                                    PointerDeviceKind.touch,
                                    PointerDeviceKind.mouse,
                                    PointerDeviceKind.trackpad,
                                    PointerDeviceKind.stylus,
                                  },
                                ),
                                child: Scrollbar(
                                  controller: _horizontalScrollCtrl,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  child: SingleChildScrollView(
                                    controller: _horizontalScrollCtrl,
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: tableConstraints.maxWidth),
                                      child: DataTable(
                                        columnSpacing: 18,
                                        horizontalMargin: 12,
                                        dataRowMinHeight: 68,
                                        dataRowMaxHeight: 78,
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
                              rows: _groupedClasses.map((grouped) {
                                 final c = grouped.primarySession;
                                 final hasMultipleSessions = grouped.sessions.length > 1;

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
                                           grouped.subjectCode,
                                           style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                         ),
                                       ),
                                     ),
                                     DataCell(
                                       Text(
                                         grouped.subjectName,
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
                                               color: (grouped.department != null && grouped.department!.isNotEmpty)
                                                   ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                                                   : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                               borderRadius: BorderRadius.circular(6),
                                             ),
                                             child: Text(
                                               (grouped.department != null && grouped.department!.isNotEmpty)
                                                   ? grouped.department!
                                                   : AppLanguage.tr('មិនទាន់កំណត់', 'Unassigned'),
                                               style: TextStyle(
                                                 fontSize: 12,
                                                 fontWeight: FontWeight.w500,
                                                 color: (grouped.department != null && grouped.department!.isNotEmpty)
                                                     ? const Color(0xFF0284C7)
                                                     : const Color(0xFFD97706),
                                               ),
                                             ),
                                           ),
                                           const SizedBox(height: 3),
                                           Row(
                                             mainAxisSize: MainAxisSize.min,
                                             children: [
                                               Text(
                                                 grouped.yearLevel != null
                                                     ? '${AppLanguage.tr('ឆ្នាំទី', 'Year')} ${grouped.yearLevel}'
                                                     : AppLanguage.tr('គ្រប់ឆ្នាំ', 'All Years'),
                                                 style: TextStyle(fontSize: 11, color: subTextCol),
                                               ),
                                               if (grouped.generation != null && grouped.generation!.isNotEmpty) ...[
                                                 Text(' • ', style: TextStyle(fontSize: 11, color: subTextCol)),
                                                 Text(
                                                   grouped.generation!,
                                                   style: TextStyle(fontSize: 11, color: subTextCol, fontWeight: FontWeight.w500),
                                                 ),
                                               ],
                                             ],
                                           ),
                                         ],
                                       ),
                                     ),
                                     DataCell(
                                       Text(
                                         grouped.room.isNotEmpty ? grouped.room : '-',
                                         style: TextStyle(color: textCol),
                                       ),
                                     ),
                                     DataCell(
                                       Column(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Row(
                                             mainAxisSize: MainAxisSize.min,
                                             children: [
                                               Icon(
                                                 hasMultipleSessions ? Icons.calendar_month_rounded : Icons.calendar_today_rounded,
                                                 size: 13,
                                                 color: isDark ? const Color(0xFF38BDF8) : AppColors.primary,
                                               ),
                                               const SizedBox(width: 4),
                                               Text(
                                                 hasMultipleSessions
                                                     ? grouped.dayOfWeek
                                                     : ((c.classDate != null && c.classDate!.isNotEmpty) ? c.classDate! : (grouped.dayOfWeek.isNotEmpty ? grouped.dayOfWeek : '-')),
                                                 style: TextStyle(
                                                   fontWeight: FontWeight.bold,
                                                   fontSize: 12,
                                                   color: textCol,
                                                 ),
                                               ),
                                             ],
                                           ),
                                           const SizedBox(height: 2),
                                           Row(
                                             mainAxisSize: MainAxisSize.min,
                                             children: [
                                               Icon(Icons.access_time_rounded, size: 12, color: subTextCol),
                                               const SizedBox(width: 4),
                                               Text(
                                                 grouped.time.isNotEmpty ? grouped.time : '-',
                                                 style: TextStyle(fontSize: 11, color: subTextCol, fontWeight: FontWeight.w500),
                                               ),
                                             ],
                                           ),
                                           if (hasMultipleSessions) ...[
                                             const SizedBox(height: 3),
                                             InkWell(
                                               onTap: () => _showSessionsDialog(grouped),
                                               borderRadius: BorderRadius.circular(4),
                                               child: Container(
                                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                 decoration: BoxDecoration(
                                                   color: (isDark ? const Color(0xFF0284C7) : AppColors.primary).withValues(alpha: 0.15),
                                                   borderRadius: BorderRadius.circular(4),
                                                   border: Border.all(
                                                     color: (isDark ? const Color(0xFF38BDF8) : AppColors.primary).withValues(alpha: 0.3),
                                                     width: 0.8,
                                                   ),
                                                 ),
                                                 child: Row(
                                                   mainAxisSize: MainAxisSize.min,
                                                   children: [
                                                     Icon(Icons.date_range_rounded, size: 11, color: isDark ? const Color(0xFF38BDF8) : AppColors.primary),
                                                     const SizedBox(width: 4),
                                                     Text(
                                                       '${grouped.sessions.length} កាលបរិច្ឆេទ (ចុចមើល)',
                                                       style: TextStyle(
                                                         fontSize: 10,
                                                         fontWeight: FontWeight.bold,
                                                         color: isDark ? const Color(0xFF38BDF8) : AppColors.primary,
                                                       ),
                                                     ),
                                                   ],
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ],
                                       ),
                                     ),
                                     DataCell(
                                       Column(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Text('ឆមាស ${grouped.semester} (${grouped.academicYear})'),
                                           Text(
                                             '${grouped.sessions.length}/${grouped.totalSessions} ${AppLanguage.tr('សប្តាហ៍', 'weeks')}',
                                             style: TextStyle(fontSize: 11, color: subTextCol),
                                           ),
                                         ],
                                       ),
                                     ),
                                     DataCell(
                                       Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                         decoration: BoxDecoration(
                                           color: grouped.isQrActive
                                               ? const Color(0xFF16A34A).withValues(alpha: 0.15)
                                               : const Color(0xFFDC2626).withValues(alpha: 0.15),
                                           borderRadius: BorderRadius.circular(6),
                                         ),
                                         child: Text(
                                           grouped.isQrActive
                                               ? AppLanguage.tr('● កំពុងបើក', '● Active')
                                               : AppLanguage.tr('○ បានបិទ', '○ Closed'),
                                           style: TextStyle(
                                             color: grouped.isQrActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
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
                                             onPressed: () => _handleProjectQr(grouped),
                                           ),
                                           const SizedBox(width: 8),

                                           OutlinedButton.icon(
                                             icon: const Icon(Icons.people_alt_outlined, size: 16),
                                             label: Text(AppLanguage.tr('បញ្ជីសិស្ស', 'Roster')),
                                             style: OutlinedButton.styleFrom(
                                               foregroundColor: const Color(0xFF10B981),
                                               side: const BorderSide(color: Color(0xFF10B981)),
                                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                             ),
                                             onPressed: () => _openClassRosterDialog(grouped.primarySession),
                                           ),
                                           const SizedBox(width: 8),

                                           OutlinedButton.icon(
                                             icon: const Icon(Icons.fact_check_outlined, size: 16),
                                             label: Text(AppLanguage.tr('វត្តមាន', 'Attendance')),
                                             style: OutlinedButton.styleFrom(
                                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                             ),
                                             onPressed: () => _handleViewAttendance(grouped),
                                           ),
                                           if (isAdmin) ...[
                                             const SizedBox(width: 4),
                                             IconButton(
                                               tooltip: AppLanguage.tr('កែប្រែថ្នាក់រៀន', 'Edit Class'),
                                               icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                               onPressed: () => _openEditClassDialog(grouped.primarySession),
                                             ),
                                             IconButton(
                                               tooltip: AppLanguage.tr('លុបថ្នាក់រៀន', 'Delete Class'),
                                               icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                               onPressed: () => _handleDeleteGroupedClass(grouped),
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
  int _countdown = 240;
  Timer? _timer;
  Timer? _pollTimer;
  List<AttendanceModel> _liveAttendances = [];
  bool _isLoadingLive = true;
  DateTime? _lastSyncedAt;

  @override
  void initState() {
    super.initState();
    _class = widget.classModel;
    _isActive = widget.classModel.isQrActive;
    _currentToken = widget.classModel.qrToken ?? 'SCANIN-${_class.subjectCode}-${DateTime.now().year}';
    _startTimer();
    _fetchLiveAttendances();
    _startLivePolling();
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

  void _startLivePolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _fetchLiveAttendances();
      }
    });
  }

  Future<void> _fetchLiveAttendances() async {
    final list = await AttendanceService.getClassAttendances(_class.id);
    if (!mounted) return;

    final sorted = List<AttendanceModel>.from(list);
    sorted.sort((a, b) {
      final aTime = a.scannedAt;
      final bTime = b.scannedAt;
      if (aTime != null && bTime != null) return bTime.compareTo(aTime);
      if (aTime != null) return -1;
      if (bTime != null) return 1;
      return b.id.compareTo(a.id);
    });

    final previousCount = _liveAttendances.where((a) => a.isPresent || a.isLate).length;
    final newCount = sorted.where((a) => a.isPresent || a.isLate).length;

    setState(() {
      _liveAttendances = sorted;
      _isLoadingLive = false;
      _lastSyncedAt = DateTime.now();
    });

    if (newCount != previousCount) {
      widget.onStatusChanged();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollTimer?.cancel();
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

  Widget _buildLiveCheckInPanel() {
    final checkedIn = _liveAttendances.where((a) => a.isPresent || a.isLate).toList();
    final totalExpected = _class.studentCount > 0 ? _class.studentCount : _liveAttendances.length;
    final syncText = _lastSyncedAt != null
        ? '${_lastSyncedAt!.hour.toString().padLeft(2, '0')}:${_lastSyncedAt!.minute.toString().padLeft(2, '0')}:${_lastSyncedAt!.second.toString().padLeft(2, '0')}'
        : '--:--:--';

    return Container(
      height: 410,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: _isActive ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLanguage.tr('វត្តមានផ្ទាល់ (Live Check-in)', 'Live Check-in Feed'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${checkedIn.length} / $totalExpected',
                  style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: AppLanguage.tr('ធ្វើបច្ចុប្បន្នភាពភ្លាម', 'Refresh now'),
                icon: const Icon(Icons.sync_rounded, color: Color(0xFF94A3B8), size: 18),
                onPressed: _fetchLiveAttendances,
              ),
            ],
          ),
          Text(
            AppLanguage.tr(
              'Auto-Refresh រៀងរាល់ ៣ វិនាទី • ចុងក្រោយ៖ $syncText',
              'Auto-refreshes every 3s • Last sync: $syncText',
            ),
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoadingLive
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                : checkedIn.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.qr_code_scanner_rounded, size: 40, color: Color(0xFF475569)),
                            const SizedBox(height: 10),
                            Text(
                              AppLanguage.tr('កំពុងរង់ចាំនិស្សិតស្កេន QR...', 'Waiting for students to scan QR...'),
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: checkedIn.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final a = checkedIn[i];
                          final isLate = a.isLate;
                          final badgeColor = isLate ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);
                          final timeStr = a.scannedAt != null
                              ? '${a.scannedAt!.hour.toString().padLeft(2, '0')}:${a.scannedAt!.minute.toString().padLeft(2, '0')}'
                              : '-';
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: badgeColor.withValues(alpha: 0.16),
                                  child: Icon(
                                    isLate ? Icons.schedule_rounded : Icons.check_rounded,
                                    color: badgeColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.studentName,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${a.studentCode} • $timeStr',
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    a.statusText,
                                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
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
                        Flexible(
                          child: Text(
                            _class.subjectName,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'បិទ',
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_class.room} • ${_class.dayOfWeek} (${_class.time}) • ឆមាស ${_class.semester} (${_class.academicYear})',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ),
              const SizedBox(height: 22),

              LayoutBuilder(
                builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth >= 720;
                  final qrColumn = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
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
                                width: 220,
                                height: 220,
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
                              Container(
                                width: 220,
                                height: 220,
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
                                        const Icon(Icons.qr_code_2_rounded, size: 74, color: Color(0xFF0F172A)),
                                        const SizedBox(height: 4),
                                        Text(
                                          _currentToken,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                            fontSize: 11,
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
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined, color: Color(0xFF38BDF8), size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  _formatTimer(_countdown),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(AppLanguage.tr('ប្តូរ Token', 'Regenerate')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF334155),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _regenerateToken,
                          ),
                          ElevatedButton.icon(
                            icon: Icon(_isActive ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 16),
                            label: Text(_isActive ? AppLanguage.tr('ផ្អាក QR', 'Pause') : AppLanguage.tr('បើក QR', 'Resume')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isActive ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _toggleStatus,
                          ),
                        ],
                      ),
                    ],
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: qrColumn),
                        const SizedBox(width: 24),
                        Expanded(flex: 6, child: _buildLiveCheckInPanel()),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      qrColumn,
                      const SizedBox(height: 20),
                      _buildLiveCheckInPanel(),
                    ],
                  );
                },
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

class _GroupedClass {
  final String key;
  final String subjectCode;
  final String subjectName;
  final String? department;
  final String? generation;
  final int? yearLevel;
  final String room;
  final String time;
  final String dayOfWeek;
  final String semester;
  final String academicYear;
  final int totalSessions;
  final List<ClassModel> sessions;

  _GroupedClass({
    required this.key,
    required this.subjectCode,
    required this.subjectName,
    this.department,
    this.generation,
    this.yearLevel,
    required this.room,
    required this.time,
    required this.dayOfWeek,
    required this.semester,
    required this.academicYear,
    required this.totalSessions,
    required this.sessions,
  });

  bool get isQrActive => sessions.any((s) => s.isQrActive);

  ClassModel get primarySession {
    final active = sessions.where((s) => s.isQrActive).firstOrNull;
    if (active != null) return active;
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final today = sessions.where((s) => (s.classDate ?? '').startsWith(todayStr)).firstOrNull;
    if (today != null) return today;
    return sessions.first;
  }
}
