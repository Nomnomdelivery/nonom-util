class GeocodeResponse {
  final double geoLat;
  final double geoLng;
  final String address;
  final String? barangay;
  final String city;
  final String region;
  final String provider;
  final String locationType;
  final String province;
  final String country;
  final double distance;
  final int cityId;
  final bool isCached;

  GeocodeResponse({
    required this.geoLat,
    required this.geoLng,
    required this.address,
    this.barangay,
    required this.city,
    required this.region,
    required this.provider,
    required this.locationType,
    required this.distance,
    this.isCached = false,
    required this.province,
    required this.country,
    required this.cityId,
  });

  factory GeocodeResponse.fromJson(Map<String, dynamic> json) {
    return GeocodeResponse(
      geoLat: double.parse(json['geo_lat'] as String),
      geoLng: double.parse(json['geo_lng'] as String),
      address: json['address'] as String,
      barangay: json['barangay'] as String?,
      city: json['city'] as String,
      region: json['region'] as String,
      provider: json['provider'] as String,
      locationType: json['location_type'] as String,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      isCached: json['is_database'] as bool? ?? false,
      province: json['province'] as String,
      country: json['country'] as String,
      cityId: json['city_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geo_lat': geoLat,
      'geo_lng': geoLng,
      'address': address,
      'barangay': barangay,
      'city': city,
      'region': region,
      'provider': provider,
      'location_type': locationType,
      'distance': distance,
      'is_database': isCached,
      'province': province,
      'country': country,
      'city_id': cityId,
    };
  }

  @override
  String toString() {
    return 'GeocodeResponse( geoLat: $geoLat, geoLng: $geoLng, address: $address, barangay: $barangay, city: $city, region: $region, provider: $provider, locationType: $locationType, distance: $distance, isCached: $isCached, province: $province, country: $country, cityId: $cityId)';
  }
}
