import 'package:flutter/cupertino.dart';
import 'package:nomnom_util/models/feedback/customer_feedback.dart';

class StoreFeedback {
  final int count;
  final double averageRating;
  final List<CustomerFeedback> feedbacks;
  StoreFeedback({
    required this.averageRating,
    required this.count,
    required this.feedbacks,
  });

  factory StoreFeedback.fromJson(Map<String, dynamic> json) {
    final List f = json['feedbacks'] ?? [];
    final List<CustomerFeedback> feedbacks = f
        .map((e) => CustomerFeedback.fromJson(e))
        .toList();
    // f.map((e) => CustomerFeedback.fromJson(e));
    final int count = json['count'];
    final double ave = double.parse(json['average_rating'].toString());

    final res = StoreFeedback(
      averageRating: ave,
      count: count,
      feedbacks: feedbacks,
    );

    debugPrint("Count $count");
    debugPrint("feedbacks $feedbacks");

    return res;
  }
  Map<String, dynamic> toJson() => {
    "count": count,
    "average": averageRating,
    "feedbacks": feedbacks.map((e) => e.toJson()).toList(),
  };
  @override
  String toString() => "${toJson()}";
}
