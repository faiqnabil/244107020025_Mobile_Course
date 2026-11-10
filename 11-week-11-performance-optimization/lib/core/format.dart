// lib/core/format.dart

String routeFromMessage(Map<String, String> data) {
  final route = data['route'] ?? '/';
  return route.startsWith('/') ? route : '/$route';
}

String truncateToken(String? token, {int maxLength = 12}) {
  if (token == null || token.isEmpty) return 'Belum tersedia';
  if (token.length <= maxLength) return token;
  return '${token.substring(0, maxLength)}...';
}

String formatDate(DateTime dateTime) {
  final y = dateTime.year.toString().padLeft(4, '0');
  final m = dateTime.month.toString().padLeft(2, '0');
  final d = dateTime.day.toString().padLeft(2, '0');
  final h = dateTime.hour.toString().padLeft(2, '0');
  final min = dateTime.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $h:$min';
}
