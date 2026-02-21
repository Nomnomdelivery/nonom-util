import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nomnom_util/models/menu/menu_item.dart';
import 'package:nomnom_util/models/menu/menu_item_details.dart';
import 'package:nomnom_util/models/menu/menu_result.dart';
import 'package:nomnom_util/models/merchant/merchant_details.dart';
import 'package:nomnom_util/models/merchant/merchant_with_city.dart';
import 'package:nomnom_util/models/promo.dart';
import 'package:nomnom_util/models/store_feedback.dart';

abstract class StoreApi {
  Future<int?> getStoreCount();

  Future<MerchantDetails> publicDetails(int id);

  Future<List<MerchantWithCity>> publicSearch({
    required int serviceID,
    String? keyword,
    String? city,
  });

  /// Returns cached merchant search results synchronously, or null if no cache exists.
  List<MerchantWithCity>? getCachedSearch({
    String? keyword,
    String? city,
    required int serviceID,
  });

  /// Clears the cache for a specific search
  Future<void> clearCache({
    String? keyword,
    String? city,
    required int serviceID,
  });

  Future<List<MerchantWithCity>> search({
    String? keyword,
    String? city,
    required int serviceID,
  });

  Future<StoreFeedback> getRatingsAndFeedback(int id, {isPublic = false});

  Future<MerchantDetails> getDetails(int id, {bool isPublic = false});
  Future<MenuItemDetails?> getPublicMenuDetails(int id);

  Future<MenuItemDetails?> getMenuDetails(int id, {bool isPublic = false});

  Future<dynamic> checkPromo({
    required List<int> cartIds,
    required String promoCode,
    BuildContext? context,
  });

  Future<List<PromoModel>> getOngoingPromo({
    required List<int> ids,
    bool isPublic = false,
    int? addressId,
  });

  Future<MenuResult> getMenu(int id, {isPublic = false});
  Future<List<MenuItem>> publicSearchMenu({String? keyword});

  Future<List<MenuItem>> searchMenu({
    String? keyword,
    bool? isPopular,
    bool? isAvailable,
    int? merchantID,
  });
}
