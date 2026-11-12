import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_language.dart';
import '../../models/user_model.dart';
import '../../models/class_model.dart';
import '../../models/attendance_model.dart';
import '../lecturer/class_detail_screen.dart';

/// អេក្រង់ទំព័រដើមសិស្ស (Tab 1: ដើម)
/// គាំទ្រទាំង Light Mode និង Dark Mode យ៉ាងពេញលេញ
class StudentDashboardScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                      (student.department != null && student.department!.isNotEmpty)
                          ? student.department!
                          : AppLanguage.tr('ថ្ងៃព្រហស្បតិ៍ 15 តុលា 2026', 'Thursday, Oct 15, 2026'),
                      style: TextStyle(
                        fontSize: 14,
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
              onPressed: onScanQr,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: AppColors.primary.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_rounded, size: 26, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    AppLanguage.tr('ស្កេនវត្តមាន', 'Scan Attendance'),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- 3. Monthly Attendance Summary (វត្តមានខែនេះ) ---
          Text(
            AppLanguage.tr('វត្តមានខែនេះ', 'Monthly Attendance'),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textCol,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // មក (Present)
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

          const SizedBox(height: 28),

          // --- 4. My Classes (ថ្នាក់របស់ខ្ញុំ) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLanguage.tr('ថ្នាក់របស់ខ្ញុំ', 'My Classes'),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textCol,
                ),
              ),
              if (student.department != null && student.department!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    student.department!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (isLoading && classes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
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
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: classes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
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

    if (onRefresh != null) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: onRefresh!,
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

  // Card ថ្នាក់រៀន
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
    final badgeBg = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

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
                  Text(
                    c.subjectName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${c.lecturerName ?? AppLanguage.tr('គ្រូបង្រៀន', 'Lecturer')} · ${c.dayOfWeek} ${c.time}',
                    style: TextStyle(
                      fontSize: 13,
                      color: subTextCol,
                      fontWeight: FontWeight.w500,
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
              ),
              child: Text(
                c.room.isNotEmpty ? c.room : '-',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: subTextCol,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
