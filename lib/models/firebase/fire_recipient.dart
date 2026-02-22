class FireRecipient {
  final String contactNumber;
  final String name;
  final String orderedBy;

  FireRecipient({
    required this.contactNumber,
    required this.name,
    required this.orderedBy,
  });

  // Factory method to create an instance from Firestore document data
  factory FireRecipient.fromFirestore(Map<String, dynamic> data) {
    return FireRecipient(
      contactNumber: data['contact_number'] as String,
      name: data['name'] as String,
      orderedBy: data['ordered_by'] as String,
    );
  }

  // Method to convert the instance to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {'contact_number': contactNumber, 'name': name};
  }
}
