import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_language.dart';
import '../../models/attendance_model.dart';
import '../../services/attendance_service.dart';

/// អេក្រង់ប្រវត្តិវត្តមានសិស្ស (Tab 2: ប្រវត្តិ)
/// គាំទ្រទាំង Light Mode និង Dark Mode យ៉ាងពេញលេញ
class StudentHistoryScreen extends StatefulWidget {
  const StudentHistoryScreen({super.key});

  @override
  State<StudentHistoryScreen> createState() => _StudentHistoryScreenState();
}

class _StudentHistoryScreenState extends State<StudentHistoryScreen> {
  List<AttendanceModel> _attendances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  // ទាញយកប្រវត្តិវត្តមានពី Backend API / Database
  Future<void> _loadAttendances() async {
    setState(() => _isLoading = true);
    final history = await AttendanceService.getMyAttendanceHistory();
    if (mounted) {
      setState(() {
        _attendances = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.border;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header ចំណងជើង និងប៊ូតុង Refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLanguage.tr('ប្រវត្តិវត្តមានទាំងអស់', 'All Attendance History'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textCol,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                tooltip: AppLanguage.tr('ទាញយកទិន្នន័យឡើងវិញ', 'Refresh'),
                onPressed: _loadAttendances,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // បង្ហាញ Loading ឬ បញ្ជីវត្តមាន
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAttendances,
                    color: AppColors.primary,
                    child: _attendances.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history_rounded,
                                      size: 56,
                                      color: subTextCol.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppLanguage.tr(
                                        'មិនទាន់មានប្រវត្តិវត្តមាននៅឡើយទេ',
                                        'No attendance history yet',
                                      ),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: subTextCol,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _attendances.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                            final item = _attendances[index];

                            // ពណ៌ Badge តាមស្ថានភាពវត្តមាន
                            Color badgeColor;
                            if (item.isPresent) {
                              badgeColor = AppColors.success;
                            } else if (item.isLate) {
                              badgeColor = AppColors.warning;
                            } else {
                              badgeColor = AppColors.error;
                            }

                            // ឈ្មោះមុខវិជ្ជា ឬ Note
                            final title = item.subjectName != null &&
                                    item.subjectName!.isNotEmpty
                                ? item.subjectName!
                                : (item.note ??
                                    AppLanguage.tr('វត្តមាន', 'Attendance'));

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderCol),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                        alpha: isDark ? 0.2 : 0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: textCol,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${AppLanguage.tr('កាលបរិច្ឆេទ៖ ', 'Date: ')}${item.date}',
                                          style: TextStyle(
                                            color: subTextCol,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(
                                          alpha: isDark ? 0.22 : 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: badgeColor.withValues(
                                            alpha: isDark ? 0.4 : 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      item.statusText,
                                      style: TextStyle(
                                        color: badgeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
