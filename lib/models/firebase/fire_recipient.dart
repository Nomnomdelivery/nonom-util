import 'package:nomnom_util/models/firebase/ordered_by.dart';

class FireRecipient {
  final String contactNumber;
  final String name;
  final OrderedBy? orderedBy;

  FireRecipient({
    required this.contactNumber,
    required this.name,
    this.orderedBy,
  });

  // Factory method to create an instance from Firestore document data
  factory FireRecipient.fromFirestore(Map<String, dynamic> data) {
    return FireRecipient(
      contactNumber: data['contact_number'] as String,
      name: data['name'] as String,
      orderedBy: data['ordered_by'] is Map<String, dynamic>
          ? OrderedBy.fromFirestore(data['ordered_by'] as Map<String, dynamic>)
          : null,
    );
  }

  // Method to convert the instance to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'contact_number': contactNumber,
      'name': name,
      if (orderedBy != null)
        'ordered_by': {
          'contact_number': orderedBy!.contactNumber,
          'full_name': orderedBy!.fullName,
        },
    };
  }
}
