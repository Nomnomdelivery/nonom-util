class FireRecipient {
  final String contactNumber;
  final String name;

  FireRecipient({required this.contactNumber, required this.name});

  // Factory method to create an instance from Firestore document data
  factory FireRecipient.fromFirestore(Map<String, dynamic> data) {
    return FireRecipient(
      contactNumber: data['contact_number'] as String,
      name: data['name'] as String,
    );
  }

  // Method to convert the instance to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {'contact_number': contactNumber, 'name': name};
  }
}
