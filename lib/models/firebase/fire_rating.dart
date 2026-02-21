class FireRating {
  final int rate;
  final String feedback;
  const FireRating({required this.feedback, required this.rate});
  factory FireRating.fromJson(Map<String, dynamic> json) => FireRating(
    feedback: json['feedback'] as String,
    rate: json['rate'] as int,
  );

  Map<String, dynamic> toJson() => {"feedback": feedback, "rate": rate};

  @override
  String toString() => "${toJson()}";
}
