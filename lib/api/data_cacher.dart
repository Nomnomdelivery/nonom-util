import 'dart:async';

abstract class DataCacher {
  Future<void> logout();

  Future<void> init();

  Future<void> saveUID(String uid);

  Future<void> removeUID();
  String? getUID();

  Future<void> saveSignedEmail(String email);
  String? signedEmail();
  Future<void> removeEmail();

  Future<void> signInMethod(int i);

  int getSignInMethod();
  Future<void> removeSignInMethod();

  Future<void> saveFcmToken(String tok);

  Future<void> removeFcmToken();

  String? getUserToken();
  Future<void> setUserToken(String token);
  Future<void> removeToken();
  Future<void> setFirebaseToken(String t);
  Future<void> removeFirebaseToken();
  String? firebaseToken();
  Future<void> setLoginTypeValue(String value);

  String? loginValue();
  Future<void> removeLoginValue();
  Future<void> setUserID(int id);
  int? getUserID();
  Future<void> removeUserID();

  // Temporary storage for deep link auth continuation
  static String? pendingVerificationId;
  static String? pendingPhone;

  // Generic cache methods
  Future<void> setCacheString(String key, String value);

  String? getCacheString(String key);

  Future<void> removeCacheString(String key);

  // remove user token
  Future<void> clearGeocodingCache();
}
