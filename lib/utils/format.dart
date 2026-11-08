const _months = [
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

/// Formats an amount as Indian rupees, e.g. `₹1,250`.
String money(num value) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
  return '${negative ? '-' : ''}₹$grouped';
}

/// e.g. `12 Oct, 6:45 PM`
String dateTime(DateTime d) {
  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final suffix = d.hour >= 12 ? 'PM' : 'AM';
  return '${d.day} ${_months[d.month - 1]}, $hour12:$minute $suffix';
}

/// e.g. `12 Oct`
String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}
