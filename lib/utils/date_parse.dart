// Helper to parse nullable date/datetime values that may come as Timestamp, String, or int(ms)
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? parseDateNullable(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is int) {
    // assume millisecondsSinceEpoch
    return DateTime.fromMillisecondsSinceEpoch(v);
  }
  if (v is String) {
    if (v.trim().isEmpty) return null;
    // Try normal ISO8601 parse, else if numeric treat as ms epoch
    final iso = DateTime.tryParse(v);
    if (iso != null) return iso;
    final epoch = int.tryParse(v);
    if (epoch != null) {
      return DateTime.fromMillisecondsSinceEpoch(epoch);
    }
  }
  return null; // unsupported type
}
