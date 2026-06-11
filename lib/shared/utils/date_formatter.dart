import 'package:intl/intl.dart';

class DateFormatter {
  static String formatScanDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatHeaderDate(DateTime date) =>
      DateFormat('EEEE, MMMM d').format(date);

  static String groupLabel(DateTime date) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));
    if (date.isAfter(weekAgo)) return 'This Week';
    if (date.isAfter(monthAgo)) return 'This Month';
    return DateFormat('MMMM yyyy').format(date);
  }
}
