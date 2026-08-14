class OrderedBy {
  final String contactNumber;
  final String fullName;

  OrderedBy({required this.contactNumber, required this.fullName});

  // Factory method to create an instance from Firestore document data
  factory OrderedBy.fromFirestore(Map<String, dynamic> data) {
    return OrderedBy(
      contactNumber: data['contact_number'] as String? ?? '',
      fullName: data['full_name'] as String? ?? '',
    );
  }
}
