abstract class DistanceMatrixService {
  Future<Map<String, dynamic>?> getETAInfoAPI({
    required int merchantId,
    required int customerAddressId,
  });
}
