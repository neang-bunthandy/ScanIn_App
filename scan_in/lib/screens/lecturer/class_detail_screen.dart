import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_language.dart';
import '../../data/mock_data.dart';
import '../../models/class_model.dart';
import '../../models/user_model.dart';

class ClassDetailScreen extends StatelessWidget {
  final ClassModel? classModel;

  const ClassDetailScreen({super.key, this.classModel});

  @override
  Widget build(BuildContext context) {
    // បើមិនបានបញ្ជូន classModel មកទេ យកថ្នាក់ទីមួយជាលំនាំដើម
    final c = classModel ?? MockData.sampleClasses.first;
    final List<UserModel> students = MockData.getStudentsForClass(c.id);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.border;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final appBarBg = isDark ? const Color(0xFF1E293B) : AppColors.primary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          AppLanguage.tr('ព័ត៌មានថ្នាក់រៀន', 'Class Details'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: appBarBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: isDark
            ? const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: Color(0xFF334155)),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ១. Header Card ព័ត៌មានមុខវិជ្ជា ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E3A8A), const Color(0xFF0F172A)]
                      : [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          c.subjectCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.isQrActive ? AppColors.success : Colors.white24,
                        ),
                        child: Text(
                          c.isQrActive
                              ? AppLanguage.tr('● QR កំពុងបើក', '● Active QR')
                              : AppLanguage.tr('○ QR បិទ', '○ Inactive QR'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    c.subjectName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${c.semester} · ${AppLanguage.tr('ឆ្នាំសិក្សា', 'Academic Year')} ${c.academicYear}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        '${AppLanguage.tr('គ្រូបង្រៀន៖ ', 'Lecturer: ')}${c.lecturerName ?? AppLanguage.tr("លោកគ្រូ", "Lecturer")}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        '${AppLanguage.tr('បន្ទប់៖ ', 'Room: ')}${c.room}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        '${c.dayOfWeek} ${c.time}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- ២. ស្ថិតិវគ្គសិក្សា (Sessions & Progress) ---
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    context: context,
                    title: AppLanguage.tr('សិស្សសរុប', 'Total Students'),
                    value: '${c.studentCount} ${AppLanguage.tr('នាក់', 'students')}',
                    icon: Icons.people_outline_rounded,
                    color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    context: context,
                    title: AppLanguage.tr('វគ្គសិក្សា', 'Sessions'),
                    value: '${c.completedSessions}/${c.totalSessions} ${AppLanguage.tr('សប្តាហ៍', 'weeks')}',
                    icon: Icons.calendar_today_rounded,
                    color: const Color(0xFF0D9488),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- ៣. ការពិពណ៌នាមុខវិជ្ជា (Description) ---
            if (c.description != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLanguage.tr('អំពីមុខវិជ្ជា', 'About Subject'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textCol,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: subTextCol,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // --- ៤. បញ្ជីឈ្មោះសិស្សក្នុងថ្នាក់ (Student Roster) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLanguage.tr('បញ្ជីឈ្មោះសិស្សក្នុងថ្នាក់', 'Student Class Roster'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textCol,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : AppColors.pillBg,
                    borderRadius: BorderRadius.circular(12),
                    border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                  ),
                  child: Text(
                    '${students.length} ${AppLanguage.tr('នាក់', 'students')}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final s = students[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isDark
                            ? const Color(0xFF334155)
                            : AppColors.primaryLight.withValues(alpha: 0.5),
                        child: Text(
                          s.name.substring(0, 1),
                          style: TextStyle(
                            color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textCol,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${s.studentCode ?? ""} · ${s.phone ?? ""}',
                              style: TextStyle(
                                fontSize: 13,
                                color: subTextCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.2) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.4) : const Color(0xFFBBF7D0),
                          ),
                        ),
                        child: Text(
                          AppLanguage.tr('សកម្ម', 'Active'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.border;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: subTextCol,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textCol,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
