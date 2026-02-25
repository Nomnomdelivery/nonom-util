import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/api/base_app_api.dart';
import 'package:nomnom_util/api/base_cart_api.dart';
import 'package:nomnom_util/api/base_data_cacher.dart';
import 'package:nomnom_util/api/base_firebase_firestore_support.dart';
import 'package:nomnom_util/api/base_store_api.dart';
import 'package:nomnom_util/extensions/color_ext.dart';
import 'package:nomnom_util/extensions/num_currency_format.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/cart.dart';
import 'package:nomnom_util/models/cart_item.dart';
import 'package:nomnom_util/models/menu/menu_item.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/models/user_model.dart';
import 'package:nomnom_util/providers/cart.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/custom_loader.dart';
import 'package:nomnom_util/widgets/menu_details.dart';

class BuildSearchByMenu extends StatelessWidget {
  const BuildSearchByMenu({
    super.key,
    required this.dataProvider,
    required this.isWholePage,
    required this.areaSettingsProvider,
    required this.firestore,
    required this.currentLocationProvider,
    required this.cartApi,
    required this.currentUserCartProvider,
    required this.currentUserProvider,
    required this.api,
    required this.appApi,
    required this.prefs,
    required this.orderId,
    required this.originalCartItem,
  });
  final FutureProvider<List<MenuItem>> dataProvider;
  final StateProvider<AreaSetting?> areaSettingsProvider;
  final bool isWholePage;
  final BaseStoreApi api;
  final StateNotifierProvider<CurrentUserNotifier, UserModel?>
  currentUserProvider;
  final StateNotifierProvider<CurrentUserCartNotifier, List<CartModel>>
  currentUserCartProvider;
  final BaseCartApi cartApi;
  final BaseFirebaseFirestoreSupport firestore;
  final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider;
  final BaseAppApi appApi;
  final BaseDataCacher prefs;
  final String orderId;
  final CartItem originalCartItem;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Consumer(
      builder: (context, ref, child) {
        final result = ref.watch(dataProvider);
        final AreaSetting? settings = ref.watch(areaSettingsProvider);
        final markUpRate = settings == null
            ? .03
            : settings.setting.markupRate / 100;
        return result.when(
          data: (data) {
            if (data.isEmpty) {
              return SizedBox(
                width: double.infinity,
                height: isWholePage ? size.height - 250 : 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "packages/nomnom_util/assets/images/rider.png",
                      height: 100,
                    ),
                    const Gap(20),
                    Text("No result found"),
                  ],
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) {
                final MenuItem item = data[i];
                final double price = item.itemVariation == null
                    ? item.price
                    : item.itemVariation!.variations.isEmpty
                    ? item.price
                    : item.itemVariation!.variations
                          .map((e) => e.price)
                          .reduce(min);

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MenuDetails(
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
                          originalCartItem: originalCartItem,
                          orderId: orderId,
                          isReplacement: true,
                        ),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: item.photoUrl,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    item.name.capitalizeWords(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "${item.itemVariation != null && item.itemVariation!.variations.isNotEmpty ? "starts at " : ""}${(price * (1 + markUpRate)).ceil().toAmount()}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: ColorPalette.sgrey.darken(),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, i) => const Gap(10),
              itemCount: data.length,
            );
          },
          error: (e, s) => Container(),
          loading: () => SizedBox(
            width: double.infinity,
            height: isWholePage ? size.height - 250 : 200,
            child: CustomLoader(
              color: const Color(0xFF3F3F3F),
              label: "Searching menu",
            ),
          ),
        );
      },
    );
  }
}
