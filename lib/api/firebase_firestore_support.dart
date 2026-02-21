import 'dart:io';
import 'package:nomnom_util/models/cart.dart';
import 'package:nomnom_util/models/delivery_model.dart';
import 'package:nomnom_util/models/firebase/fire_active_schedule.dart';

abstract class FirebaseFirestoreSupport {
  Future<void> updateETA(String refcode, int eta);

  Future<DeliveryModel?> getRealtimeData({required String referenceCode});

  Stream<DeliveryModel?> listenToSpecificItem({required String referenceCode});

  Stream<List<FireActiveSchedule>> listenToActiveRiders({
    required String cityName,
  });

  Stream<Map<String, dynamic>?> listenMerchantSchedule({required int id});

  // Stream<List<CartModel>> listenToCart({required int userID});

  Future<List<CartModel>> getCart({required int userID});

  // List<CartModel> convertCartSnapshot(QuerySnapshot snapshot);

  // Future<void> updateCartItemQuantity(int cartID, int nQuantity);

  // Stream<List<DeliveryModel>> listenToDeliveries({
  //   required int value,
  //   required String key,
  // });
  // Future<DeliveryModel?> getOrderByExternalId(String externalId);
  // Stream<FirebaseCoin> listenCoins({required int userID});
  // Stream<RiderLocationData?> listenSpecificRider(int riderId);

  // Stream<List<DeliveryModel>> listenRider({
  //   required int value,
  //   required String key,
  // });
  // List<DeliveryModel> convertQuerySnapshotToList(QuerySnapshot snapshot);
  // Stream<List<Chat>> fetchMessages({required String refcode});

  // Stream<ChatroomModel> listenToChatroom({required String refcode});

  // Future<void> updateOnlinePayment({
  //   required String refcode,
  //   required String txID,
  //   required String eID,
  //   required double additionalcharge,
  // });
  // Future<void> updateStatus({required String refcode, required int status});
  // Future<AppRemoteConfig> getRemoteConfig();
  Future<String> uploadPhoto(File file, String fileName, String refCode);

  Future<void> addNewMessage({
    required String message,
    required String refcode,
    required int senderID,
    required String senderAvatar,
    required String senderName,
    File? photo,
  });

  Future<void> addRating({
    required String ref,
    required int riderRating,
    required String riderComment,
    required int storeRating,
    required String storeComment,
  });

  Future<void> addFcmToken(int id, String token);
  Future<List<String>> getTokens(int id);

  Future<void> removeToken(int id, String token);
}
