import 'dart:math' as math;
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

class MenuCard extends StatefulWidget {
  const MenuCard({
    super.key,
    required this.item,
    required this.preorderDateTime,
    required this.markupRate,
    required this.currentUserCartProvider,
    required this.cartApi,
    required this.firestore,
    required this.areaSettingsProvider,
    required this.currentLocationProvider,
    required this.api,
    required this.currentUserProvider,
    required this.appApi,
    required this.prefs,
  });
  final MenuItem item;
  final DateTime? preorderDateTime;
  final double markupRate;
  final StoreApi api;
  final StateNotifierProvider<CurrentUserCartNotifier, List<CartModel>>
  currentUserCartProvider;
  final CartApi cartApi;
  final FirebaseFirestoreSupport firestore;
  final StateProvider<AreaSetting?> areaSettingsProvider;
  final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider;
  final StateNotifierProvider<CurrentUserNotifier, UserModel?>
  currentUserProvider;
  final AppApi appApi;
  final DataCacher prefs;
  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> with ColorPalette {
  double getPrice() {
    if (widget.item.itemVariation == null) {
      return widget.item.price;
    } else {
      final List<double> prices = widget.item.itemVariation!.variations
          .map((e) => e.price)
          .toList();

      if (prices.isEmpty) {
        return widget.item.price;
      }
      final minimum = prices.reduce(math.min);

      return minimum;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MenuDetails(
              preorderDateTime: widget.preorderDateTime,
              item: widget.item,
              api: widget.api,
              currentUserCartProvider: widget.currentUserCartProvider,
              currentUserProvider: widget.currentUserProvider,
              cartApi: widget.cartApi,
              firestore: widget.firestore,
              areaSettingsProvider: widget.areaSettingsProvider,
              currentLocationProvider: widget.currentLocationProvider,
              appApi: widget.appApi,
              prefs: widget.prefs,
            ),
          ),
        );
      },
      child: Container(
        color: scaffoldColor,
        height: 110,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name.capitalizeWords(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: (getPrice() * (1 + (widget.markupRate)))
                            .ceil()
                            .toAmount(),
                        style: TextStyle(
                          fontFamily: "",
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          if (widget.item.orderType > 1) ...{
                            TextSpan(
                              text:
                                  " ${widget.item.orderType == 2 ? "Pre-order Only" : ""}",
                              style: TextStyle(
                                color: orangePalette,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          },
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.item.photoUrl.isNotEmpty &&
                !widget.item.photoUrl.contains("placeholder")) ...{
              const Gap(10),
              Hero(
                tag: "${widget.item.id}${widget.item.photoUrl}",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: widget.item.photoUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (!widget.item.isAvailable) ...{
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
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
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
              ),
            },
          ],
        ),
      ),
    );
  }
}
