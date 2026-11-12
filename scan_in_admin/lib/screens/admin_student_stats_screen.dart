import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_routes.dart';
import '../services/auth_service.dart';
import '../services/class_service.dart';
import 'admin_scaffold.dart';

class AdminStudentStatsScreen extends StatefulWidget {
  const AdminStudentStatsScreen({super.key});

  @override
  State<AdminStudentStatsScreen> createState() => _AdminStudentStatsScreenState();
}

class _AdminStudentStatsScreenState extends State<AdminStudentStatsScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  bool _accessDenied = false;

  String? _selectedIntakeYear;
  String? _selectedGeneration;
  String? _selectedDepartment;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final user = AuthService.cachedUser ?? await AuthService.getCurrentUser();
    if (user?.role == 'lecturer') {
      if (mounted) {
        setState(() {
          _accessDenied = true;
          _isLoading = false;
        });
      }
      return;
    }

    final data = await ClassService.getAdminStudentStats(
      intakeYear: _selectedIntakeYear,
      generation: _selectedGeneration,
      department: _selectedDepartment,
      status: _selectedStatus,
    );

    if (mounted) {
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    }
  }

  void _copyCsvReport() {
    if (_stats == null) return;
    final byYear = (_stats!['by_intake_year'] as List? ?? []);
    final depts = List<String>.from(_stats!['departments'] as List? ?? []);

    final header = [
      'Intake Year',
      'Generations',
      'Total',
      'Active',
      'Graduated',
      'Inactive',
      'Male',
      'Female',
      ...depts,
    ].join(',');

    final rows = byYear.map((raw) {
      final r = Map<String, dynamic>.from(raw as Map);
      final gens = (r['generations'] as List? ?? []).join(' / ');
      final deptMap = Map<String, dynamic>.from(r['departments'] as Map? ?? {});
      final deptCounts = depts.map((d) => '${deptMap[d] ?? 0}');
      return [
        '"${r['intake_year']}"',
        '"$gens"',
        '${r['total'] ?? 0}',
        '${r['active'] ?? 0}',
        '${r['graduated'] ?? 0}',
        '${r['inactive'] ?? 0}',
        '${r['male'] ?? 0}',
        '${r['female'] ?? 0}',
        ...deptCounts,
      ].join(',');
    });

    final csv = [header, ...rows].join('\n');
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLanguage.tr(
          'បានចម្លងរបាយការណ៍ CSV រួចរាល់! អាច Paste ចូល Excel បាន។',
          'CSV report copied to clipboard!',
        )),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    if (_accessDenied) {
      return AdminScaffold(
        title: AppLanguage.tr('ស្ថិតិនិស្សិត & ប្រវត្តិតាមឆ្នាំ', 'Student Yearly Statistics'),
        currentRoute: AppRoutes.studentStats,
        body: Center(
          child: Text(
            AppLanguage.tr(
              'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចមើលរបាយការណ៍នេះបាន។',
              'Only Administrators can access this report.',
            ),
            style: TextStyle(color: subTextCol, fontSize: 16),
          ),
        ),
      );
    }

    final summary = Map<String, dynamic>.from((_stats?['summary'] as Map?) ?? {});
    final byYear = List<Map<String, dynamic>>.from(
      (_stats?['by_intake_year'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    final byDept = List<Map<String, dynamic>>.from(
      (_stats?['by_department'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    final byGen = List<Map<String, dynamic>>.from(
      (_stats?['by_generation'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    final pivotDepts = List<String>.from(_stats?['departments'] as List? ?? []);

    final filters = Map<String, dynamic>.from((_stats?['filters'] as Map?) ?? {});
    final yearOptions = List<String>.from(filters['intake_years'] as List? ?? []);
    final deptOptions = List<String>.from(filters['departments'] as List? ?? []);
    final genOptions = List<String>.from(filters['generations'] as List? ?? []);

    return AdminScaffold(
      title: AppLanguage.tr(
        'ស្ថិតិនិស្សិត & ប្រវត្តិតាមឆ្នាំ (Admin Only)',
        'Student Yearly & Historical Statistics',
      ),
      currentRoute: AppRoutes.studentStats,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 16 : 28),
                children: [
                  // ១. របារ Filter និងប៊ូតុងសកម្មភាព
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLanguage.tr(
                                      'ប្រវត្តិទិន្នន័យនិស្សិតគ្រប់ឆ្នាំចូលរៀន និងគ្រប់ជំនាញ (រក្សាទុកអចិន្ត្រៃយ៍)',
                                      'All-Time Student Enrollment & Historical Records Across All Departments',
                                    ),
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textCol),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLanguage.tr(
                                      'រាប់បញ្ចូលទាំងសិស្សកំពុងរៀន សិស្សរៀនចប់ និងសិស្សឈប់រៀន ដើម្បីធានាមិនបាត់បង់ទិន្នន័យប្រវត្តិសាស្ត្រតាមឆ្នាំ',
                                      'Includes Active, Graduated, and Inactive students so historical intake numbers stay intact',
                                    ),
                                    style: TextStyle(fontSize: 12, color: subTextCol),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.copy_all_rounded, size: 17),
                                  label: Text(AppLanguage.tr('ចម្លង CSV / Excel', 'Copy CSV')),
                                  onPressed: byYear.isEmpty ? null : _copyCsvReport,
                                ),
                                IconButton(
                                  tooltip: 'Refresh',
                                  icon: const Icon(Icons.refresh_rounded),
                                  onPressed: _loadStats,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(
                              width: 170,
                              child: DropdownButtonFormField<String?>(
                                isExpanded: true,
                                initialValue: yearOptions.contains(_selectedIntakeYear) ? _selectedIntakeYear : null,
                                decoration: InputDecoration(
                                  labelText: AppLanguage.tr('ឆ្នាំចូលរៀន', 'Intake Year'),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(AppLanguage.tr('គ្រប់ឆ្នាំទាំងអស់', 'All Years')),
                                  ),
                                  ...yearOptions.map(
                                    (y) => DropdownMenuItem<String?>(value: y, child: Text(y)),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() => _selectedIntakeYear = val);
                                  _loadStats();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 210,
                              child: DropdownButtonFormField<String?>(
                                isExpanded: true,
                                initialValue: genOptions.contains(_selectedGeneration) ? _selectedGeneration : null,
                                decoration: InputDecoration(
                                  labelText: AppLanguage.tr('ជំនាន់', 'Generation'),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(AppLanguage.tr('គ្រប់ជំនាន់', 'All Generations')),
                                  ),
                                  ...genOptions.map(
                                    (g) => DropdownMenuItem<String?>(value: g, child: Text(g, overflow: TextOverflow.ellipsis)),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() => _selectedGeneration = val);
                                  _loadStats();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              child: DropdownButtonFormField<String?>(
                                isExpanded: true,
                                initialValue: deptOptions.contains(_selectedDepartment) ? _selectedDepartment : null,
                                decoration: InputDecoration(
                                  labelText: AppLanguage.tr('ជំនាញ / ដេប៉ាតឺម៉ង់', 'Department'),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(AppLanguage.tr('គ្រប់ជំនាញ', 'All Departments')),
                                  ),
                                  ...deptOptions.map(
                                    (d) => DropdownMenuItem<String?>(value: d, child: Text(d, overflow: TextOverflow.ellipsis)),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() => _selectedDepartment = val);
                                  _loadStats();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 190,
                              child: DropdownButtonFormField<String?>(
                                isExpanded: true,
                                initialValue: _selectedStatus,
                                decoration: InputDecoration(
                                  labelText: AppLanguage.tr('ស្ថានភាព', 'Status'),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(AppLanguage.tr('ទាំងអស់ (All)', 'All Statuses')),
                                  ),
                                  ...ClassService.presetStatuses.map(
                                    (s) => DropdownMenuItem<String?>(
                                      value: s,
                                      child: Text(ClassService.studentStatusLabel(s), overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() => _selectedStatus = val);
                                  _loadStats();
                                },
                              ),
                            ),
                            if (_selectedIntakeYear != null ||
                                _selectedGeneration != null ||
                                _selectedDepartment != null ||
                                _selectedStatus != null)
                              TextButton.icon(
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                label: Text(AppLanguage.tr('សម្អាត', 'Clear')),
                                onPressed: () {
                                  setState(() {
                                    _selectedIntakeYear = null;
                                    _selectedGeneration = null;
                                    _selectedDepartment = null;
                                    _selectedStatus = null;
                                  });
                                  _loadStats();
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ២. កាតសង្ខេបទូទៅ
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 550 ? 2 : 1);
                      final spacing = 14.0;
                      final cardWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          _buildKpiCard(
                            width: cardWidth,
                            title: AppLanguage.tr('និស្សិតរក្សាទុកសរុប', 'Total Historical Students'),
                            value: '${summary['total_students'] ?? 0}',
                            subtitle: AppLanguage.tr(
                              'ប្រុស ${summary['male_count'] ?? 0} · ស្រី ${summary['female_count'] ?? 0}',
                              'Male ${summary['male_count'] ?? 0} · Female ${summary['female_count'] ?? 0}',
                            ),
                            icon: Icons.groups_rounded,
                            color: AppColors.primary,
                            cardBg: cardBg,
                            borderCol: borderCol,
                            textCol: textCol,
                            subTextCol: subTextCol,
                          ),
                          _buildKpiCard(
                            width: cardWidth,
                            title: AppLanguage.tr('កំពុងសិក្សា (Active)', 'Currently Studying'),
                            value: '${summary['active_count'] ?? 0}',
                            subtitle: AppLanguage.tr('អាចស្កេនកត់វត្តមាន', 'Active in classes'),
                            icon: Icons.school_rounded,
                            color: const Color(0xFF16A34A),
                            cardBg: cardBg,
                            borderCol: borderCol,
                            textCol: textCol,
                            subTextCol: subTextCol,
                          ),
                          _buildKpiCard(
                            width: cardWidth,
                            title: AppLanguage.tr('រៀនចប់ (Graduated)', 'Graduated Students'),
                            value: '${summary['graduated_count'] ?? 0}',
                            subtitle: AppLanguage.tr('ទិន្នន័យរក្សាទុកអចិន្ត្រៃយ៍', 'Archived alumni records'),
                            icon: Icons.workspace_premium_rounded,
                            color: const Color(0xFF0284C7),
                            cardBg: cardBg,
                            borderCol: borderCol,
                            textCol: textCol,
                            subTextCol: subTextCol,
                          ),
                          _buildKpiCard(
                            width: cardWidth,
                            title: AppLanguage.tr('ឈប់ / ផ្អាក (Inactive)', 'Inactive / Dropped'),
                            value: '${summary['inactive_count'] ?? 0}',
                            subtitle: AppLanguage.tr(
                              '${summary['departments_count'] ?? 0} ជំនាញ · ${summary['intake_years_count'] ?? 0} ឆ្នាំ',
                              '${summary['departments_count'] ?? 0} Depts · ${summary['intake_years_count'] ?? 0} Years',
                            ),
                            icon: Icons.pause_circle_outline_rounded,
                            color: const Color(0xFFD97706),
                            cardBg: cardBg,
                            borderCol: borderCol,
                            textCol: textCol,
                            subTextCol: subTextCol,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 22),

                  // ៣. តារាងសរុបតាមឆ្នាំចូលរៀន & ជំនាញ (Year × Department Matrix)
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
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            AppLanguage.tr(
                              'តារាងសរុបចំនួននិស្សិតតាមឆ្នាំចូលរៀន និងគ្រប់ជំនាញ (Intake Year × Department)',
                              'Student Enrollment Breakdown by Intake Year & Department',
                            ),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textCol),
                          ),
                        ),
                        const Divider(height: 1),
                        if (byYear.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                AppLanguage.tr('មិនទាន់មានទិន្នន័យនិស្សិតទេ', 'No student data available'),
                                style: TextStyle(color: subTextCol),
                              ),
                            ),
                          )
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                    ),
                                    columns: [
                                      DataColumn(label: Text(AppLanguage.tr('ឆ្នាំចូលរៀន', 'Intake Year'))),
                                      DataColumn(label: Text(AppLanguage.tr('ជំនាន់', 'Generations'))),
                                      DataColumn(label: Text(AppLanguage.tr('សរុបរួម', 'Total')), numeric: true),
                                      DataColumn(label: Text(AppLanguage.tr('កំពុងរៀន', 'Active')), numeric: true),
                                      DataColumn(label: Text(AppLanguage.tr('រៀនចប់', 'Graduated')), numeric: true),
                                      DataColumn(label: Text(AppLanguage.tr('ឈប់', 'Inactive')), numeric: true),
                                      DataColumn(label: Text(AppLanguage.tr('ប្រុស / ស្រី', 'M / F'))),
                                      ...pivotDepts.map((d) => DataColumn(label: Text(d), numeric: true)),
                                    ],
                                    rows: byYear.map((r) {
                                      final gens = (r['generations'] as List? ?? []).join(', ');
                                      final deptMap = Map<String, dynamic>.from(r['departments'] as Map? ?? {});
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${r['intake_year']}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(gens.isEmpty ? '-' : gens)),
                                          DataCell(Text('${r['total'] ?? 0}', style: TextStyle(fontWeight: FontWeight.bold, color: textCol))),
                                          DataCell(Text('${r['active'] ?? 0}', style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w600))),
                                          DataCell(Text('${r['graduated'] ?? 0}', style: const TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.w600))),
                                          DataCell(Text('${r['inactive'] ?? 0}', style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w600))),
                                          DataCell(Text('${r['male'] ?? 0} / ${r['female'] ?? 0}')),
                                          ...pivotDepts.map((d) {
                                            final count = deptMap[d] ?? 0;
                                            return DataCell(
                                              Text(
                                                '$count',
                                                style: TextStyle(
                                                  fontWeight: (count as int) > 0 ? FontWeight.w600 : FontWeight.normal,
                                                  color: count > 0 ? textCol : subTextCol,
                                                ),
                                              ),
                                            );
                                          }),
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
                  const SizedBox(height: 22),

                  // ៤. សរុបតាមជំនាញ និងតាមជំនាន់
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 900;
                      final deptCard = _buildBreakdownCard(
                        title: AppLanguage.tr('ស្ថិតិតាមជំនាញ / ដេប៉ាតឺម៉ង់', 'By Department'),
                        items: byDept,
                        labelKey: 'department',
                        cardBg: cardBg,
                        borderCol: borderCol,
                        textCol: textCol,
                        subTextCol: subTextCol,
                        isDark: isDark,
                      );
                      final genCard = _buildBreakdownCard(
                        title: AppLanguage.tr('ស្ថិតិតាមជំនាន់', 'By Generation'),
                        items: byGen,
                        labelKey: 'generation',
                        cardBg: cardBg,
                        borderCol: borderCol,
                        textCol: textCol,
                        subTextCol: subTextCol,
                        isDark: isDark,
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: deptCard),
                            const SizedBox(width: 18),
                            Expanded(child: genCard),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          deptCard,
                          const SizedBox(height: 18),
                          genCard,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color borderCol,
    required Color textCol,
    required Color subTextCol,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, color: subTextCol, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textCol)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: subTextCol), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownCard({
    required String title,
    required List<Map<String, dynamic>> items,
    required String labelKey,
    required Color cardBg,
    required Color borderCol,
    required Color textCol,
    required Color subTextCol,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textCol)),
          ),
          const Divider(height: 1),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text('-', style: TextStyle(color: subTextCol))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: borderCol),
              itemBuilder: (context, index) {
                final item = items[index];
                final label = item[labelKey]?.toString() ?? '-';
                final total = item['total'] ?? 0;
                final active = item['active'] ?? 0;
                final grad = item['graduated'] ?? 0;
                final inact = item['inactive'] ?? 0;

                return ListTile(
                  title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textCol)),
                  subtitle: Text(
                    'កំពុងរៀន $active · រៀនចប់ $grad · ឈប់ $inact · (ប្រុស ${item['male'] ?? 0} / ស្រី ${item['female'] ?? 0})',
                    style: TextStyle(fontSize: 12, color: subTextCol),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$total ${AppLanguage.tr('នាក់', 'stu')}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

