import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_routes.dart';
import '../models/class_model.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import '../services/class_service.dart';
import '../services/attendance_service.dart';
import '../services/auth_service.dart';
import 'admin_scaffold.dart';

class AdminAttendancesScreen extends StatefulWidget {
  final int? initialClassId;

  const AdminAttendancesScreen({super.key, this.initialClassId});

  @override
  State<AdminAttendancesScreen> createState() => _AdminAttendancesScreenState();
}

class _AdminAttendancesScreenState extends State<AdminAttendancesScreen> {
  List<ClassModel> _classes = [];
  int? _selectedClassId;
  List<AttendanceModel> _attendances = [];
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
      int? selectedId = widget.initialClassId;
      if (_classes.isNotEmpty) {
        if (selectedId == null || !_classes.any((c) => c.id == selectedId)) {
          selectedId = _classes.first.id;
        }
      }
      _selectedClassId = selectedId;
      if (selectedId != null) {
        _loadAttendancesForClass(selectedId);
      } else {
        _isLoading = false;
      }
    } else {
      _initData();
    }
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    final user = await AuthService.getCurrentUser();
    final allClasses = await ClassService.getStudentClasses();
    final displayClasses = _filterForRole(allClasses, user);

    int? selectedId = widget.initialClassId;

    if (displayClasses.isNotEmpty) {
      if (selectedId == null || !displayClasses.any((c) => c.id == selectedId)) {
        selectedId = displayClasses.first.id;
      }
    }

    List<AttendanceModel> atts = [];
    if (selectedId != null) {
      atts = await AttendanceService.getClassAttendances(selectedId);
    }

    if (mounted) {
      setState(() {
        _currentUser = user;
        _classes = displayClasses;
        _selectedClassId = selectedId;
        _attendances = atts;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAttendancesForClass(int classId) async {
    setState(() {
      _selectedClassId = classId;
      _isLoading = true;
    });

    final atts = await AttendanceService.getClassAttendances(classId);
    if (mounted) {
      setState(() {
        _attendances = atts;
        _isLoading = false;
      });
    }
  }

  /// ទាញយក ឬចម្លងរបាយការណ៍វត្តមានជាទម្រង់ CSV / Excel
  void _exportAttendanceCsv() {
    if (_attendances.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLanguage.tr(
            'គ្មានកំណត់ត្រាវត្តមានសម្រាប់ Export ទេ',
            'No attendance records to export',
          )),
        ),
      );
      return;
    }

    final selectedClass = _classes.where((c) => c.id == _selectedClassId).firstOrNull;

    final header = [
      '#',
      'Student Code',
      'Student Name',
      'Class Code',
      'Class Name',
      'Date',
      'Time Scanned',
      'Status',
      'Note / Reason',
    ].join(',');

    final rows = _attendances.asMap().entries.map((entry) {
      final idx = entry.key + 1;
      final a = entry.value;
      final scanTime = a.scannedAt != null
          ? '${a.scannedAt!.hour.toString().padLeft(2, '0')}:${a.scannedAt!.minute.toString().padLeft(2, '0')}'
          : '-';
      return [
        idx,
        '"${a.studentCode}"',
        '"${a.studentName}"',
        '"${a.subjectCode ?? selectedClass?.subjectCode ?? ''}"',
        '"${a.subjectName ?? selectedClass?.subjectName ?? ''}"',
        '"${a.date}"',
        '"$scanTime"',
        '"${a.statusText}"',
        '"${(a.note ?? '').replaceAll('"', '""')}"',
      ].join(',');
    });

    final csv = [header, ...rows].join('\n');
    Clipboard.setData(ClipboardData(text: csv));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLanguage.tr(
          'បានចម្លងរបាយការណ៍វត្តមាន (${_attendances.length} នាក់) ជា CSV រួចរាល់! អាច Paste ចូល Excel បានភ្លាមៗ។',
          'Copied attendance CSV (${_attendances.length} records) to clipboard! Ready to paste into Excel.',
        )),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// បើកផ្ទាំង Dialog ឱ្យគ្រូ ឬ Admin កែប្រែស្ថានភាពវត្តមានសិស្សជាក់ស្តែង
  Future<void> _showEditAttendanceDialog(AttendanceModel item) async {
    String currentStatus = item.status;
    final noteCtrl = TextEditingController(text: item.note ?? '');

    await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textCol = isDark ? Colors.white : AppColors.textPrimary;
            final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLanguage.tr('កែប្រែស្ថានភាពវត្តមានជាក់ស្តែង', 'Edit Actual Attendance'),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textCol),
                        ),
                        Text(
                          '${item.studentName} (${item.studentCode})',
                          style: TextStyle(fontSize: 12, color: subTextCol),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppLanguage.tr('ជ្រើសរើសស្ថានភាពវត្តមាន៖', 'Select Attendance Status:'),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textCol),
                    ),
                    const SizedBox(height: 12),
                    // Status Options: present, late, absent
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusChoice(
                          label: AppLanguage.tr('វត្តមាន (Present)', 'Present'),
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF16A34A),
                          isSelected: currentStatus == 'present',
                          onTap: () => setDlgState(() => currentStatus = 'present'),
                        ),
                        _buildStatusChoice(
                          label: AppLanguage.tr('មកយឺត (Late)', 'Late'),
                          icon: Icons.access_time_filled_rounded,
                          color: const Color(0xFFD97706),
                          isSelected: currentStatus == 'late',
                          onTap: () => setDlgState(() => currentStatus = 'late'),
                        ),
                        _buildStatusChoice(
                          label: AppLanguage.tr('អវត្តមាន (Absent)', 'Absent'),
                          icon: Icons.cancel_rounded,
                          color: const Color(0xFFDC2626),
                          isSelected: currentStatus == 'absent',
                          onTap: () => setDlgState(() => currentStatus = 'absent'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick Note Presets
                    Text(
                      AppLanguage.tr('កំណត់សម្គាល់ (Note / Excuse Reason)៖', 'Note / Reason:'),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textCol),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildQuickChip('មានច្បាប់ឈឺ (Sick Leave)', noteCtrl),
                        _buildQuickChip('ធុរៈគ្រួសារ (Family)', noteCtrl),
                        _buildQuickChip('មកយឺត (Late arrival)', noteCtrl),
                        _buildQuickChip('ទូរស័ព្ទអស់ថ្ម (No battery)', noteCtrl),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteCtrl,
                      decoration: InputDecoration(
                        hintText: AppLanguage.tr('បញ្ចូលមូលហេតុ ឬចំណាំផ្សេងៗ...', 'Enter reason or note...'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx, true);
                    final noteText = noteCtrl.text.trim();
                    final success = await AttendanceService.updateAttendanceStatus(
                      item.id,
                      currentStatus,
                      note: noteText.isNotEmpty ? noteText : null,
                    );
                    if (success) {
                      setState(() {
                        final idx = _attendances.indexWhere((a) => a.id == item.id);
                        if (idx != -1) {
                          _attendances[idx] = AttendanceModel(
                            id: item.id,
                            classId: item.classId,
                            studentId: item.studentId,
                            studentName: item.studentName,
                            studentCode: item.studentCode,
                            status: currentStatus,
                            scannedAt: currentStatus == 'absent' ? null : (item.scannedAt ?? DateTime.now()),
                            date: item.date,
                            note: noteText.isNotEmpty ? noteText : item.note,
                            createdAt: item.createdAt,
                          );
                        }
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLanguage.tr(
                              'បានកែប្រែវត្តមាន ${item.studentName} ចូល Database រួចរាល់!',
                              'Updated attendance in database successfully!',
                            )),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(AppLanguage.tr('រក្សាទុក', 'Save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChoice({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String text, TextEditingController controller) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontSize: 11)),
      onPressed: () {
        controller.text = text;
      },
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final isLecturer = _currentUser?.role == 'lecturer';

    return AdminScaffold(
      title: isLecturer
          ? AppLanguage.tr('វត្តមានសិស្សក្នុងថ្នាក់ (Class Attendance)', 'Class Attendance')
          : AppLanguage.tr('របាយការណ៍ និងគ្រប់គ្រងវត្តមាន', 'Attendance Management'),
      currentRoute: AppRoutes.attendances,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _selectedClassId != null
            ? _loadAttendancesForClass(_selectedClassId!)
            : _initData(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 16 : 32),
        children: [
          // Filter & Class Dropdown Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol),
            ),
            child: LayoutBuilder(
              builder: (context, filterConstraints) {
                final isNarrow = filterConstraints.maxWidth < 600;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLanguage.tr('ជ្រើសរើសថ្នាក់រៀន៖', 'Select Class:'),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textCol),
                      ),
                      const SizedBox(height: 8),
                      if (_classes.isNotEmpty)
                        DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedClassId,
                          dropdownColor: cardBg,
                          style: TextStyle(color: textCol, fontSize: 14),
                          items: _classes.map((c) {
                            return DropdownMenuItem<int>(
                              value: c.id,
                              child: Text('${c.subjectCode} - ${c.subjectName}', overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) _loadAttendancesForClass(val);
                          },
                        )
                      else
                        Text(AppLanguage.tr('គ្មានថ្នាក់រៀន', 'No classes'), style: TextStyle(color: subTextCol)),
                    ],
                  );
                }
                return Row(
                  children: [
                    Text(
                      AppLanguage.tr('ជ្រើសរើសថ្នាក់រៀន៖', 'Select Class:'),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textCol),
                    ),
                    const SizedBox(width: 16),
                    if (_classes.isNotEmpty)
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedClassId,
                          dropdownColor: cardBg,
                          style: TextStyle(color: textCol, fontSize: 14),
                          items: _classes.map((c) {
                            return DropdownMenuItem<int>(
                              value: c.id,
                              child: Text('${c.subjectCode} - ${c.subjectName}', overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) _loadAttendancesForClass(val);
                          },
                        ),
                      )
                    else
                      Text(AppLanguage.tr('គ្មានថ្នាក់រៀន', 'No classes'), style: TextStyle(color: subTextCol)),
                    const SizedBox(width: 16),
                    if (_selectedClassId != null)
                      IconButton(
                        tooltip: 'Refresh',
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () => _loadAttendancesForClass(_selectedClassId!),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Attendance Records Table
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLanguage.tr('កំណត់ត្រាវត្តមានសិស្សជាក់ស្តែង', 'Class Attendances List'),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textCol),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLecturer
                                  ? AppLanguage.tr(
                                      'គ្រូអាចចុចប៊ូតុង "កែប្រែ" ដើម្បីប្តូរវត្តមានជាក់ស្តែងក្នុងថ្នាក់ (មក, យឺត, អវត្តមាន ឬច្បាប់)',
                                      'Lecturers can click Edit to change actual attendance status in class',
                                    )
                                  : AppLanguage.tr(
                                      'សវនកម្ម និងពិនិត្យរបាយការណ៍វត្តមានសិស្សទូទាំងសាកលវិទ្យាល័យ',
                                      'Audit and review university-wide student attendance reports',
                                    ),
                              style: TextStyle(fontSize: 12, color: subTextCol),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: Text(AppLanguage.tr('Export CSV', 'Export CSV')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF10B981),
                          side: const BorderSide(color: Color(0xFF10B981)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _attendances.isEmpty ? null : _exportAttendanceCsv,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_attendances.length} ${AppLanguage.tr('កំណត់ត្រា', 'Records')}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                else if (_attendances.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        AppLanguage.tr('មិនទាន់មានកំណត់ត្រាវត្តមានក្នុងថ្នាក់នេះទេ', 'No attendance records for this class yet'),
                        style: TextStyle(color: subTextCol),
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
                              DataColumn(label: Text(AppLanguage.tr('អត្តលេខសិស្ស', 'Student Code'))),
                              DataColumn(label: Text(AppLanguage.tr('ឈ្មោះសិស្ស', 'Student Name'))),
                              DataColumn(label: Text(AppLanguage.tr('ស្ថានភាព', 'Status'))),
                              DataColumn(label: Text(AppLanguage.tr('កាលបរិច្ឆេទ', 'Date'))),
                              DataColumn(label: Text(AppLanguage.tr('ម៉ោងស្កេន', 'Scanned Time'))),
                              DataColumn(label: Text(AppLanguage.tr('សម្គាល់', 'Note'))),
                              DataColumn(label: Text(AppLanguage.tr('សកម្មភាព (Actions)', 'Actions'))),
                            ],
                            rows: _attendances.map((a) {
                              Color statusColor;
                              String statusLabel;
                              if (a.isLate) {
                                statusColor = const Color(0xFFD97706);
                                statusLabel = AppLanguage.tr('យឺត (Late)', 'Late');
                              } else if (a.isAbsent) {
                                statusColor = const Color(0xFFDC2626);
                                statusLabel = AppLanguage.tr('អវត្តមាន (Absent)', 'Absent');
                              } else {
                                statusColor = const Color(0xFF16A34A);
                                statusLabel = AppLanguage.tr('មក (Present)', 'Present');
                              }

                              return DataRow(
                                cells: [
                                  DataCell(Text('#${a.id}')),
                                  DataCell(Text(a.studentCode.isNotEmpty ? a.studentCode : '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text(a.studentName)),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(a.date)),
                                  DataCell(Text(a.scannedAt != null ? a.scannedAt!.toLocal().toString().substring(11, 16) : '-')),
                                  DataCell(Text(a.note ?? '-', style: TextStyle(color: subTextCol, fontSize: 12))),
                                  DataCell(
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.edit_note_rounded, size: 16),
                                      label: Text(AppLanguage.tr('កែប្រែ', 'Edit')),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        elevation: 0,
                                      ),
                                      onPressed: () => _showEditAttendanceDialog(a),
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
