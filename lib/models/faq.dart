class FAQCategory {
  final String category;
  final List<FAQItem> items;

  FAQCategory({required this.category, required this.items});

  // Factory constructor to parse JSON
  factory FAQCategory.fromJson(Map<String, dynamic> json) {
    return FAQCategory(
      category: json['category'],
      items: (json['items'] as List)
          .map((item) => FAQItem.fromJson(item))
          .toList(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});

  // Factory constructor to parse JSON
  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(question: json['question'], answer: json['answer']);
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'question': question, 'answer': answer};
  }
}
