import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/merchant/merchant_with_city.dart';

abstract class BaseAppApi {
  Future<AreaSetting?> areaSettings({required String city});

  // Future<List<WhitelistLocationModel>> getWhiteList({
  //   int? cityId,
  //   int? barangayId,
  // });

  // Future<List<RawCategory>> getPredefinedCategories();
  Future<List<MerchantWithCity>> searchByClass(int classID);

  Future<List<MerchantWithCity>> fastfood(String city);

  bool validateMapState(Map<String, dynamic> mapState) =>
      mapState.containsKey('id') &&
      mapState['id'] != null &&
      mapState['id'].toString().isNotEmpty &&
      mapState.containsKey('name') &&
      mapState['name'] != null &&
      mapState['name'].toString().isNotEmpty;

  Future<bool> deliverySettings({
    required String merchantId,
    required double orderTotalAmount,
    required bool isCod,
    double nomnomCoins = 0,
    String promocode = "",
  });

  // Future<GeocodeResponse?> geoCoding({
  //   required double lat,
  //   required double long,
  // });
}
