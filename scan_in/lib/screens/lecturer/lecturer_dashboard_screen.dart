import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_language.dart';
import '../../data/mock_data.dart';
import '../../models/class_model.dart';
import '../../models/user_model.dart';
import 'class_detail_screen.dart';
import 'show_qr_screen.dart';
import 'attendance_list_screen.dart';

/// អេក្រង់ទំព័រដើមរបស់គ្រូ (Tab 1: ដើម)
/// គាំទ្រទាំង Light Mode និង Dark Mode យ៉ាងពេញលេញ
class LecturerDashboardScreen extends StatelessWidget {
  final UserModel lecturer;
  final List<ClassModel> classes;
  final Map<int, bool> classQrActive;
  final Function(ClassModel) onShowQr;
  final Function(ClassModel) onToggleQr;
  final Function({ClassModel? initialClass}) onNavigateToCreateClass;
  final Function(ClassModel) onConfirmDeleteClass;
  final VoidCallback onGoToAttendanceTab;

  const LecturerDashboardScreen({
    super.key,
    required this.lecturer,
    required this.classes,
    required this.classQrActive,
    required this.onShowQr,
    required this.onToggleQr,
    required this.onNavigateToCreateClass,
    required this.onConfirmDeleteClass,
    required this.onGoToAttendanceTab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.border;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final avatarBg = isDark ? const Color(0xFF334155) : AppColors.primaryLight;

    // ថ្នាក់ដែលត្រូវបង្ហាញ QR លំនាំដើម
    final defaultClass = classes.firstWhere(
      (c) => (classQrActive[c.id] ?? false),
      orElse: () => classes.isNotEmpty ? classes.first : MockData.sampleClasses.first,
    );

    // គណនាស្ថិតិរួម ដោយប្រើ Loop សាមញ្ញ ងាយស្រួលពន្យល់
    int totalStudents = 0;
    for (var c in classes) {
      totalStudents += c.studentCount;
    }

    int activeQrCount = 0;
    for (var active in classQrActive.values) {
      if (active) activeQrCount++;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Header (សួស្តី & តួនាទី) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLanguage.tr('សួស្តី, លោកគ្រូ ', 'Hello, Lecturer ')}${lecturer.name} 👋',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textCol,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppLanguage.tr('ថ្ងៃព្រហស្បតិ៍ 15 តុលា 2026', 'Thursday, Oct 15, 2026')} • ${lecturer.department ?? AppLanguage.tr('ដេប៉ាតឺម៉ង់ IT', 'IT Department')}',
                      style: TextStyle(
                        fontSize: 13,
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
                  lecturer.name.isNotEmpty ? lecturer.name.substring(0, 1) : 'L',
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

          // --- 2. Big Action Button (📱 បង្ហាញ QR កត់វត្តមាន) ---
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
                onTap: () => onShowQr(defaultClass),
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

          // --- 3. Teaching Summary Cards (ស្ថិតិបង្រៀន) ---
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
              // ថ្នាក់បង្រៀន (Classes)
              Expanded(
                child: _buildStatCard(
                  count: '${classes.length}',
                  label: AppLanguage.tr('ថ្នាក់បង្រៀន', 'Classes'),
                  bgColor: isDark ? const Color(0xFF1D4ED8).withValues(alpha: 0.15) : const Color(0xFFEFF6FF),
                  borderColor: isDark ? const Color(0xFF1D4ED8).withValues(alpha: 0.35) : const Color(0xFFBFDBFE),
                  textColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                ),
              ),
              const SizedBox(width: 12),

              // សិស្សសរុប (Total Students)
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

              // វត្តមានមធ្យម (Avg Attendance) - Clickable to go to Attendance tab
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: onGoToAttendanceTab,
                    child: _buildStatCard(
                      count: '94%',
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

          const SizedBox(height: 28),

          // --- 4. Teaching Classes Section Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppLanguage.tr('ថ្នាក់បង្រៀនរបស់ខ្ញុំ', 'My Teaching Classes')} (${classes.length})',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textCol,
                ),
              ),
              TextButton.icon(
                onPressed: () => onNavigateToCreateClass(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(AppLanguage.tr('បង្កើតថ្នាក់', 'Add Class')),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // --- 5. Class Cards List ---
          if (classes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36.0),
                child: Column(
                  children: [
                    Icon(Icons.school_outlined, size: 54, color: isDark ? const Color(0xFF475569) : Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      AppLanguage.tr('លោកគ្រូមិនទាន់មានថ្នាក់បង្រៀននៅឡើយទេ', 'No teaching classes available yet'),
                      style: TextStyle(color: subTextCol, fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => onNavigateToCreateClass(),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(AppLanguage.tr('បង្កើតថ្នាក់ដំបូង', 'Create First Class')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: classes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final c = classes[index];
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
  }

  // Stat Card Widget
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

  // Class Card Widget for Lecturer
  Widget _buildClassCard(
    BuildContext context,
    ClassModel c, {
    required Color cardBg,
    required Color borderCol,
    required Color textCol,
    required Color subTextCol,
    required bool isDark,
  }) {
    final isQrActive = classQrActive[c.id] ?? false;
    final progress = c.completedSessions / (c.totalSessions > 0 ? c.totalSessions : 1);
    final badgeCodeBg = isDark ? const Color(0xFF334155) : AppColors.primaryLight.withValues(alpha: 0.35);

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
            // Top Row: Subject Code & Name + QR Status + More Options
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

                // QR Status Chip
                Container(
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

                // Popup Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 20, color: subTextCol),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (val) {
                    if (val == 'fullscreen_qr') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowQrScreen(classModel: c),
                        ),
                      );
                    } else if (val == 'attendance_list') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceListScreen(classModel: c),
                        ),
                      );
                    } else if (val == 'edit') {
                      onNavigateToCreateClass(initialClass: c);
                    } else if (val == 'delete') {
                      onConfirmDeleteClass(c);
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
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: textCol),
                          const SizedBox(width: 8),
                          Text(AppLanguage.tr('កែប្រែព័ត៌មានថ្នាក់', 'Edit Class Info')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text(AppLanguage.tr('លុបថ្នាក់នេះ', 'Delete this class'), style: const TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Class Schedule & Room Info
            Row(
              children: [
                Icon(Icons.room_outlined, size: 16, color: subTextCol),
                const SizedBox(width: 4),
                Text(
                  c.room,
                  style: TextStyle(fontSize: 13, color: subTextCol),
                ),
                const SizedBox(width: 14),
                Icon(Icons.access_time_rounded, size: 16, color: subTextCol),
                const SizedBox(width: 4),
                Text(
                  '${c.dayOfWeek} ${c.time}',
                  style: TextStyle(fontSize: 13, color: subTextCol),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress & Student Count
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

            // Card Bottom Actions
            Row(
              children: [
                // Button 1: បង្ហាញ QR Code
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onShowQr(c),
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

                // Button 2: ព័ត៌មានលម្អិត & សិស្ស
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
