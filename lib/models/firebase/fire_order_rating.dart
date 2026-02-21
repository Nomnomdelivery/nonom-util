class FireOrderRating {
  final int riderRate, storeRate;
  final String riderRateComment, storeRateComment;
  const FireOrderRating({
    this.riderRate = 0,
    this.riderRateComment = "",
    this.storeRate = 0,
    this.storeRateComment = "",
  });

  factory FireOrderRating.fromJson(Map<String, dynamic> json) =>
      FireOrderRating(
        riderRate: json['rider_rate'] ?? 0,
        riderRateComment: json['rider_rate_comment'] ?? "",
        storeRate: json['store_rate'] ?? 0,
        storeRateComment: json['store_rate_comment'] ?? "",
      );
}
