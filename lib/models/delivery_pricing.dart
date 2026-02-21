class DeliveryPricing {
  final double deliveryFee, subtotal, totalItemMarkup, merchantFee;
  double total, promoDeduction;
  String promoCode;

  DeliveryPricing({
    required this.totalItemMarkup,
    required this.deliveryFee,
    required this.promoDeduction,
    required this.subtotal,
    required this.total,
    required this.promoCode,
    required this.merchantFee,
  });

  Map<String, dynamic> toJson() => {
    "total_item_markup": totalItemMarkup,
    "delivery_fee": deliveryFee,
    "sub_total": subtotal,
    "total": total,
    "promo_deduction": promoDeduction,
    "promo_code": promoCode,
    "merchant_fee": merchantFee,
  };

  @override
  String toString() => "${toJson()}";

  DeliveryPricing copyWith({
    double? deliveryFee,
    double? subtotal,
    double? total,
    double? promoDeduction,
    double? totalItemMarkup,
    String? promoCode,
    double? merchantFee,
    double? nomnomCoinsDeduction,
  }) {
    return DeliveryPricing(
      totalItemMarkup: totalItemMarkup ?? this.totalItemMarkup,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      promoDeduction: promoDeduction ?? this.promoDeduction,
      promoCode: promoCode ?? this.promoCode,
      merchantFee: merchantFee ?? this.merchantFee,
    );
  }
}
