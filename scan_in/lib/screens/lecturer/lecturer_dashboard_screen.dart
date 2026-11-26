// Lecturer home dashboard and teaching statistics.
import 'package:flutter/material.dart';
import '../../core/api_config.dart';
import '../../core/app_colors.dart';
import '../../core/app_language.dart';
import '../../core/app_datetime.dart';
import '../../models/class_model.dart';
import '../../models/user_model.dart';
import '../../models/attendance_model.dart';
import '../../widgets/week_day_strip.dart';
import 'class_detail_screen.dart';
import 'show_qr_screen.dart';
import 'attendance_list_screen.dart';

class LecturerDashboardScreen extends StatefulWidget {
  final UserModel lecturer;
  final List<ClassModel> classes;
  final List<AttendanceModel> attendances;
  final Map<int, bool> classQrActive;
  final Function(ClassModel) onShowQr;
  final Function(ClassModel) onToggleQr;
  final VoidCallback onGoToAttendanceTab;
  final VoidCallback? onGoToProfileTab;
  final Future<void> Function()? onRefresh;

  const LecturerDashboardScreen({
    super.key,
    required this.lecturer,
    required this.classes,
    this.attendances = const [],
    required this.classQrActive,
    required this.onShowQr,
    required this.onToggleQr,
    required this.onGoToAttendanceTab,
    this.onGoToProfileTab,
    this.onRefresh,
  });

  @override
  State<LecturerDashboardScreen> createState() => _LecturerDashboardScreenState();
}

class _LecturerDashboardScreenState extends State<LecturerDashboardScreen> {
  late DateTime _selectedDate;
  bool _showAllClasses = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final lecturer = widget.lecturer;
    final classes = widget.classes;
    final attendances = widget.attendances;
    final classQrActive = widget.classQrActive;
    final onShowQr = widget.onShowQr;
    final onGoToAttendanceTab = widget.onGoToAttendanceTab;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.border;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final avatarBg = isDark ? const Color(0xFF334155) : AppColors.primaryLight;

    final ClassModel? defaultClass = classes.isEmpty
        ? null
        : classes.firstWhere(
            (c) => (classQrActive[c.id] ?? false),
            orElse: () => classes.first,
          );

    final Set<String> uniqueCourseCodes = {};
    int totalStudents = 0;
    for (var c in classes) {
      final key = c.subjectCode.trim().isNotEmpty ? c.subjectCode.trim() : c.subjectName.trim();
      if (!uniqueCourseCodes.contains(key)) {
        uniqueCourseCodes.add(key);
        totalStudents += c.studentCount;
      }
    }
    final int uniqueClassesCount = uniqueCourseCodes.length;

    int activeQrCount = 0;
    for (var active in classQrActive.values) {
      if (active) activeQrCount++;
    }

