import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/api/app_abstract.dart';
import 'package:nomnom_util/api/cart_api.dart';
import 'package:nomnom_util/api/data_cacher.dart';
import 'package:nomnom_util/api/firebase_firestore_support.dart';
import 'package:nomnom_util/api/base_store_api.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/cart.dart';
import 'package:nomnom_util/models/merchant/merchant_with_city.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/models/user_model.dart';
import 'package:nomnom_util/providers/cart.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/store_details_page.dart';

class VisitShop extends StatefulWidget {
  const VisitShop({
    super.key,
    required this.store,
    required this.api,
    required this.currentUserProvider,
    required this.areaSettingsProvider,
    required this.appApi,
    required this.currentUserCartProvider,
    required this.cartApi,
    required this.firestore,
    required this.currentLocationProvider,
    required this.prefs,
  });
  final MerchantWithCity store;
  final BaseStoreApi api;
  final StateNotifierProvider<CurrentUserNotifier, UserModel?>
  currentUserProvider;
  final StateProvider<AreaSetting?> areaSettingsProvider;
  final AppApi appApi;
  final StateNotifierProvider<CurrentUserCartNotifier, List<CartModel>>
  currentUserCartProvider;
  final CartApi cartApi;
  final FirebaseFirestoreSupport firestore;
  final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider;
  final DataCacher prefs;
  @override
  State<VisitShop> createState() => _VisitShopState();
}

class _VisitShopState extends State<VisitShop> with ColorPalette {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: widget.store.photoUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.store.name.capitalizeWords(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  widget.store.displayAddressString,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: .5),
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          SizedBox(
            width: 75,
            child: MaterialButton(
              elevation: 0,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StoreDetailsPage(
                      model: widget.store,
                      api: widget.api,
                      currentUserProvider: widget.currentUserProvider,
                      areaSettingsProvider: widget.areaSettingsProvider,
                      appApi: widget.appApi,
                      currentUserCartProvider: widget.currentUserCartProvider,
                      cartApi: widget.cartApi,
                      firestore: widget.firestore,
                      currentLocationProvider: widget.currentLocationProvider,
                      prefs: widget.prefs,
                    ),
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: orangePalette,
              height: 35,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store, size: 15, color: Colors.white),
                    const Gap(5),
                    Text(
                      "Visit",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
