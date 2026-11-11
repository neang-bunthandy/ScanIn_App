import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_routes.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';
import '../services/attendance_service.dart';
import 'admin_scaffold.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<ClassModel> _classes = [];
  int _totalAttendances = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final cached = ClassService.cachedClasses;
    if (cached != null && cached.isNotEmpty) {
      _classes = cached;
      _isLoading = false;
      _loadData(silent: true);
    } else {
      _loadData();
    }
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    final classes = await ClassService.getStudentClasses();
    int attCount = 0;
    for (final c in classes) {
      final atts = await AttendanceService.getClassAttendances(c.id);
      attCount += atts.length;
    }

    if (mounted) {
      setState(() {
        _classes = classes;
        _totalAttendances = attCount;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    final activeQrCount = _classes.where((c) => c.isQrActive).length;

    return AdminScaffold(
      title: AppLanguage.tr('ទំព័រដើម (Dashboard)', 'Dashboard'),
      currentRoute: AppRoutes.dashboard,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 16 : 32),
                children: [
                  // Stat Cards Grid (Responsive)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 750;
                      final card1 = _buildStatCard(
                        icon: Icons.class_outlined,
                        label: AppLanguage.tr('ថ្នាក់រៀនសរុប', 'Total Classes'),
                        count: '${_classes.length}',
                        color: const Color(0xFF4F46E5),
                        bgColor: const Color(0xFFEEF2FF),
                      );
                      final card2 = _buildStatCard(
                        icon: Icons.qr_code_scanner_rounded,
                        label: AppLanguage.tr('QR កំពុងបើក', 'Active QR'),
                        count: '$activeQrCount',
                        color: const Color(0xFF16A34A),
                        bgColor: const Color(0xFFDCFCE7),
                      );
                      final card3 = _buildStatCard(
                        icon: Icons.fact_check_outlined,
                        label: AppLanguage.tr('កំណត់ត្រាវត្តមាន', 'Total Attendances'),
                        count: '$_totalAttendances',
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFEF3C7),
                      );

                      if (isNarrow) {
                        return Column(
                          children: [
                            card1,
                            const SizedBox(height: 12),
                            card2,
                            const SizedBox(height: 12),
                            card3,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: card1),
                          const SizedBox(width: 20),
                          Expanded(child: card2),
                          const SizedBox(width: 20),
                          Expanded(child: card3),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Classes Card Table
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
                                child: Text(
                                  AppLanguage.tr('បញ្ជីថ្នាក់រៀនក្នុងប្រព័ន្ធ', 'System Classes Overview'),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textCol),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.classes),
                                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                label: Text(AppLanguage.tr('មើលទាំងអស់', 'View All')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        if (_classes.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                AppLanguage.tr('មិនទាន់មានថ្នាក់រៀនទេ', 'No classes registered yet'),
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
                                      DataColumn(label: Text(AppLanguage.tr('កូដ', 'Code'))),
                                      DataColumn(label: Text(AppLanguage.tr('មុខវិជ្ជា', 'Subject'))),
                                      DataColumn(label: Text(AppLanguage.tr('បន្ទប់', 'Room'))),
                                      DataColumn(label: Text(AppLanguage.tr('កាលវិភាគ', 'Schedule'))),
                                      DataColumn(label: Text(AppLanguage.tr('ស្ថានភាព QR', 'QR Status'))),
                                    ],
                                    rows: _classes.take(5).map((c) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(c.subjectCode, style: const TextStyle(fontWeight: FontWeight.bold))),
                                          DataCell(Text(c.subjectName)),
                                          DataCell(Text(c.room.isNotEmpty ? c.room : '-')),
                                          DataCell(Text('${c.dayOfWeek} (${c.time})')),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: c.isQrActive
                                                    ? const Color(0xFF16A34A).withValues(alpha: 0.15)
                                                    : const Color(0xFFDC2626).withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                c.isQrActive
                                                    ? AppLanguage.tr('● កំពុងបើក', '● Active')
                                                    : AppLanguage.tr('○ បានបិទ', '○ Closed'),
                                                style: TextStyle(
                                                  color: c.isQrActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
    required Color bgColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? color.withValues(alpha: 0.2) : bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textCol),
              ),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 13, color: subTextCol)),
            ],
          ),
        ],
      ),
    );
  }
}
