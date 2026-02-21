import 'package:nomnom_util/models/user/user_ex.dart';
import 'package:nomnom_util/models/user_model.dart';

abstract class BaseAuthApi {
  Future<bool> deleteAccount();

  Future<void> useReferralCode(String code, int id);

  Future<bool> logout();

  Future<bool> updateDefaultAddressint(int addressID);

  Future<String?> signIn(String firebaseToken, [String? email]);

  // Future<bool> updatePicture(File file);

  // Future<bool> updateProfile(UserModel user);

  // Future<String?> createUserProfile(UserModel user, String? referralCode);

  // static const String _userDetailsCacheKey = 'cached_user_details';

  // /// Returns cached user details synchronously, or null if no cache exists.
  // UserModel? getCachedUserDetails();

  // /// Clears the cached user details
  // Future<void> clearUserDetailsCache();
  Future<UserEx<UserModel, Exception>> getUserDetails();
  // Future<bool> updateAddress(UserAddress address);

  // Future<bool> delete(int id);
  // Future<UserAddress?> saveNewAddress({
  //   required String landmark,
  //   required String address,
  //   required String brgy,
  //   required String state,
  //   required String city,
  //   required String country,
  //   required GeoPoint coordinates,
  //   required String title,
  //   required String region,
  //   required String pinned,
  //   required UserAddress uAddress,
  //   required bool isForSomeone,
  // });
  // Future<bool> addFCMToken(String token);

  // Future<double> getPoints();
}
