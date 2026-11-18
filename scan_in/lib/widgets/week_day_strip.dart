import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_datetime.dart';
import '../models/class_model.dart';

/// របាររើសថ្ងៃផ្ដេក Week Day Strip បែប Modern (ដូច iOS / Notion Calendar)
/// សម្រាប់ជ្រើសរើសថ្ងៃ និងត្រួតពិនិត្យកាលវិភាគសិក្សាជាក់ស្តែង
class WeekDayStrip extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final List<ClassModel> classes;
  final VoidCallback? onResetToToday;

  const WeekDayStrip({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
    required this.classes,
    this.onResetToToday,
  });

  @override
  State<WeekDayStrip> createState() => _WeekDayStripState();
}

class _WeekDayStripState extends State<WeekDayStrip> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay();
    });
  }

  @override
  void didUpdateWidget(covariant WeekDayStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!AppDateTime.isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      _scrollToSelectedDay();
    }
  }

  void _scrollToSelectedDay() {
    if (!_scrollController.hasClients) return;
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final diff = widget.selectedDate.difference(monday).inDays;
    if (diff >= 0 && diff < 14) {
      final targetOffset = (diff * 64.0) - 100.0;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    // បង្ហាញ ១៤ ថ្ងៃ (២ សប្តាហ៍៖ សប្តាហ៍នេះ និងសប្តាហ៍ក្រោយ)
    final days = List.generate(14, (i) => monday.add(Duration(days: i)));
    final isTodaySelected = AppDateTime.isSameDay(widget.selectedDate, now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header Row: ចំណងជើង & ប៊ូតុងត្រឡប់មកថ្ងៃនេះ ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLanguage.tr('កាលវិភាគប្រចាំសប្តាហ៍', 'Weekly Schedule'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textCol,
                  ),
                ),
              ],
            ),
            if (!isTodaySelected && widget.onResetToToday != null)
              InkWell(
                onTap: widget.onResetToToday,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.today_rounded, size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        AppLanguage.tr('ថ្ងៃនេះ', 'Today'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // --- Horizontal Scrollable Strip (១៤ ថ្ងៃ) ---
        SizedBox(
          height: 80,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = AppDateTime.isSameDay(day, widget.selectedDate);
              final isToday = AppDateTime.isSameDay(day, now);
              final hasClasses = widget.classes.any(
                (c) => AppDateTime.matchesClassSchedule(c.dayOfWeek, c.classDate, day),
              );

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () => widget.onSelectDate(day),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isToday ? AppColors.primary.withValues(alpha: 0.8) : borderCol),
                        width: isToday ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ឈ្មោះថ្ងៃ (ច័ន្ទ, អង្គារ...)
                        Text(
                          AppDateTime.dayOfWeekShort(day),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : (isToday ? AppColors.primary : subTextCol),
                          ),
                        ),
                        // លេខថ្ងៃ (16, 17, 18...)
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : (isToday ? AppColors.primary : textCol),
                          ),
                        ),
                        // Indicator Dot (បើថ្ងៃនោះមានថ្នាក់រៀន)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasClasses
                                ? (isSelected
                                    ? Colors.white
                                    : (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A)))
                                : (isToday && !isSelected
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : Colors.transparent),
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

        const SizedBox(height: 10),

        // --- Sub-indicator ថ្ងៃដែលកំពុងជ្រើសរើស (Current Filter Label) ---
        Row(
          children: [
            Icon(Icons.event_note_rounded, size: 14, color: subTextCol),
            const SizedBox(width: 5),
            Text(
              AppDateTime.formatTimetableDate(widget.selectedDate),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: subTextCol,
              ),
            ),
            if (isTodaySelected) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppLanguage.tr('ថ្ងៃនេះ', 'Today'),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
