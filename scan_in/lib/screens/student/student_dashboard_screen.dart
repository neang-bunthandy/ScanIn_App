import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_language.dart';
import '../../core/app_datetime.dart';
import '../../models/user_model.dart';
import '../../models/class_model.dart';
import '../../models/attendance_model.dart';
import '../../widgets/week_day_strip.dart';
import '../lecturer/class_detail_screen.dart';

/// អេក្រង់ទំព័រដើមសិស្ស (Tab 1: ដើម)
/// គាំទ្រទាំង Light Mode និង Dark Mode យ៉ាងពេញលេញ
/// បំពាក់ WeekDayStrip (ជម្រើសទី ២) សម្រាប់រើសថ្ងៃ និងមើលកាលវិភាគជាក់ស្តែង
class StudentDashboardScreen extends StatefulWidget {
  final UserModel student;
  final List<ClassModel> classes;
  final List<AttendanceModel> attendances;
  final bool isLoading;
  final VoidCallback onScanQr;
  final Future<void> Function()? onRefresh;

  const StudentDashboardScreen({
    super.key,
    required this.student,
    required this.classes,
    this.attendances = const [],
    this.isLoading = false,
    required this.onScanQr,
    this.onRefresh,
  });

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  late DateTime _selectedDate;
  bool _showAllClasses = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final classes = widget.classes;
    final attendances = widget.attendances;
    final isLoading = widget.isLoading;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.border;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final avatarBg = isDark ? const Color(0xFF334155) : AppColors.primaryLight;

    // គណនាស្ថិតិវត្តមានជាក់ស្តែងពី Database (MySQL)
    final presentCount = attendances.where((a) => a.isPresent).length;
    final lateCount = attendances.where((a) => a.isLate).length;
    final absentCount = attendances.where((a) => a.isAbsent).length;

