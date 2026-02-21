class Setting {
  final int id;
  final int parameterId;
  final int serviceAvailability;
  final String deliveryStartTime;
  final String deliveryEndTime;
  final double deliveryBaseFare;
  final double deliveryRatePerKm;
  final double applicableDistance;
  final double deliveryRatePerKmBeyond;
  final int customerActiveOrderLimit;
  final int riderActiveOrderLimit;
  final double maximumOrderAmountCash;
  final double maximumOrderAmountNoncash;
  final double coinsEarnRate;
  final int coinsExpirationMonths;
  final double coinsMaximumEarned;
  final double minimumShareableCoins;
  final double maximumShareableCoins;
  final double referralEarnedCoins;
  final int bookingDay;
  final int bookingShiftDuration;
  final int bookingMinimumDutyHours;
  final int bookingMaximumDutyHours;
  final String bookingHighStartTime;
  final String bookingHighEndTime;
  final String bookingMiddleStartTime;
  final String bookingMiddleEndTime;
  final String bookingLowStartTime;
  final String bookingLowEndTime;
  final double riderCommissionRate;
  final double riderCustomerRatingFeedback;
  final double riderAcceptanceRate;
  final double riderWorkRate;
  final int riderAcceptanceWindow;
  final int riderAssignmentWindow;
  final int storeAcceptanceWindow;
  final double storeAcceptanceRate;
  final double storeCompleteOrdersRate;
  final double storeTimelinessRate;
  final double storeHighestCustomerReviews;
  final double storePenaltyPreptime;
  final double storePenaltyDeclined;
  final double storePenaltyIncorrectIncomplete;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isEquivalentDeliveryFee;
  final double riderTransferLimit;
  final String postingTime;
  final double markupRate;

  Setting({
    required this.id,
    required this.parameterId,
    required this.serviceAvailability,
    required this.deliveryStartTime,
    required this.deliveryEndTime,
    required this.deliveryBaseFare,
    required this.deliveryRatePerKm,
    required this.applicableDistance,
    required this.deliveryRatePerKmBeyond,
    required this.customerActiveOrderLimit,
    required this.riderActiveOrderLimit,
    required this.maximumOrderAmountCash,
    required this.maximumOrderAmountNoncash,
    required this.coinsEarnRate,
    required this.coinsExpirationMonths,
    required this.coinsMaximumEarned,
    required this.minimumShareableCoins,
    required this.maximumShareableCoins,
    required this.referralEarnedCoins,
    required this.bookingDay,
    required this.bookingShiftDuration,
    required this.bookingMinimumDutyHours,
    required this.bookingMaximumDutyHours,
    required this.bookingHighStartTime,
    required this.bookingHighEndTime,
    required this.bookingMiddleStartTime,
    required this.bookingMiddleEndTime,
    required this.bookingLowStartTime,
    required this.bookingLowEndTime,
    required this.riderCommissionRate,
    required this.riderCustomerRatingFeedback,
    required this.riderAcceptanceRate,
    required this.riderWorkRate,
    required this.riderAcceptanceWindow,
    required this.riderAssignmentWindow,
    required this.storeAcceptanceWindow,
    required this.storeAcceptanceRate,
    required this.storeCompleteOrdersRate,
    required this.storeTimelinessRate,
    required this.storeHighestCustomerReviews,
    required this.storePenaltyPreptime,
    required this.storePenaltyDeclined,
    required this.storePenaltyIncorrectIncomplete,
    required this.createdAt,
    required this.updatedAt,
    required this.isEquivalentDeliveryFee,
    required this.riderTransferLimit,
    required this.postingTime,
    required this.markupRate,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['id'],
      parameterId: json['parameter_id'],
      serviceAvailability: json['service_availability'],
      deliveryStartTime: json['delivery_start_time'],
      deliveryEndTime: json['delivery_end_time'],
      deliveryBaseFare: double.parse(json['delivery_base_fare'].toString()),
      deliveryRatePerKm: double.parse(json['delivery_rate_per_km'].toString()),
      applicableDistance: double.parse(json['applicable_distance'].toString()),
      deliveryRatePerKmBeyond: double.parse(
        json['delivery_rate_per_km_beyond'].toString(),
      ),
      customerActiveOrderLimit: json['customer_active_order_limit'],
      riderActiveOrderLimit: json['rider_active_order_limit'],
      maximumOrderAmountCash: double.parse(
        json['maximum_order_amount_cash'].toString(),
      ),
      maximumOrderAmountNoncash: double.parse(
        json['maximum_order_amount_noncash'].toString(),
      ),
      coinsEarnRate: double.parse(json['coins_earn_rate'].toString()),
      coinsExpirationMonths: json['coins_expiration_months'],
      coinsMaximumEarned: double.parse(
        json['coints_maximum_earned'].toString(),
      ),
      minimumShareableCoins: double.parse(
        json['minimum_shareable_coins'].toString(),
      ),
      maximumShareableCoins: double.parse(
        json['maximum_shareable_coins'].toString(),
      ),
      referralEarnedCoins: double.parse(
        json['referral_earned_coins'].toString(),
      ),
      bookingDay: json['booking_day'],
      bookingShiftDuration: json['booking_shift_duration'],
      bookingMinimumDutyHours: json['booking_minimum_duty_hours'],
      bookingMaximumDutyHours: json['booking_maximum_duty_hours'],
      bookingHighStartTime: json['booking_high_start_time'],
      bookingHighEndTime: json['booking_high_end_time'],
      bookingMiddleStartTime: json['booking_middle_start_time'],
      bookingMiddleEndTime: json['booking_middle_end_time'],
      bookingLowStartTime: json['booking_low_start_time'],
      bookingLowEndTime: json['booking_low_end_time'],
      riderCommissionRate: double.parse(
        json['rider_commission_rate'].toString(),
      ),
      riderCustomerRatingFeedback: double.parse(
        json['rider_customer_rating_feedback'].toString(),
      ),
      riderAcceptanceRate: double.parse(
        json['rider_acceptance_rate'].toString(),
      ),
      riderWorkRate: double.parse(json['rider_work_rate'].toString()),
      riderAcceptanceWindow: json['rider_acceptance_window'],
      riderAssignmentWindow: json['rider_assignment_window'],
      storeAcceptanceWindow: json['store_acceptance_window'],
      storeAcceptanceRate: double.parse(
        json['store_acceptance_rate'].toString(),
      ),
      storeCompleteOrdersRate: double.parse(
        json['store_complete_orders_rate'].toString(),
      ),
      storeTimelinessRate: double.parse(
        json['store_timeliness_rate'].toString(),
      ),
      storeHighestCustomerReviews: double.parse(
        json['store_highest_customer_reviews'].toString(),
      ),
      storePenaltyPreptime: double.parse(
        json['store_penalty_preptime'].toString(),
      ),
      storePenaltyDeclined: double.parse(
        json['store_penalty_declined'].toString(),
      ),
      storePenaltyIncorrectIncomplete: double.parse(
        json['store_penalty_incorrect_incomplete'].toString(),
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isEquivalentDeliveryFee: json['is_equivalent_delivery_fee'],
      riderTransferLimit: double.parse(json['rider_transfer_limit'].toString()),
      postingTime: json['posting_time'],
      markupRate: double.parse(json['markup_rate'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parameter_id': parameterId,
      'service_availability': serviceAvailability,
      'delivery_start_time': deliveryStartTime,
      'delivery_end_time': deliveryEndTime,
      'delivery_base_fare': deliveryBaseFare,
      'delivery_rate_per_km': deliveryRatePerKm,
      'applicable_distance': applicableDistance,
      'delivery_rate_per_km_beyond': deliveryRatePerKmBeyond,
      'customer_active_order_limit': customerActiveOrderLimit,
      'rider_active_order_limit': riderActiveOrderLimit,
      'maximum_order_amount_cash': maximumOrderAmountCash,
      'maximum_order_amount_noncash': maximumOrderAmountNoncash,
      'coins_earn_rate': coinsEarnRate,
      'coins_expiration_months': coinsExpirationMonths,
      'coints_maximum_earned': coinsMaximumEarned,
      'minimum_shareable_coins': minimumShareableCoins,
      'maximum_shareable_coins': maximumShareableCoins,
      'referral_earned_coins': referralEarnedCoins,
      'booking_day': bookingDay,
      'booking_shift_duration': bookingShiftDuration,
      'booking_minimum_duty_hours': bookingMinimumDutyHours,
      'booking_maximum_duty_hours': bookingMaximumDutyHours,
      'booking_high_start_time': bookingHighStartTime,
      'booking_high_end_time': bookingHighEndTime,
      'booking_middle_start_time': bookingMiddleStartTime,
      'booking_middle_end_time': bookingMiddleEndTime,
      'booking_low_start_time': bookingLowStartTime,
      'booking_low_end_time': bookingLowEndTime,
      'rider_commission_rate': riderCommissionRate,
      'rider_customer_rating_feedback': riderCustomerRatingFeedback,
      'rider_acceptance_rate': riderAcceptanceRate,
      'rider_work_rate': riderWorkRate,
      'rider_acceptance_window': riderAcceptanceWindow,
      'rider_assignment_window': riderAssignmentWindow,
      'store_acceptance_window': storeAcceptanceWindow,
      'store_acceptance_rate': storeAcceptanceRate,
      'store_complete_orders_rate': storeCompleteOrdersRate,
      'store_timeliness_rate': storeTimelinessRate,
      'store_highest_customer_reviews': storeHighestCustomerReviews,
      'store_penalty_preptime': storePenaltyPreptime,
      'store_penalty_declined': storePenaltyDeclined,
      'store_penalty_incorrect_incomplete': storePenaltyIncorrectIncomplete,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_equivalent_delivery_fee': isEquivalentDeliveryFee,
      'rider_transfer_limit': riderTransferLimit,
      'posting_time': postingTime,
      'markup_rate': markupRate,
    };
  }
}
