class Rating {
  final double averageRating;
  final int count;
  final List feedbacks;

  Rating({
    required this.averageRating,
    required this.count,
    required this.feedbacks,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      averageRating: double.parse(json['average_rating'].toString()),
      count: json['count'],
      feedbacks: json['feedbacks'],
    );
  }

  Map<String, dynamic> toJson() => {
    'average_rating': averageRating,
    'count': count,
    'feedbacks': feedbacks,
  };
}
