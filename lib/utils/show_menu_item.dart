import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomnom_util/api/base_app_api.dart';
import 'package:nomnom_util/api/base_cart_api.dart';
import 'package:nomnom_util/api/base_data_cacher.dart';
import 'package:nomnom_util/api/base_firebase_firestore_support.dart';
import 'package:nomnom_util/api/base_store_api.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/cart.dart';
import 'package:nomnom_util/models/cart_item.dart';
import 'package:nomnom_util/models/menu/menu_result.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/models/user_model.dart';
import 'package:nomnom_util/providers/cart.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/menu_replacement_content.dart';

void showMenuReplacementBottomSheet({
  required BuildContext context,
  required CartItem itemToReplace,
  required int merchantId,
  required String merchantName,
  String? orderId,
  required FutureProvider<MenuResult> menuProvider,
  required BaseStoreApi api,
  required StateNotifierProvider<CurrentUserCartNotifier, List<CartModel>>
  currentUserCartProvider,
  required BaseCartApi cartApi,
  required BaseFirebaseFirestoreSupport firestore,
  required StateProvider<AreaSetting?> areaSettingsProvider,
  required BaseAppApi appApi,
  required StateNotifierProvider<CurrentUserNotifier, UserModel?>
  currentUserProvider,
  required StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider,
  required BaseDataCacher prefs,
  required String city,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, color: ColorPalette.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replace "${itemToReplace.menuName}"',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            // Menu content with categories
            Expanded(
              child: MenuReplacementContent(
                merchantId: merchantId,
                merchantName: merchantName,
                itemToReplace: itemToReplace,
                scrollController: scrollController,
                orderId: orderId,
                menuProvider: menuProvider,
                areaSettingsProvider: areaSettingsProvider,
                api: api,
                currentUserCartProvider: currentUserCartProvider,
                cartApi: cartApi,
                firestore: firestore,
                currentLocationProvider: currentLocationProvider,
                currentUserProvider: currentUserProvider,
                appApi: appApi,
                prefs: prefs,
                city: city,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
