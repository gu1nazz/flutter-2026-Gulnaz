const List<String> _months = [
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

String _two(int n) => n.toString().padLeft(2, '0');

/// 18 Oct
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// 09:05
String formatTime(int hour, int minute) => '${_two(hour)}:${_two(minute)}';

/// 18 Oct, 10:00
String formatDateTime(DateTime d) =>
    '${formatDate(d)}, ${formatTime(d.hour, d.minute)}';
