import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_language.dart';
import '../../models/attendance_model.dart';
import '../../models/class_model.dart';
import '../../data/mock_data.dart';

/// អេក្រង់ពិនិត្យ និងកែសម្រួលបញ្ជីវត្តមានសិស្សពេញលេញតាមថ្នាក់
class AttendanceListScreen extends StatefulWidget {
  final ClassModel? classModel;

  const AttendanceListScreen({super.key, this.classModel});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  late List<AttendanceModel> _attendances;
  String _selectedStatusFilter = 'all'; // all, present, late, absent
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  void _loadAttendances() {
    final all = List<AttendanceModel>.from(MockData.sampleAttendances);
    if (widget.classModel != null) {
      _attendances = all.where((a) => a.classId == widget.classModel!.id).toList();
    } else {
      _attendances = all;
    }
  }

  void _changeAttendanceStatus(AttendanceModel item, String newStatus) {
    setState(() {
      final index = _attendances.indexWhere((a) => a.id == item.id);
      if (index != -1) {
        _attendances[index] = AttendanceModel(
          id: item.id,
          classId: item.classId,
          studentId: item.studentId,
          studentName: item.studentName,
          studentCode: item.studentCode,
          status: newStatus,
          scannedAt: newStatus == 'absent' ? null : DateTime.now(),
          date: item.date,
          note: newStatus == 'present'
              ? AppLanguage.tr('បានកែប្រែដោយគ្រូ', 'Updated by lecturer')
              : (newStatus == 'late' ? AppLanguage.tr('មកយឺត', 'Late') : AppLanguage.tr('អវត្តមាន', 'Absent')),
          createdAt: item.createdAt,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLanguage.tr(
          'បានកែប្រែវត្តមាន ${item.studentName} ទៅជា "${_getStatusKhmer(newStatus)}"',
          'Updated ${item.studentName}\'s attendance to "${_getStatusKhmer(newStatus)}"',
        )),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditStatusModal(AttendanceModel item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${AppLanguage.tr('កែប្រែវត្តមាន: ', 'Edit Attendance: ')}${item.studentName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${AppLanguage.tr('អត្តលេខ៖ ', 'Student ID: ')}${item.studentCode}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
                    title: Text(AppLanguage.tr('វត្តមាន (Present)', 'Present'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: item.isPresent ? const Icon(Icons.done, color: Color(0xFF16A34A)) : null,
                    onTap: () {
                      Navigator.pop(context);
                      _changeAttendanceStatus(item, 'present');
                    },
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.access_time_filled_rounded, color: Color(0xFFD97706)),
                    title: Text(AppLanguage.tr('មកយឺត (Late)', 'Late'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: item.isLate ? const Icon(Icons.done, color: Color(0xFFD97706)) : null,
                    onTap: () {
                      Navigator.pop(context);
                      _changeAttendanceStatus(item, 'late');
                    },
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626)),
                    title: Text(AppLanguage.tr('អវត្តមាន (Absent)', 'Absent'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: item.isAbsent ? const Icon(Icons.done, color: Color(0xFFDC2626)) : null,
                    onTap: () {
                      Navigator.pop(context);
                      _changeAttendanceStatus(item, 'absent');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusKhmer(String status) {
    switch (status) {
      case 'present':
        return AppLanguage.tr('វត្តមាន', 'Present');
      case 'late':
        return AppLanguage.tr('យឺត', 'Late');
      case 'absent':
        return AppLanguage.tr('អវត្តមាន', 'Absent');
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    var filtered = _attendances;

    if (_selectedStatusFilter != 'all') {
      filtered = filtered.where((a) => a.status == _selectedStatusFilter).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((a) {
        return a.studentName.toLowerCase().contains(q) ||
            a.studentCode.toLowerCase().contains(q);
      }).toList();
    }

    final presentCount = _attendances.where((a) => a.isPresent).length;
    final lateCount = _attendances.where((a) => a.isLate).length;
    final absentCount = _attendances.where((a) => a.isAbsent).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.classModel != null
              ? '${AppLanguage.tr('វត្តមាន៖ ', 'Attendance: ')}${widget.classModel!.subjectName}'
              : AppLanguage.tr('របាយការណ៍វត្តមានសរុប', 'Overall Attendance Report'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: AppLanguage.tr('ទាញយករបាយការណ៍ Excel', 'Export Excel Report'),
            icon: const Icon(Icons.file_download_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLanguage.tr('បានទាញយកទិន្នន័យ Excel រួចរាល់', 'Downloaded Excel report successfully')),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Stats Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    label: AppLanguage.tr('វត្តមាន', 'Present'),
                    count: '$presentCount',
                    color: const Color(0xFF16A34A),
                    bg: const Color(0xFFF0FDF4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMiniStat(
                    label: AppLanguage.tr('យឺត', 'Late'),
                    count: '$lateCount',
                    color: const Color(0xFFD97706),
                    bg: const Color(0xFFFFFBEB),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMiniStat(
                    label: AppLanguage.tr('អវត្តមាន', 'Absent'),
                    count: '$absentCount',
                    color: const Color(0xFFDC2626),
                    bg: const Color(0xFFFEF2F2),
                  ),
                ),
              ],
            ),
          ),

          // Search & Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: AppLanguage.tr('ស្វែងរកឈ្មោះសិស្ស ឬអត្តលេខ...', 'Search student name or ID...'),
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(AppLanguage.tr('ទាំងអស់', 'All'), 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('${AppLanguage.tr('វត្តមាន', 'Present')} ($presentCount)', 'present'),
                      const SizedBox(width: 8),
                      _buildFilterChip('${AppLanguage.tr('យឺត', 'Late')} ($lateCount)', 'late'),
                      const SizedBox(width: 8),
                      _buildFilterChip('${AppLanguage.tr('អវត្តមាន', 'Absent')} ($absentCount)', 'absent'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Student Attendance List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      AppLanguage.tr('មិនមានទិន្នន័យត្រូវបង្ហាញទេ', 'No data to display'),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filtered[index];

                      Color badgeColor;
                      Color badgeBg;
                      if (item.isPresent) {
                        badgeColor = const Color(0xFF16A34A);
                        badgeBg = const Color(0xFFF0FDF4);
                      } else if (item.isLate) {
                        badgeColor = const Color(0xFFD97706);
                        badgeBg = const Color(0xFFFFFBEB);
                      } else {
                        badgeColor = const Color(0xFFDC2626);
                        badgeBg = const Color(0xFFFEF2F2);
                      }

                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showEditStatusModal(item),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.35),
                                  child: Text(
                                    item.studentName.isNotEmpty ? item.studentName[0] : 'S',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.studentName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.studentCode} · ${item.note ?? AppLanguage.tr("វត្តមាន", "Present")}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.statusText,
                                        style: TextStyle(
                                          color: badgeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.arrow_drop_down, color: badgeColor, size: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String count,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStatusFilter = value),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
