import 'app_language.dart';

/// Helper សម្រាប់ Format កាលបរិច្ឆេទជាភាសាខ្មែរ និងអង់គ្លេស Real-time
/// គាំទ្រស្តង់ដារ NUBB និងប្រព័ន្ធសាកលវិទ្យាល័យកម្ពុជា
class AppDateTime {
  static const List<String> khmerDays = [
    'ច័ន្ទ',
    'អង្គារ',
    'ពុធ',
    'ព្រហស្បតិ៍',
    'សុក្រ',
    'សៅរ៍',
    'អាទិត្យ',
  ];

  static const List<String> englishDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> khmerMonths = [
    'មករា',
    'កុម្ភៈ',
    'មីនា',
    'មេសា',
    'ឧសភា',
    'មិថុនា',
    'កក្កដា',
    'សីហា',
    'កញ្ញា',
    'តុលា',
    'វិច្ឆិកា',
    'ធ្នូ',
  ];

  static const List<String> englishMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> englishMonthsFull = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// ឈ្មោះថ្ងៃក្នុងសប្តាហ៍ (weekday: 1=Mon .. 7=Sun)
  static String dayOfWeek(DateTime dt) {
    final idx = (dt.weekday - 1).clamp(0, 6);
    return AppLanguage.isKhmer ? khmerDays[idx] : englishDays[idx];
  }

  /// ឈ្មោះខែ (month: 1..12)
  static String monthName(DateTime dt, {bool fullEnglish = false}) {
    final idx = (dt.month - 1).clamp(0, 11);
    if (AppLanguage.isKhmer) {
      return khmerMonths[idx];
    }
    return fullEnglish ? englishMonthsFull[idx] : englishMonths[idx];
  }

  /// Format សម្រាប់ Header លើ Dashboard:
  /// ខ្មែរ៖ ថ្ងៃពុធ 18 វិច្ឆិកា 2026
  /// អង់គ្លេស៖ Wednesday, Nov 18, 2026
  static String formatHeaderDate(DateTime dt) {
    if (AppLanguage.isKhmer) {
      return 'ថ្ងៃ${dayOfWeek(dt)} ${dt.day} ${monthName(dt)} ${dt.year}';
    }
    return '${dayOfWeek(dt)}, ${monthName(dt)} ${dt.day}, ${dt.year}';
  }

  /// Format សម្រាប់របារ Timetable (ដូច NUBB UI):
  /// ខ្មែរ៖ ថ្ងៃពុធ, ខែវិច្ឆិកា 18, 2026
  /// អង់គ្លេស៖ Wednesday, November 18, 2026
  static String formatTimetableDate(DateTime dt) {
    if (AppLanguage.isKhmer) {
      return 'ថ្ងៃ${dayOfWeek(dt)}, ខែ${monthName(dt)} ${dt.day}, ${dt.year}';
    }
    return '${dayOfWeek(dt)}, ${monthName(dt, fullEnglish: true)} ${dt.day}, ${dt.year}';
  }

  /// ពិនិត្យមើលថាតើ Date ទាំងពីរជាថ្ងៃតែមួយឬទេ
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
