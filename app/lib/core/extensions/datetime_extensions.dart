import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get toDisplayDate => DateFormat('d MMM yyyy').format(this);

  String get toDisplayDateTime => DateFormat('d MMM yyyy, h:mm a').format(this);

  String get toDisplayTime => DateFormat('h:mm a').format(this);

  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