    final int totalAttendances = attendances.length;
    final int presentAttendances = attendances.where((a) => a.isPresent || a.isLate).length;
    final String avgRateString = totalAttendances > 0
        ? '${((presentAttendances / totalAttendances) * 100).round()}%'
        : '0%';

    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      () {
                        final hasTitle = lecturer.name.startsWith('លោកគ្រូ') ||
                            lecturer.name.startsWith('អ្នកគ្រូ') ||
                            lecturer.name.startsWith('សាស') ||
                            lecturer.name.toLowerCase().startsWith('lecturer');
                        return hasTitle
                            ? '${AppLanguage.tr('សួស្តី, ', 'Hello, ')}${lecturer.name} 👋'
                            : '${AppLanguage.tr('សួស្តី, លោកគ្រូ ', 'Hello, Lecturer ')}${lecturer.name} 👋';
                      }(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textCol,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppDateTime.formatHeaderDate(DateTime.now())} • ${lecturer.department ?? AppLanguage.tr('ដេប៉ាតឺម៉ង់ IT', 'IT Department')}',
                      style: TextStyle(
                        fontSize: 13,
                        color: subTextCol,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: widget.onGoToProfileTab,
                borderRadius: BorderRadius.circular(24),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: avatarBg,
                  backgroundImage: lecturer.avatarUrl != null && lecturer.avatarUrl!.isNotEmpty
                      ? NetworkImage(ApiConfig.resolveImageUrl(lecturer.avatarUrl) ?? lecturer.avatarUrl!)
                      : null,
                  child: lecturer.avatarUrl == null || lecturer.avatarUrl!.isEmpty
                      ? Text(
                          lecturer.name.isNotEmpty ? lecturer.name.substring(0, 1) : 'L',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (defaultClass != null) {
                    onShowQr(defaultClass);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLanguage.tr(
                            'សាលាមិនទាន់បានចាត់តាំងថ្នាក់បង្រៀនជូនលោកគ្រូនៅឡើយទេ',
                            'No teaching classes assigned by Admin yet',
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLanguage.tr('បង្ហាញ QR កត់វត្តមាន', 'Show Attendance QR Code'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeQrCount > 0
                                  ? (AppLanguage.tr('កំពុងបើក QR សម្រាប់ $activeQrCount ថ្នាក់ (ចុចមើល)', 'Active QR for $activeQrCount classes (tap to view)'))
                                  : AppLanguage.tr('ចុចដើម្បីបង្ហាញ QR សម្រាប់និស្សិតស្កេន', 'Tap to show QR code for students to scan'),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            AppLanguage.tr('ស្ថិតិបង្រៀន', 'Teaching Statistics'),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textCol,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [

              Expanded(
                child: _buildStatCard(
                  count: '$uniqueClassesCount',
                  label: AppLanguage.tr('ថ្នាក់បង្រៀន', 'Classes'),
                  bgColor: isDark ? const Color(0xFF1D4ED8).withValues(alpha: 0.15) : const Color(0xFFEFF6FF),
                  borderColor: isDark ? const Color(0xFF1D4ED8).withValues(alpha: 0.35) : const Color(0xFFBFDBFE),
                  textColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: _buildStatCard(
                  count: '$totalStudents',
                  label: AppLanguage.tr('សិស្សសរុប', 'Total Students'),
                  bgColor: isDark ? const Color(0xFF7C3AED).withValues(alpha: 0.15) : const Color(0xFFF5F3FF),
                  borderColor: isDark ? const Color(0xFF7C3AED).withValues(alpha: 0.35) : const Color(0xFFDDD6FE),
                  textColor: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: onGoToAttendanceTab,
                    child: _buildStatCard(
                      count: avgRateString,
                      label: AppLanguage.tr('វត្តមានមធ្យម', 'Avg Attendance'),
                      bgColor: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.15) : const Color(0xFFF0FDF4),
                      borderColor: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.35) : const Color(0xFFBBF7D0),
                      textColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

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

          () {
            final dayClasses = classes.where((c) {
              return AppDateTime.matchesClassSchedule(c.dayOfWeek, c.classDate, _selectedDate);
            }).toList();
            final displayClasses = _showAllClasses ? classes : dayClasses;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          _showAllClasses
                              ? AppLanguage.tr('ថ្នាក់បង្រៀនទាំងអស់', 'All Teaching Classes')
                              : AppLanguage.tr('ថ្នាក់បង្រៀនតាមថ្ងៃ', 'Teaching Classes by Day'),
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

                if (classes.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36.0),
                      child: Column(
                        children: [
                          Icon(Icons.school_outlined, size: 54, color: isDark ? const Color(0xFF475569) : Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            AppLanguage.tr(
                              'សាលាមិនទាន់បានចាត់តាំងថ្នាក់បង្រៀនជូនលោកគ្រូនៅឡើយទេ',
                              'No teaching classes have been assigned by Admin yet',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: subTextCol, fontSize: 14),
                          ),
                        ],
                      ),
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
                            'គ្មានថ្នាក់បង្រៀនសម្រាប់ ${AppDateTime.formatTimetableDate(_selectedDate)} ទេ',
                            'No teaching classes scheduled for ${AppDateTime.formatTimetableDate(_selectedDate)}',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.5, color: textCol, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () {
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
                            AppLanguage.tr('មើលថ្នាក់បង្រៀនបន្ទាប់ ➔', 'View upcoming class ➔'),
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
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
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
            );
          }(),
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
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    ClassModel c, {
    required Color cardBg,
    required Color borderCol,
    required Color textCol,
    required Color subTextCol,
    required bool isDark,
  }) {
    final isQrActive = widget.classQrActive[c.id] ?? false;
    final progress = c.completedSessions / (c.totalSessions > 0 ? c.totalSessions : 1);
    final badgeCodeBg = isDark ? const Color(0xFF334155) : AppColors.primaryLight.withValues(alpha: 0.35);
    final String sessionDateText = c.classDate != null && c.classDate!.isNotEmpty
        ? AppDateTime.formatSessionDate(DateTime.tryParse(c.classDate!) ?? _selectedDate)
        : (c.dayOfWeek.isNotEmpty ? c.dayOfWeek : AppDateTime.dayOfWeek(_selectedDate));

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isQrActive ? AppColors.primary.withValues(alpha: isDark ? 0.7 : 0.5) : borderCol,
          width: isQrActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeCodeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    c.subjectCode,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.subjectName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                    ),
                  ),
                ),

                InkWell(
                  onTap: () => widget.onToggleQr(c),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isQrActive
                          ? (isDark ? const Color(0xFF16A34A).withValues(alpha: 0.2) : const Color(0xFFF0FDF4))
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isQrActive
                            ? (isDark ? const Color(0xFF16A34A).withValues(alpha: 0.4) : const Color(0xFFBBF7D0))
                            : (isDark ? const Color(0xFF475569) : Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 7,
                          color: isQrActive ? const Color(0xFF16A34A) : Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isQrActive ? AppLanguage.tr('បើក QR', 'Active QR') : AppLanguage.tr('បិទ QR', 'Inactive QR'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isQrActive ? const Color(0xFF16A34A) : subTextCol,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 20, color: subTextCol),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (val) {
                    if (val == 'fullscreen_qr') {
                      final activeClass = c.copyWith(isQrActive: isQrActive);
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowQrScreen(classModel: activeClass),
                        ),
                      ).then((result) {
                        if (result != null && result != isQrActive) {
                          widget.onToggleQr(c);
                        }
                      });
                    } else if (val == 'attendance_list') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceListScreen(classModel: c),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'fullscreen_qr',
                      child: Row(
                        children: [
                          const Icon(Icons.fullscreen_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(AppLanguage.tr('QR ពេញអេក្រង់ (Projector)', 'Projector Fullscreen QR')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'attendance_list',
                      child: Row(
                        children: [
                          const Icon(Icons.fact_check_rounded, size: 18, color: Color(0xFF0D9488)),
                          const SizedBox(width: 8),
                          Text(AppLanguage.tr('បញ្ជីវត្តមានថ្នាក់នេះ', 'Attendance for this class')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.room_outlined, size: 16, color: subTextCol),
                const SizedBox(width: 4),
                Text(
                  c.room,
                  style: TextStyle(fontSize: 13, color: subTextCol),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sessionDateText,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: subTextCol),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLanguage.tr('វគ្គសិក្សា', 'Sessions')} ${c.completedSessions}/${c.totalSessions} (${(progress * 100).toInt()}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextCol,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.people_outline_rounded, size: 15, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${c.studentCount} ${AppLanguage.tr('នាក់', 'students')}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 5,
              ),
            ),

            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onShowQr(c),
                    icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                    label: Text(AppLanguage.tr('បង្ហាញ QR', 'Show QR')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isQrActive ? AppColors.primary : const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClassDetailScreen(classModel: c),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text(AppLanguage.tr('មើលលម្អិត', 'View Details')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textCol,
                      side: BorderSide(color: borderCol),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
