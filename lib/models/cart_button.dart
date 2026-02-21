import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomnom_util/models/cart.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/providers/cart.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/cart_page.dart';

class CartButton extends StatelessWidget with ColorPalette {
  CartButton({
    super.key,
    this.isFilled = false,
    this.badgeColor,
    this.mainColor = Colors.white,
    this.textColor = const Color(0xffFF9E1B),
    this.showCircle = true,
    required this.currentLocationProvider,
    required this.currentUserCartProvider,
  });
  final Color mainColor;
  final bool isFilled;
  final Color textColor;
  final Color? badgeColor;
  final bool showCircle;
  final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider;
  final StateNotifierProvider<CurrentUserCartNotifier, List<CartModel>>
  currentUserCartProvider;

  late final TextStyle _style = TextStyle(
    fontWeight: FontWeight.bold,
    color: textColor,
    fontSize: 10,
    height: 1,
  );
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, child) {
        final loc = ref.watch(currentLocationProvider);
        final allCarts = ref.watch(currentUserCartProvider);

        // Filter carts to only count items from merchants in the user's current city
        final cart = loc != null
            ? allCarts
                  .where(
                    (cart) => cart.merchant.city.mergedIds.contains(loc.cityID),
                  )
                  .toList()
            : allCarts;

        final int itemCount = cart
            .map((e) => e.items.length) // Get the count of items in each cart
            .fold(0, (sum, count) => sum + count);
        Widget iconWidget;
        if (isFilled) {
          iconWidget = itemCount > 0
              ? Badge.count(
                  count: itemCount,
                  backgroundColor: Colors.white,
                  textStyle: _style,
                  textColor: orangePalette,
                  child: Image.asset(
                    "packages/nomnom_util/assets/icons/new_bag.png",
                    width: 25,
                  ),
                )
              : Image.asset(
                  "packages/nomnom_util/assets/icons/new_bag.png",
                  width: 25,
                );
        } else {
          iconWidget = itemCount > 0
              ? Badge.count(
                  backgroundColor: badgeColor ?? mainColor,
                  count: itemCount,
                  textColor: textColor,
                  textStyle: _style,
                  child: ImageIcon(
                    AssetImage("packages/nomnom_util/assets/icons/bag.png"),
                    color: mainColor,
                  ),
                )
              : ImageIcon(
                  AssetImage("packages/nomnom_util/assets/icons/bag.png"),
                  color: mainColor,
                );
        }
        return IconButton(
          onPressed: () async {
            //TODO: cart page
            // await Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (_) => CartPage()),
            // );
          },
          icon: Container(
            decoration: showCircle
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.4),
                  )
                : null,
            padding: const EdgeInsets.all(8),
            child: iconWidget,
          ),
        );
      },
    );
  }
}
