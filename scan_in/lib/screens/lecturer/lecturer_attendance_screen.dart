import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/attendance_model.dart';
import '../../models/class_model.dart';
import 'attendance_list_screen.dart';

/// អេក្រង់គ្រប់គ្រងវត្តមានរបស់គ្រូ (Tab 2: វត្តមាន)
/// គាំទ្រទាំង Light Mode និង Dark Mode យ៉ាងពេញលេញ
class LecturerAttendanceScreen extends StatefulWidget {
  final List<ClassModel> classes;
  final List<AttendanceModel> attendanceRecords;
  final Function(AttendanceModel, String) onUpdateAttendanceStatus;

  const LecturerAttendanceScreen({
    super.key,
    required this.classes,
    required this.attendanceRecords,
    required this.onUpdateAttendanceStatus,
  });

  @override
  State<LecturerAttendanceScreen> createState() => _LecturerAttendanceScreenState();
}

class _LecturerAttendanceScreenState extends State<LecturerAttendanceScreen> {
  int? _selectedClassFilterId;
  String _searchQuery = '';

  void _showEditStudentAttendanceModal(AttendanceModel item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
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
                      color: isDark ? const Color(0xFF475569) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'កែប្រែវត្តមាន: ${item.studentName}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textCol,
                  ),
                ),
                Text(
                  'អត្តលេខ៖ ${item.studentCode}',
                  style: TextStyle(fontSize: 13, color: subTextCol),
                ),
                const SizedBox(height: 20),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
                    title: Text('វត្តមាន (Present)', style: TextStyle(fontWeight: FontWeight.w600, color: textCol)),
                    trailing: item.isPresent ? const Icon(Icons.done, color: Color(0xFF16A34A)) : null,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onUpdateAttendanceStatus(item, 'present');
                    },
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.access_time_filled_rounded, color: Color(0xFFD97706)),
                    title: Text('មកយឺត (Late)', style: TextStyle(fontWeight: FontWeight.w600, color: textCol)),
                    trailing: item.isLate ? const Icon(Icons.done, color: Color(0xFFD97706)) : null,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onUpdateAttendanceStatus(item, 'late');
                    },
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626)),
                    title: Text('អវត្តមាន (Absent)', style: TextStyle(fontWeight: FontWeight.w600, color: textCol)),
                    trailing: item.isAbsent ? const Icon(Icons.done, color: Color(0xFFDC2626)) : null,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onUpdateAttendanceStatus(item, 'absent');
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.border;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    // Filter attendance records
    var filteredList = widget.attendanceRecords;
    if (_selectedClassFilterId != null) {
      filteredList = filteredList.where((a) => a.classId == _selectedClassFilterId).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      filteredList = filteredList.where((a) {
        final q = _searchQuery.toLowerCase();
        return a.studentName.toLowerCase().contains(q) ||
            a.studentCode.toLowerCase().contains(q) ||
            (a.note?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'របាយការណ៍វត្តមាន',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textCol,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'មើលបញ្ជីពេញលេញ',
                    onPressed: () {
                      final selectedClass = _selectedClassFilterId != null
                          ? widget.classes.firstWhere(
                              (c) => c.id == _selectedClassFilterId,
                              orElse: () => widget.classes.first,
                            )
                          : null;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceListScreen(classModel: selectedClass),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded, color: AppColors.primary),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.download_done_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text('បានទាញយករបាយការណ៍ Excel រួចរាល់'),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                    tooltip: 'ទាញយក Excel',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Search Field
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: TextStyle(color: textCol),
            decoration: InputDecoration(
              hintText: 'ស្វែងរកសិស្ស ឬអត្តលេខ...',
              hintStyle: TextStyle(color: subTextCol),
              prefixIcon: Icon(Icons.search_rounded, color: subTextCol),
              filled: true,
              fillColor: cardBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderCol),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderCol),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'ទាំងអស់',
                  isSelected: _selectedClassFilterId == null,
                  onSelected: () => setState(() => _selectedClassFilterId = null),
                  cardBg: cardBg,
                  borderCol: borderCol,
                  textCol: textCol,
                ),
                const SizedBox(width: 8),
                for (var c in widget.classes) ...[
                  _buildFilterChip(
                    label: c.subjectName,
                    isSelected: _selectedClassFilterId == c.id,
                    onSelected: () => setState(() => _selectedClassFilterId = c.id),
                    cardBg: cardBg,
                    borderCol: borderCol,
                    textCol: textCol,
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Attendance Records List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_late_outlined, size: 48, color: isDark ? const Color(0xFF475569) : Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'មិនមានទិន្នន័យវត្តមានទេ',
                          style: TextStyle(color: subTextCol, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];

                      Color badgeColor;
                      Color badgeBg;
                      if (item.isPresent) {
                        badgeColor = const Color(0xFF16A34A);
                        badgeBg = isDark ? const Color(0xFF16A34A).withValues(alpha: 0.2) : const Color(0xFFF0FDF4);
                      } else if (item.isLate) {
                        badgeColor = const Color(0xFFD97706);
                        badgeBg = isDark ? const Color(0xFFD97706).withValues(alpha: 0.2) : const Color(0xFFFFFBEB);
                      } else {
                        badgeColor = const Color(0xFFDC2626);
                        badgeBg = isDark ? const Color(0xFFDC2626).withValues(alpha: 0.2) : const Color(0xFFFEF2F2);
                      }

                      return Material(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _showEditStudentAttendanceModal(item),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderCol),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primaryLight.withValues(alpha: isDark ? 0.2 : 0.35),
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
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: textCol,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.studentCode} · ${item.note ?? 'វត្តមាន'}',
                                        style: TextStyle(
                                          color: subTextCol,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: badgeColor.withValues(alpha: isDark ? 0.4 : 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.statusKhmer,
                                        style: TextStyle(
                                          color: badgeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required Color cardBg,
    required Color borderCol,
    required Color textCol,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary,
      backgroundColor: cardBg,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : textCol,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : borderCol,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
