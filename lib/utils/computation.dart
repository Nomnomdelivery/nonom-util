import 'dart:math';

double toRadians(double degree) => degree * (pi / 180.0);
double haversineKm(List<double> coords) {
  final lat1 = coords[0];
  final lon1 = coords[1];
  final lat2 = coords[2];
  final lon2 = coords[3];
  const double R = 6371.0; // Earth radius in kilometers
  final dLat = toRadians(lat2 - lat1);
  final dLon = toRadians(lon2 - lon1);
  final a =
      (sin(dLat / 2) * sin(dLat / 2)) +
      cos(toRadians(lat1)) *
          cos(toRadians(lat2)) *
          (sin(dLon / 2) * sin(dLon / 2));
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

bool computeStoreOpenStatus({
  required String? overrideStatus,
  required Map schedule,
  required DateTime now,
}) {
  // Handle override first
  if (overrideStatus == "open") return true;
  if (overrideStatus == "closed") return false;
  // Check if explicitly closed (fallback)
  if (schedule['isClosed'] == true) return false;

  final String openTimeStr = schedule['open'] ?? "00:00:00";
  final String closeTimeStr = schedule['close'] ?? "00:00:00";
  final String? dateStr = schedule['date'];

  if (dateStr == null) return false; // no valid date

  try {
    final DateTime date = DateTime.parse(dateStr);

    // Parse open and close time based on the given date
    final openParts = openTimeStr
        .split(':')
        .map(int.parse)
        .toList(); // [08,00,00]
    final closeParts = closeTimeStr.split(':').map(int.parse).toList();

    final open = DateTime(
      date.year,
      date.month,
      date.day,
      openParts[0],
      openParts[1],
    );
    final close = DateTime(
      date.year,
      date.month,
      date.day,
      closeParts[0],
      closeParts[1],
    );

    return now.isAfter(open) && now.isBefore(close);
  } catch (e) {
    return false;
  }
}
