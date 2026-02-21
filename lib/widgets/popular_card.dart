import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/api/app_abstract.dart';
import 'package:nomnom_util/api/cart_api.dart';
import 'package:nomnom_util/api/data_cacher.dart';
import 'package:nomnom_util/api/firebase_firestore_support.dart';
import 'package:nomnom_util/api/store_api.dart';
import 'package:nomnom_util/extensions/color_ext.dart';
import 'package:nomnom_util/extensions/num_currency_format.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/cart.dart';
import 'package:nomnom_util/models/menu/menu_item.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/models/user_model.dart';
import 'package:nomnom_util/providers/cart.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/menu_details.dart';

class PopularCard extends StatelessWidget with ColorPalette {
  PopularCard({
    super.key,
    required this.item,
    required this.width,
    required this.placeholderImage,
    required this.preorderDateTime,
    required this.areaSettingsProvider,
    required this.api,
    required this.currentUserCartProvider,
    required this.cartApi,
    required this.firestore,
    required this.currentLocationProvider,
    required this.currentUserProvider,
    required this.appApi,
    required this.prefs,
  });
  final MenuItem item;
  final double width;
  final DateTime? preorderDateTime;
  final String placeholderImage;
  final StateProvider<AreaSetting?> areaSettingsProvider;
  final StoreApi api;
  final StateNotifierProvider<CurrentUserCartNotifier, List<CartModel>>
  currentUserCartProvider;
  final CartApi cartApi;
  final FirebaseFirestoreSupport firestore;
  final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider;
  final StateNotifierProvider<CurrentUserNotifier, UserModel?>
  currentUserProvider;
  final AppApi appApi;
  final DataCacher prefs;
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final AreaSetting? settings = ref.watch(areaSettingsProvider);
        final markUpRate = settings == null
            ? .03
            : settings.setting.markupRate / 100;
        final double price = item.itemVariation == null
            ? item.price
            : item.itemVariation!.variations.isEmpty
            ? item.price
            : item.itemVariation!.variations.map((e) => e.price).reduce(min);
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MenuDetails(
                  preorderDateTime: preorderDateTime,
                  item: item,
                  api: api,
                  currentUserCartProvider: currentUserCartProvider,
                  currentUserProvider: currentUserProvider,
                  cartApi: cartApi,
                  firestore: firestore,
                  areaSettingsProvider: areaSettingsProvider,
                  currentLocationProvider: currentLocationProvider,
                  appApi: appApi,
                  prefs: prefs,
                ),
              ),
            );
          },
          child: SizedBox(
            width: width,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 110,
                    width: width,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl:
                                item.photoUrl.isEmpty ||
                                    item.photoUrl.contains("placeholder")
                                ? placeholderImage
                                : item.photoUrl,
                            width: width,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (!item.isAvailable) ...{
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: .1),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: grey.darken().withValues(alpha: .7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Not Available",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        },
                      ],
                    ),
                  ),
                ),

                const Gap(5),
                SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.capitalizeWords(),
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${item.itemVariation != null && item.itemVariation!.variations.isNotEmpty ? "starts at " : ""}${(price * (1 + markUpRate)).ceil().toAmount()}",
                        style: TextStyle(
                          fontFamily: "",
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