    // ច្រោះយកថ្នាក់រៀនតាមថ្ងៃដែលបានជ្រើសរើស (Filter by Selected Day)
    final dayClasses = classes.where((c) {
      return AppDateTime.matchesClassSchedule(c.dayOfWeek, c.classDate, _selectedDate);
    }).toList();
    final displayClasses = _showAllClasses ? classes : dayClasses;

    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Header (សួស្តី & កាលបរិច្ឆេទ) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLanguage.tr('សួស្តី, ', 'Hello, ')}${student.name} 👋',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textCol,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (student.department != null && student.department!.isNotEmpty) student.department!,
                        if (student.yearLevel != null) 'ឆ្នាំទី ${student.yearLevel}',
                        if (student.generation != null && student.generation!.isNotEmpty) student.generation!,
                      ].isNotEmpty
                          ? [
                              if (student.department != null && student.department!.isNotEmpty) student.department!,
                              if (student.yearLevel != null) 'ឆ្នាំទី ${student.yearLevel}',
                              if (student.generation != null && student.generation!.isNotEmpty) student.generation!,
                            ].join(' · ')
                          : AppDateTime.formatHeaderDate(DateTime.now()),
                      style: TextStyle(
                        fontSize: 13.5,
                        color: subTextCol,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: avatarBg,
                child: Text(
                  student.name.isNotEmpty ? student.name.substring(0, 1) : 'S',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- 2. Big Action Button (📷 ស្កេនវត្តមាន) ---
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: widget.onScanQr,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: AppColors.primary.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_rounded, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    AppLanguage.tr('ស្កេនវត្តមាន', 'Scan Attendance'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- 3. Quick Stats (វត្តមានខែនេះ) ---
          Text(
            AppLanguage.tr('វត្តមានខែនេះ៖', 'This Month\'s Attendance:'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textCol,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // វត្តមាន (Present)
              Expanded(
                child: _buildStatCard(
                  count: '$presentCount',
                  label: AppLanguage.tr('មក', 'Present'),
                  bgColor: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.15) : const Color(0xFFF0FDF4),
                  borderColor: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.35) : const Color(0xFFBBF7D0),
                  textColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),

              // យឺត (Late)
              Expanded(
                child: _buildStatCard(
                  count: '$lateCount',
                  label: AppLanguage.tr('យឺត', 'Late'),
                  bgColor: isDark ? const Color(0xFFD97706).withValues(alpha: 0.15) : const Color(0xFFFFFBEB),
                  borderColor: isDark ? const Color(0xFFD97706).withValues(alpha: 0.35) : const Color(0xFFFDE68A),
                  textColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 12),

              // អវត្តមាន (Absent)
              Expanded(
                child: _buildStatCard(
                  count: '$absentCount',
                  label: AppLanguage.tr('អវត្តមាន', 'Absent'),
                  bgColor: isDark ? const Color(0xFFDC2626).withValues(alpha: 0.15) : const Color(0xFFFEF2F2),
                  borderColor: isDark ? const Color(0xFFDC2626).withValues(alpha: 0.35) : const Color(0xFFFECACA),
                  textColor: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- 3.5. របាររើសថ្ងៃ Week Day Strip (ជម្រើសទី ២ ទំនើប) ---
          WeekDayStrip(
            selectedDate: _selectedDate,
            classes: classes,
            onSelectDate: (d) {
              setState(() {
                _selectedDate = d;
                _showAllClasses = false;
              });
            },
            onResetToToday: () {
              setState(() {
                _selectedDate = DateTime.now();
                _showAllClasses = false;
              });
            },
          ),

          const SizedBox(height: 24),

          // --- 4. My Classes (ថ្នាក់របស់ខ្ញុំ) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _showAllClasses
                        ? AppLanguage.tr('ថ្នាក់ទាំងអស់', 'All Classes')
                        : AppLanguage.tr('ថ្នាក់រៀនតាមថ្ងៃ', 'Classes by Day'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textCol,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${displayClasses.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              if (classes.isNotEmpty)
                InkWell(
                  onTap: () => setState(() => _showAllClasses = !_showAllClasses),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _showAllClasses
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _showAllClasses
                            ? AppColors.primary
                            : subTextCol.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showAllClasses ? Icons.calendar_today_rounded : Icons.list_alt_rounded,
                          size: 13,
                          color: _showAllClasses ? AppColors.primary : subTextCol,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _showAllClasses
                              ? AppLanguage.tr('មើលតាមថ្ងៃ', 'Filter by Day')
                              : AppLanguage.tr('មើលទាំងអស់ (${classes.length})', 'View All (${classes.length})'),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _showAllClasses ? AppColors.primary : subTextCol,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (isLoading && classes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (classes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  Icon(Icons.class_outlined, size: 38, color: subTextCol),
                  const SizedBox(height: 10),
                  Text(
                    AppLanguage.tr(
                      'មិនទាន់មានថ្នាក់រៀនក្នុងដេប៉ាតឺម៉ង់របស់អ្នកនៅឡើយទេ',
                      'No classes found for your department yet',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: subTextCol, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          else if (displayClasses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.event_busy_rounded, size: 26, color: subTextCol),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLanguage.tr(
                      'គ្មានថ្នាក់រៀនសម្រាប់ ${AppDateTime.formatTimetableDate(_selectedDate)} ទេ',
                      'No classes scheduled for ${AppDateTime.formatTimetableDate(_selectedDate)}',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, color: textCol, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {
                      // រកមើលថ្នាក់បន្ទាប់ដែលជិតបំផុត
                      for (int i = 0; i < 14; i++) {
                        final checkDate = DateTime.now().add(Duration(days: i));
                        if (classes.any((c) => AppDateTime.matchesClassSchedule(c.dayOfWeek, c.classDate, checkDate))) {
                          setState(() {
                            _selectedDate = checkDate;
                            _showAllClasses = false;
                          });
                          break;
                        }
                      }
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                    label: Text(
                      AppLanguage.tr('មើលថ្នាក់រៀនបន្ទាប់ ➔', 'View upcoming class ➔'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayClasses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = displayClasses[index];
                return _buildClassCard(
                  context,
                  c,
                  cardBg: cardBg,
                  borderCol: borderCol,
                  textCol: textCol,
                  subTextCol: subTextCol,
                  isDark: isDark,
                );
              },
            ),
        ],
      ),
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: widget.onRefresh!,
        child: content,
      );
    }
    return content;
  }

  // Card សង្ខេបវត្តមាន
  Widget _buildStatCard({
    required String count,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Card ថ្នាក់រៀនទំនើប (មានកាលបរិច្ឆេទ Session និង Smart Status Badge)
  Widget _buildClassCard(
    BuildContext context,
    ClassModel c, {
    required Color cardBg,
    required Color borderCol,
    required Color textCol,
    required Color subTextCol,
    required bool isDark,
  }) {
    final iconBg = isDark ? const Color(0xFF334155) : AppColors.primaryLight.withValues(alpha: 0.35);

    // គណនាកាលបរិច្ឆេទ Session ជាក់លាក់
    final String sessionDateText = c.classDate != null && c.classDate!.isNotEmpty
        ? AppDateTime.formatSessionDate(DateTime.tryParse(c.classDate!) ?? _selectedDate)
        : (c.dayOfWeek.isNotEmpty ? c.dayOfWeek : AppDateTime.dayOfWeek(_selectedDate));

    // Smart Status Badge
    final att = widget.attendances.where((a) => a.classId == c.id).firstOrNull;
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final isFuture = targetDate.isAfter(todayDate);
    final isPast = targetDate.isBefore(todayDate);

    Widget statusBadge;
    if (att != null && att.isPresent) {
      statusBadge = _buildBadge(
        label: AppLanguage.tr('វត្តមាន', 'Present'),
        color: const Color(0xFF16A34A),
        bgColor: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.15) : const Color(0xFFDCFCE7),
      );
    } else if (att != null && att.isLate) {
      statusBadge = _buildBadge(
        label: AppLanguage.tr('យឺត', 'Late'),
        color: const Color(0xFFD97706),
        bgColor: isDark ? const Color(0xFFD97706).withValues(alpha: 0.15) : const Color(0xFFFEF3C7),
      );
    } else if (isFuture) {
      statusBadge = _buildBadge(
        label: AppLanguage.tr('មិនទាន់ដល់ថ្ងៃ', 'Upcoming'),
        color: const Color(0xFF0284C7),
        bgColor: isDark ? const Color(0xFF0284C7).withValues(alpha: 0.15) : const Color(0xFFE0F2FE),
      );
    } else if (isPast) {
      statusBadge = _buildBadge(
        label: AppLanguage.tr('អវត្តមាន', 'Absent'),
        color: const Color(0xFFDC2626),
        bgColor: isDark ? const Color(0xFFDC2626).withValues(alpha: 0.15) : const Color(0xFFFEE2E2),
      );
    } else {
      statusBadge = _buildBadge(
        label: AppLanguage.tr('មិនទាន់ស្កេន', 'Not Scanned'),
        color: const Color(0xFF7C3AED),
        bgColor: isDark ? const Color(0xFF7C3AED).withValues(alpha: 0.15) : const Color(0xFFEDE9FE),
      );
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassDetailScreen(classModel: c, isStudentView: true),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ឈ្មោះមុខវិជ្ជា
                  Text(
                    c.subjectName,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ម៉ោង និងកាលបរិច្ឆេទ Session
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFF16A34A)),
                            const SizedBox(width: 4),
                            Text(
                              c.time,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          sessionDateText,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: subTextCol,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // គ្រូបង្រៀន, បន្ទប់ & Status Badge
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 13, color: subTextCol),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          c.lecturerName ?? AppLanguage.tr('គ្រូបង្រៀន', 'Lecturer'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.5, color: subTextCol),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c.room.isNotEmpty ? c.room : '-',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subTextCol,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      statusBadge,
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
