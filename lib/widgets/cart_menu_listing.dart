import 'dart:async';
import 'dart:isolate';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nomnom_util/api/app_abstract.dart';
import 'package:nomnom_util/api/cart_api.dart';
import 'package:nomnom_util/api/data_cacher.dart';
import 'package:nomnom_util/api/firebase_firestore_support.dart';
import 'package:nomnom_util/api/store_api.dart';
import 'package:nomnom_util/extensions/color_ext.dart';
import 'package:nomnom_util/extensions/date_ext.dart';
import 'package:nomnom_util/extensions/duration_ext.dart';
import 'package:nomnom_util/extensions/int_ext.dart';
import 'package:nomnom_util/extensions/num_currency_format.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/cart.dart';
import 'package:nomnom_util/models/cart_item.dart';
import 'package:nomnom_util/models/checkout_data.dart';
import 'package:nomnom_util/models/delivery_fee_params.dart';
import 'package:nomnom_util/models/delivery_pricing.dart';
import 'package:nomnom_util/models/delivery_type.dart';
import 'package:nomnom_util/models/firebase/fire_active_schedule.dart';
import 'package:nomnom_util/models/merchant/merchant.dart';
import 'package:nomnom_util/models/merchant/operating_day.dart';
import 'package:nomnom_util/models/promo.dart';
import 'package:nomnom_util/models/selected_option.dart';
import 'package:nomnom_util/models/selected_option_cat.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/models/user_model.dart';
import 'package:nomnom_util/providers/cart.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/utils/distance_matrix_service.dart';
import 'package:nomnom_util/utils/eta_average.dart';
import 'package:nomnom_util/widgets/adaptive_dialog_button.dart';
import 'package:nomnom_util/widgets/custom_radio_button.dart';
import 'package:nomnom_util/widgets/empty_eta.dart';
import 'package:nomnom_util/widgets/merchant_promo_codes.dart';
import 'package:nomnom_util/widgets/quantity_button.dart';
import 'package:nomnom_util/widgets/request_cutlery.dart';
import 'package:nomnom_util/widgets/store_details_page.dart';
import 'package:toastification/toastification.dart';

import '../extensions/time_of_day_parser.dart' show PARSER;

class PortAndVal<T> {
  final T value;
  final SendPort port;
  const PortAndVal({required this.port, required this.value});
}

class CartMenuListing extends ConsumerStatefulWidget {
  const CartMenuListing({
    super.key,
    required this.onCheckout,
    this.orderForSomeoneElse = false,
    required this.firestore,
    required this.api,
    required this.currentUserCartProvider,
    required this.currentLocationProvider,
    required this.areaSettingsProvider,
    required this.deliveryProvider,
    required this.currentActiveRidersStateProvider,
    required this.service,
    required this.cartApi,
    required this.currentUserProvider,
    required this.cartLoadingProvider,
    required this.appApi,
    required this.prefs,
  });
  final ValueChanged<CheckoutData> onCheckout;
  final bool orderForSomeoneElse;
  final FirebaseFirestoreSupport firestore;
  final CartApi cartApi;
  final StoreApi api;
  final StateNotifierProvider<CurrentUserCartNotifier, List<CartModel>>
  currentUserCartProvider;
  final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider;
  final StateProvider<AreaSetting?> areaSettingsProvider;
  final AutoDisposeFutureProviderFamily<double, DeliveryFeeParams>
  deliveryProvider;
  final StateProvider<List<FireActiveSchedule>>
  currentActiveRidersStateProvider;
  final DistanceMatrixService service;
  final StateNotifierProvider<CurrentUserNotifier, UserModel?>
  currentUserProvider;
  final StateProvider<bool> cartLoadingProvider;
  final AppApi appApi;
  final DataCacher prefs;

  @override
  ConsumerState<CartMenuListing> createState() => CartMenuListingState();
}

class CartMenuListingState extends ConsumerState<CartMenuListing>
    with ColorPalette {
  bool hasUtensils = true;
  CartModel? selectedCartModel;
  DeliveryPricing? selectedPricing;
  PromoModel? selectedPromo;
  late DeliveryType selectedDeliveryType = deliveryType.first;
  StreamSubscription? _riderSubscription;
  final List<DeliveryType> deliveryType = [
    //TODO: fix image
    // DeliveryType(
    //   id: 1,
    //   photoPath: "packages/nomnom_util/assets/images/food_delivery.png",
    //   title: "Food Delivery",
    // ),
    // DeliveryType(
    //   id: 2,
    //   photoPath: "packages/nomnom_util/assets/images/food_pick-up.png",
    //   title: "Food Pick-up",
    // ),
  ];
  final DateFormat format = DateFormat('MMM. dd');
  DateTime deliveryDate = DateTime.now().toLocal();
  TimeOfDay deliveryTime = TimeOfDay.now();

  late String selectedItemUnavailability = unavialbleList.first;
  final List<String> unavialbleList = [
    "Replace item",
    "Remove it from my order",
    "Cancel entire order",
  ];
  bool isPreorder = false;

  double calculateOptions(List<SelectedOptionCat> cats) {
    double s = 0.0;
    for (SelectedOptionCat cat in cats) {
      for (SelectedOption opt in cat.options) {
        s += (opt.suboption?.price ?? opt.price ?? 0);
      }
    }
    return s;
  }

  double _calculateSubtotal(double markupRate, CartItem item) {
    double subtotal = 0;
    for (SelectedOptionCat cat in item.options) {
      if (cat.options.isNotEmpty) {
        for (SelectedOption opt in cat.options) {
          subtotal +=
              ((opt.suboption?.price ?? opt.price ?? 0) * (1 + markupRate))
                  .ceilToDouble();
        }
      }
    }
    final double markedUpPrice =
        ((item.selectedVariant?.price ?? item.rawPrice) * (1 + markupRate))
            .ceilToDouble();

    return ((subtotal + markedUpPrice) * item.quantity).ceilToDouble();
  }

  double _calculateTotalMarkups(CartModel model, double markupRate) {
    if (selectedDeliveryType.id == 1) return 0;
    double total = 0.0;
    for (CartItem item in model.items) {
      total = item.options
          .map(
            (e) => e.options.map((ee) => ee.suboption?.price ?? ee.price ?? 0),
          )
          .toList()
          .fold(
            0,
            (prev, curr) => double.parse((prev + curr.first).toString()),
          );
    }
    return total;
  }

  Future<void> _recalculatePricing() async {
    if (selectedCartModel == null) return;
    final loc = ref.read(widget.currentLocationProvider);
    if (loc == null) return;

    final double subtotal = calculateTotalSubtotal(selectedCartModel!);
    final AreaSetting? settings = ref.watch(widget.areaSettingsProvider);

    if (settings == null) {
      Fluttertoast.showToast(
        msg: "Something went wrong please try again later.",
      );
      return;
    }

    final double deliveryFee = await ref.read(
      widget
          .deliveryProvider(
            (DeliveryFeeParams(
              deliveryPoint: loc.coordinates,
              store: selectedCartModel!.merchant.coordinates,
              areaSetting: settings,
              merchantId: selectedCartModel!.merchant.id,
              customerAddressId: loc.id,
            )),
          )
          .future,
    );

    final double merchantFee = selectedCartModel!.merchant.merchantFee;

    final f = DeliveryPricing(
      totalItemMarkup: _calculateTotalMarkups(
        selectedCartModel!,
        ref.read(widget.areaSettingsProvider) == null
            ? .03
            : ref.read(widget.areaSettingsProvider)!.setting.markupRate / 100,
      ),
      promoCode: selectedPricing?.promoCode ?? "",
      deliveryFee: selectedDeliveryType.id == 1 ? deliveryFee : 0,
      promoDeduction: selectedPricing?.promoDeduction ?? 0,
      subtotal: subtotal,
      total:
          subtotal +
          deliveryFee +
          merchantFee -
          (selectedPricing?.promoDeduction ?? 0),
      merchantFee: merchantFee,
    );

    selectedPricing = f;
  }

  double calculateTotalSubtotal(CartModel cartModel) {
    final AreaSetting? settings = ref.watch(widget.areaSettingsProvider);
    final markUpRate = selectedDeliveryType.id == 1
        ? settings == null
              ? .03
              : settings.setting.markupRate / 100
        : 0.0;

    final double merchantTotal = cartModel.items.fold(0, (subtotal, cartItem) {
      final newSubtotal = _calculateSubtotal(markUpRate, cartItem);

      return subtotal + newSubtotal;
    });
    return merchantTotal;
  }

  int determineOrderTime(Merchant store) {
    final now = DateTime.now();
    final startTime = store.currentSchedule.startTime.toTimeOfDay.toDateTime();
    final endTime = store.currentSchedule.endTime.toTimeOfDay.toDateTime();
    if (now.isAfter(startTime) && now.isBefore(endTime)) {
      return 0; // now
    } else if (now.isBefore(startTime)) {
      return 1; // later
    } else if (now.isAfter(endTime)) {
      return 2; // tomorrow
    }

    return 2;
  }

  int getNextOperatingDay(Merchant store) {
    final now = DateTime.now();
    final currentDayOfWeek = now.weekday; // 1 (Monday) to 7 (Sunday)
    final List<OperatingDay> operatingDays = store.operatingDays;

    // Filter only enabled operating days
    final activeDays = operatingDays.where((day) => day.enable).toList();

    // Sort by dayOfWeek
    activeDays.sort((a, b) => a.day.compareTo(b.day));

    // Find the next valid operating day
    for (var day in activeDays) {
      if (day.day == currentDayOfWeek) {
        // Include the current day if within operating hours
        if (now.isBefore(day.endTime.toDateTime())) {
          return 0; // Operating today
        }
      } else if (day.day > currentDayOfWeek) {
        // Future days in the current week
        return day.day - currentDayOfWeek;
      }
    }

    // If no day in the current week, wrap around to the next week
    if (activeDays.isNotEmpty) {
      final firstDay = activeDays.first;
      return (7 - currentDayOfWeek) + firstDay.day;
    }

    // Return 0 if no operating days are enabled
    return 0;
  }

  int? next;
  int? orderTime;

  bool isSelectingCart = false;

  Future<void> selectCart(UserAddress loc, CartModel cartModel) async {
    try {
      setState(() {
        isSelectingCart = true;
      });
      if (cartModel.merchant.city.mergedIds.contains(loc.cityID)) {
        setState(() {
          selectedCartModel = cartModel;
          next = getNextOperatingDay(selectedCartModel!.merchant);
          orderTime = determineOrderTime(selectedCartModel!.merchant);
        });

        final double subtotal = calculateTotalSubtotal(cartModel);

        final AreaSetting? settings = ref.watch(widget.areaSettingsProvider);

        if (settings == null) {
          Fluttertoast.showToast(
            msg: "Something went wrong please restart the app.",
          );
          return;
        }

        final double deliveryFee = await ref.read(
          widget
              .deliveryProvider(
                (DeliveryFeeParams(
                  deliveryPoint: loc.coordinates,
                  store: cartModel.merchant.coordinates,
                  areaSetting: settings,
                  merchantId: cartModel.merchant.id,
                  customerAddressId: loc.id,
                )),
              )
              .future,
        );

        final double merchantFee = cartModel.merchant.merchantFee;

        final f = DeliveryPricing(
          totalItemMarkup: 0,
          promoCode: "",
          deliveryFee: deliveryFee,
          promoDeduction: 0,
          subtotal: subtotal,
          total: subtotal + deliveryFee + merchantFee,
          merchantFee: merchantFee,
        );

        _riderSubscription?.cancel();
        _riderSubscription = widget.firestore
            .listenToActiveRiders(cityName: loc.city)
            .listen((ondata) {
              ref
                  .read(widget.currentActiveRidersStateProvider.notifier)
                  .update((r) => ondata);
            });

        setState(() {
          selectedPricing = f;
          isSelectingCart = false;
        });
      }
    } catch (e, s) {
      debugPrint("${e.toString()} $s");
    }
  }

  Future<void> orderSomeOne() async {
    if (selectedCartModel != null && selectedPricing != null) {
      if (!isPreorder &&
          selectedCartModel!.items.map((e) => e.orderType.id).contains(2)) {
        Fluttertoast.showToast(
          msg: "Cart contains item/s that can only be purchased as pre-order",
        );
        return;
      }

      final AreaSetting? settings = ref.watch(widget.areaSettingsProvider);

      if (settings == null) {
        Fluttertoast.showToast(
          msg: "Something went wrong please try again later.",
        );
        return;
      }

      final eta = await averageEtaWithPrepTime(
        store: selectedCartModel!.merchant.coordinates,
        settings: settings,
        merchantId: selectedCartModel!.merchant.id,
        service: widget.service,
        currentLocationProvider: widget.currentLocationProvider,
        ref: ref,
      );

      widget.onCheckout(
        CheckoutData(
          hasUtensils: hasUtensils,
          cart: selectedCartModel!,
          deliveryDate: deliveryDate,
          deliveryTime: deliveryTime,
          isPreorder: isPreorder,
          deliveryType: selectedDeliveryType,
          isForFriend: true,
          pricing: selectedPricing!,
          note: selectedItemUnavailability,
          etaMinute: selectedDeliveryType.id == 1 ? eta : 0,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = ref.read(widget.currentLocationProvider);
      final cartData = ref.read(widget.currentUserCartProvider).toList();

      if (cartData.length == 1 && selectedCartModel == null && loc != null) {
        if (cartData.first.merchant.city.mergedIds.contains(loc.cityID)) {
          selectCart(loc, cartData.first);
        }
      }
    });
  }

  @override
  void dispose() {
    _riderSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserAddress? loc = ref.watch(widget.currentLocationProvider);
    final AreaSetting? settings = ref.watch(widget.areaSettingsProvider);
    final markUpRate = settings == null
        ? .03
        : settings.setting.markupRate / 100;

    final allCarts = ref.watch(widget.currentUserCartProvider).toList();
    final cartData = loc != null
        ? allCarts.where((cart) {
            return cart.merchant.city.mergedIds.contains(loc.cityID);
          }).toList()
        : allCarts;
    final hasHiddenItems =
        loc != null &&
        allCarts.any(
          (cart) => !cart.merchant.city.mergedIds.contains(loc.cityID),
        );
    // Update selectedCartModel to point to the current CartModel from provider
    if (selectedCartModel != null) {
      try {
        final updated = cartData.firstWhere(
          (e) => e.merchant.id == selectedCartModel!.merchant.id,
        );
        // Check if items have changed - if so, recalculate pricing
        if (updated.items.length != selectedCartModel!.items.length) {
          selectedCartModel = updated;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _recalculatePricing();
          });
        } else {
          selectedCartModel = updated;
        }
      } catch (e) {
        // Cart model no longer exists, reset
        selectedCartModel = null;
        selectedPricing = null;
      }
    }

    if (cartData.length == 1 && selectedCartModel == null) {
      if (loc != null &&
          cartData.first.merchant.city.mergedIds.contains(loc.cityID)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          selectCart(loc, cartData.first);
        });
      }
    } else if (cartData.isEmpty) {
      selectedPricing = null;
      selectedCartModel = null;
    }
    return isSelectingCart
        ? Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator.adaptive(),
            ),
          )
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (hasHiddenItems)
                        Container(
                          decoration: BoxDecoration(color: Colors.grey[100]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: orangePalette),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    "Some items are hidden because they’re not available in your current address.",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (selectedCartModel == null) ...{
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            "Please select a store",
                            style: TextStyle(
                              color: ColorPalette.orange,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      },
                      const Gap(10),
                      ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) {
                          final CartModel model = cartData[i];

                          return StreamBuilder(
                            stream: widget.firestore.listenMerchantSchedule(
                              id: model.merchant.id,
                            ),
                            builder: (context, asyncSnapshot) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomRadioButton(
                                    enabled: loc != null,
                                    disabledMessage:
                                        "Please enable location to calculate estimated delivery",
                                    removeButton:
                                        cartData.length == 1 ||
                                        !model.merchant.city.mergedIds.contains(
                                          loc?.cityID,
                                        ),
                                    currentState: selectedCartModel == model,
                                    callback: (bool f) async {
                                      if (selectedCartModel == model) {
                                        debugPrint("Deselecting cart");
                                        // Redirect to store details page
                                        //TODO: Implement store details page
                                        // Navigator.of(context).push(
                                        //   MaterialPageRoute(
                                        //     builder: (_) => StoreDetailsPage(
                                        //       model: cartData.first.merchant,
                                        //       api: widget.api,
                                        //       currentUserProvider:
                                        //           widget.currentUserProvider,
                                        //     ),
                                        //   ),
                                        // );
                                        return;
                                      }
                                      if (loc == null) {
                                        Fluttertoast.showToast(
                                          msg:
                                              "Please select address to calculate estimated delivery",
                                        );
                                        return;
                                      } else if (!model.merchant.city.mergedIds
                                          .contains(loc.cityID)) {
                                        await showGeneralDialog(
                                          context: context,
                                          barrierColor: Colors.black12,
                                          transitionBuilder:
                                              (context, a1, a2, child) =>
                                                  FadeTransition(
                                                    opacity: a1,
                                                    child: ScaleTransition(
                                                      scale: a1,
                                                      child: child,
                                                    ),
                                                  ),
                                          barrierDismissible: true,
                                          barrierLabel: "",
                                          transitionDuration: 300.ms,
                                          pageBuilder: (context, a1, a2) =>
                                              AlertDialog.adaptive(
                                                backgroundColor: Colors.white,
                                                title: Text(
                                                  "Address Mismatch!",
                                                ),
                                                contentTextStyle: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                content: Text(
                                                  "Merchant and your selected address are in different cities. Kindly update your selected address and make sure it matches with merchant's city.",
                                                ),
                                                actions: [
                                                  AdaptiveDialogButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                    child: Text("OK"),
                                                  ),
                                                ],
                                              ),
                                        );
                                        return;
                                      }
                                      selectedCartModel = model;
                                      deliveryDate =
                                          selectedCartModel!.merchant
                                                  .determineOrderTime(
                                                    ffStoreSchedule:
                                                        asyncSnapshot.data,
                                                  ) >
                                              0
                                          ? DateTime.now().add(
                                              getNextOperatingDay(
                                                selectedCartModel!.merchant,
                                              ).days,
                                            )
                                          : DateTime.now();
                                      deliveryTime =
                                          selectedCartModel!.merchant
                                                  .determineOrderTime(
                                                    ffStoreSchedule:
                                                        asyncSnapshot.data,
                                                  ) >
                                              0
                                          ? selectedCartModel!
                                                .merchant
                                                .operatingDays
                                                .where(
                                                  (e) =>
                                                      e.day ==
                                                      DateTime.now()
                                                          .add(
                                                            getNextOperatingDay(
                                                              selectedCartModel!
                                                                  .merchant,
                                                            ).days,
                                                          )
                                                          .weekday,
                                                )
                                                .first
                                                .startTime
                                          : TimeOfDay.now();
                                      next = getNextOperatingDay(
                                        selectedCartModel!.merchant,
                                      );
                                      orderTime = determineOrderTime(
                                        selectedCartModel!.merchant,
                                      );
                                      isPreorder = orderTime! > 0;
                                      selectedCartModel = model;
                                      final double subtotal =
                                          calculateTotalSubtotal(model);
                                      final AreaSetting? settings = ref.watch(
                                        widget.areaSettingsProvider,
                                      );

                                      if (settings == null) {
                                        Fluttertoast.showToast(
                                          msg:
                                              "Something went wrong please try again later.",
                                        );
                                        return;
                                      }
                                      final double deliveryFee = await ref.read(
                                        widget
                                            .deliveryProvider(
                                              (DeliveryFeeParams(
                                                deliveryPoint: loc.coordinates,
                                                store:
                                                    model.merchant.coordinates,
                                                areaSetting: settings,
                                                merchantId: model.merchant.id,
                                                customerAddressId: loc.id,
                                              )),
                                            )
                                            .future,
                                      );

                                      final double merchantFee =
                                          model.merchant.merchantFee;
                                      final f = DeliveryPricing(
                                        totalItemMarkup: _calculateTotalMarkups(
                                          selectedCartModel!,
                                          markUpRate,
                                        ),
                                        promoCode: "",
                                        deliveryFee:
                                            selectedDeliveryType.id == 1
                                            ? deliveryFee
                                            : 0,
                                        promoDeduction: 0,
                                        subtotal: subtotal,
                                        total:
                                            subtotal +
                                            deliveryFee +
                                            merchantFee,
                                        merchantFee: merchantFee,
                                      );
                                      selectedPricing = f;
                                      selectedPromo = null;
                                      setState(() {});
                                    },
                                    label: model.merchant.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (selectedCartModel == model) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    color: orangePalette,
                                                    size: 20,
                                                  ),
                                                  const Gap(10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (selectedCartModel !=
                                                            null) ...{
                                                          FutureBuilder<int>(
                                                            future: averageEtaWithPrepTime(
                                                              store: selectedCartModel!
                                                                  .merchant
                                                                  .coordinates,
                                                              settings:
                                                                  settings!,
                                                              merchantId:
                                                                  selectedCartModel!
                                                                      .merchant
                                                                      .id,
                                                              service: widget
                                                                  .service,
                                                              currentLocationProvider:
                                                                  widget
                                                                      .currentLocationProvider,
                                                              ref: ref,
                                                            ),
                                                            builder: (context, snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                final int eta =
                                                                    snapshot
                                                                        .data!;
                                                                return Text(
                                                                  isPreorder ||
                                                                          selectedDeliveryType.id ==
                                                                              2
                                                                      ? selectedDeliveryType.id ==
                                                                                2
                                                                            ? "Pick-up"
                                                                            : "Pre-order"
                                                                      : eta
                                                                            .toDuration()
                                                                            .etaFormatDuration(),
                                                                  // ",",
                                                                  style: TextStyle(
                                                                    color:
                                                                        orangePalette,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                );
                                                              } else {
                                                                return EmptyEta();
                                                              }
                                                            },
                                                          ),
                                                        } else ...{
                                                          EmptyEta(),
                                                        },
                                                        if (isPreorder ||
                                                            selectedDeliveryType
                                                                    .id ==
                                                                2) ...{
                                                          Text.rich(
                                                            TextSpan(
                                                              text: format
                                                                  .format(
                                                                    deliveryDate,
                                                                  )
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      " (${deliveryTime.format(context)})",
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .black
                                                                        .withValues(
                                                                          alpha:
                                                                              0.5,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        } else ...{
                                                          Text(
                                                            "Estimated delivery",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        },
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(color: grey),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const Gap(10),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (_, index) {
                                      final CartItem item = model.items[index];
                                      return Slidable(
                                        closeOnScroll: true,
                                        endActionPane: ActionPane(
                                          motion: ScrollMotion(),
                                          children: [
                                            SlidableAction(
                                              onPressed: (context) async {
                                                await widget.cartApi.delete(
                                                  item.cartID,
                                                );
                                                final currentUser = ref.read(
                                                  widget.currentUserProvider,
                                                );
                                                if (currentUser != null) {
                                                  final cart = await widget
                                                      .firestore
                                                      .getCart(
                                                        userID: currentUser.id,
                                                      );
                                                  ref
                                                      .read(
                                                        widget
                                                            .currentUserCartProvider
                                                            .notifier,
                                                      )
                                                      .update(cart);
                                                }
                                                await _recalculatePricing();
                                                setState(() {});
                                              },
                                              backgroundColor: red,
                                              foregroundColor: Colors.white,
                                              label: "Remove item",
                                              icon: Icons.delete_outline,
                                            ),
                                          ],
                                        ),
                                        startActionPane: ActionPane(
                                          motion: ScrollMotion(),
                                          children: [
                                            SlidableAction(
                                              onPressed: (context) async {
                                                await widget.cartApi.delete(
                                                  item.cartID,
                                                );
                                                final currentUser = ref.read(
                                                  widget.currentUserProvider,
                                                );
                                                if (currentUser != null) {
                                                  final cart = await widget
                                                      .firestore
                                                      .getCart(
                                                        userID: currentUser.id,
                                                      );
                                                  ref
                                                      .read(
                                                        widget
                                                            .currentUserCartProvider
                                                            .notifier,
                                                      )
                                                      .update(cart);
                                                }
                                                await _recalculatePricing();
                                                setState(() {});
                                              },
                                              backgroundColor: red,
                                              foregroundColor: Colors.white,
                                              label: "Remove item",
                                              icon: Icons.delete_outline,
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border:
                                                    !isPreorder &&
                                                        item.orderType.id == 2
                                                    ? Border.all(color: red)
                                                    : null,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (!isPreorder &&
                                                      item.orderType.id ==
                                                          2) ...{
                                                    Text(
                                                      "This item is for pre-order only",
                                                      style: TextStyle(
                                                        color: red,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const Gap(5),
                                                  },
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,

                                                    children: [
                                                      if (item
                                                              .photoUrl
                                                              .isNotEmpty &&
                                                          !item.photoUrl
                                                              .contains(
                                                                "no_image",
                                                              ))
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          child:
                                                              CachedNetworkImage(
                                                                imageUrl: item
                                                                    .photoUrl,
                                                                height: 70,
                                                                width: 70,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                        )
                                                      else if (model
                                                          .merchant
                                                          .photoUrl
                                                          .isNotEmpty)
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          child: CachedNetworkImage(
                                                            imageUrl: model
                                                                .merchant
                                                                .photoUrl,
                                                            height: 70,
                                                            width: 70,
                                                            fit: BoxFit.cover,
                                                            errorWidget:
                                                                (
                                                                  context,
                                                                  url,
                                                                  error,
                                                                ) => Image.asset(
                                                                  'packages/nomnom_util/assets/images/customer.jpg',
                                                                  height: 70,
                                                                  width: 70,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                          ),
                                                        )
                                                      else
                                                        Container(
                                                          height: 70,
                                                          width: 70,
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            color: Colors
                                                                .transparent,
                                                          ),
                                                        ),
                                                      SizedBox(width: 20),
                                                      ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                              minHeight: 70,
                                                              maxWidth: 150,
                                                            ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                debugPrint(
                                                                  "Tapped on item name",
                                                                );

                                                                //TODO: selecting item name should redirect to menudatails
                                                                // if (menuItems
                                                                //     .isNotEmpty) {
                                                                //   Navigator.push(
                                                                //     context,
                                                                //     MaterialPageRoute(
                                                                //       builder: (_) => MenuDetails(
                                                                //         item: menuItems.firstWhere(
                                                                //           (
                                                                //             menuItem,
                                                                //           ) =>
                                                                //               menuItem.id ==
                                                                //               item.menuId,
                                                                //         ),
                                                                //       ),
                                                                //     ),
                                                                //   );
                                                                // }
                                                              },
                                                              child: Text(
                                                                item.menuName,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),

                                                            if (item.selectedVariant !=
                                                                null) ...{
                                                              Text(
                                                                "(${item.selectedVariant?.name.capitalizeWords()})",
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      ColorPalette
                                                                          .sgrey
                                                                          .darken(
                                                                            .2,
                                                                          ),
                                                                ),
                                                              ),
                                                            },
                                                            if (item
                                                                .options
                                                                .isNotEmpty) ...{
                                                              Text(
                                                                item.options
                                                                    .map((e) {
                                                                      if (e
                                                                          .options
                                                                          .isNotEmpty) {
                                                                        return "${e.name}: ${e.options.map((x) => "${x.name}${x.suboption != null ? "-${x.suboption!.name}" : ""}")}";
                                                                      }
                                                                      return '';
                                                                    })
                                                                    .toList()
                                                                    .where(
                                                                      (e) => e
                                                                          .isNotEmpty,
                                                                    )
                                                                    .join(', '),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: grey
                                                                      .darken(
                                                                        .2,
                                                                      ),
                                                                ),
                                                              ),
                                                              const Gap(5),
                                                            },

                                                            if (item
                                                                .instruction
                                                                .isNotEmpty) ...{
                                                              Text(
                                                                "\"${item.instruction.capitalize()}\"",
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      ColorPalette
                                                                          .sgrey
                                                                          .darken(
                                                                            .2,
                                                                          ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              const Gap(5),
                                                            },

                                                            Gap(10),
                                                            Text(
                                                              (_calculateSubtotal(
                                                                selectedDeliveryType
                                                                            .id ==
                                                                        1
                                                                    ? markUpRate
                                                                    : 0,
                                                                item,
                                                              )).toAmount(),
                                                              style: TextStyle(
                                                                fontFamily: "",
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              right: 10,
                                              child: SizedBox(
                                                height: 70,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Spacer(),
                                                    QuantityButton(
                                                      fontSize: 12,
                                                      onDelete: () async {
                                                        await widget.cartApi
                                                            .delete(
                                                              item.cartID,
                                                            );
                                                        final currentUser = ref
                                                            .read(
                                                              widget
                                                                  .currentUserProvider,
                                                            );
                                                        if (currentUser !=
                                                            null) {
                                                          final cart = await widget
                                                              .firestore
                                                              .getCart(
                                                                userID:
                                                                    currentUser
                                                                        .id,
                                                              );
                                                          ref
                                                              .read(
                                                                widget
                                                                    .currentUserCartProvider
                                                                    .notifier,
                                                              )
                                                              .update(cart);
                                                        }
                                                        await _recalculatePricing();
                                                        setState(() {});
                                                      },
                                                      callback: (s) async {
                                                        item.quantity = s;

                                                        final double subtotal =
                                                            calculateTotalSubtotal(
                                                              model,
                                                            );

                                                        final deliveryAddress =
                                                            ref.watch(
                                                              widget
                                                                  .currentLocationProvider,
                                                            );

                                                        final AreaSetting?
                                                        settings = ref.watch(
                                                          widget
                                                              .areaSettingsProvider,
                                                        );

                                                        if (settings == null) {
                                                          Fluttertoast.showToast(
                                                            msg:
                                                                "Something went wrong please try again later.",
                                                          );
                                                          return;
                                                        }
                                                        if (deliveryAddress ==
                                                            null) {
                                                          Fluttertoast.showToast(
                                                            msg:
                                                                "Please restart the app and choose your location properly.",
                                                          );
                                                        }
                                                        final double
                                                        deliveryFee = await ref.read(
                                                          widget
                                                              .deliveryProvider(
                                                                (DeliveryFeeParams(
                                                                  deliveryPoint:
                                                                      deliveryAddress!
                                                                          .coordinates,
                                                                  store: model
                                                                      .merchant
                                                                      .coordinates,
                                                                  areaSetting:
                                                                      settings,
                                                                  merchantId: model
                                                                      .merchant
                                                                      .id,
                                                                  customerAddressId:
                                                                      deliveryAddress
                                                                          .id,
                                                                )),
                                                              )
                                                              .future,
                                                        );
                                                        final double
                                                        merchantFee = model
                                                            .merchant
                                                            .merchantFee;
                                                        final f = DeliveryPricing(
                                                          totalItemMarkup:
                                                              _calculateTotalMarkups(
                                                                model,
                                                                markUpRate,
                                                              ),
                                                          promoCode: "",
                                                          deliveryFee:
                                                              selectedDeliveryType
                                                                      .id ==
                                                                  1
                                                              ? deliveryFee
                                                              : 0,
                                                          promoDeduction: 0,
                                                          subtotal: subtotal,
                                                          total:
                                                              subtotal +
                                                              deliveryFee +
                                                              merchantFee,
                                                          merchantFee:
                                                              merchantFee,
                                                        );
                                                        selectedPricing = f;
                                                        selectedPromo = null;
                                                        await widget.cartApi
                                                            .updateQuantity(
                                                              item.cartID,
                                                              s,
                                                            );

                                                        final currentUser = ref
                                                            .read(
                                                              widget
                                                                  .currentUserProvider,
                                                            );
                                                        if (currentUser !=
                                                            null) {
                                                          final cart = await widget
                                                              .firestore
                                                              .getCart(
                                                                userID:
                                                                    currentUser
                                                                        .id,
                                                              );
                                                          ref
                                                              .read(
                                                                widget
                                                                    .currentUserCartProvider
                                                                    .notifier,
                                                              )
                                                              .update(cart);
                                                        }

                                                        setState(() {});
                                                      },
                                                      value: item.quantity,
                                                      limit: item.quantityLimit,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder: (_, i) =>
                                        Divider(color: grey, thickness: .5),
                                    itemCount: model.items.length,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        separatorBuilder: (_, i) =>
                            Divider(color: Colors.black12),
                        itemCount: cartData.length,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: grey),
                            InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () {
                                final bool moreItemsFromStore =
                                    cartData.length == 1;
                                if (moreItemsFromStore) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => StoreDetailsPage(
                                        model: cartData.first.merchant,
                                        api: widget.api,
                                        currentUserProvider:
                                            widget.currentUserProvider,
                                        areaSettingsProvider:
                                            widget.areaSettingsProvider,
                                        appApi: widget.appApi,
                                        currentUserCartProvider:
                                            widget.currentUserCartProvider,
                                        cartApi: widget.cartApi,
                                        firestore: widget.firestore,
                                        currentLocationProvider:
                                            widget.currentLocationProvider,
                                        prefs: widget.prefs,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Text(
                                  "Add more items",
                                  style: TextStyle(
                                    color: orangePalette,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "If item is not available",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const Gap(5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: textField),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      borderRadius: BorderRadius.circular(6),
                                      isExpanded: true,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                      ),
                                      value: selectedItemUnavailability,
                                      items: unavialbleList
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (s) {
                                        setState(() {
                                          selectedItemUnavailability =
                                              s ?? unavialbleList.first;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            RequestCutlery(
                              onChanged: (bool u) {
                                setState(() {
                                  hasUtensils = u;
                                });
                              },
                            ),
                            if (selectedCartModel != null &&
                                selectedPricing != null) ...{
                              const Gap(20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Subtotal",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    selectedPricing!.subtotal.toAmount(),
                                    style: TextStyle(
                                      fontFamily: "",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Delivery fee",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: grey,
                                    ),
                                  ),
                                  Text(
                                    (selectedPricing!.deliveryFee +
                                            selectedPricing!.merchantFee)
                                        .toAmount(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: "",
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            },
                            const Gap(10),
                            if (selectedCartModel != null &&
                                selectedPricing != null) ...{
                              MaterialButton(
                                height: 50,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: orangePalette,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MerchantPromoCodes(
                                        selectedPromo: selectedPromo,
                                        merchantID:
                                            selectedCartModel!.merchant.id,
                                        onPromoSelected: (PromoModel promo) async {
                                          // Check if we're deselecting (same promo clicked again)
                                          if (selectedPromo?.promoCode ==
                                              promo.promoCode) {
                                            debugPrint(
                                              "DESELECTING PROMO - REVERSING CHANGES",
                                            );

                                            setState(() {
                                              // Add back the discount to the total
                                              selectedPricing!.total =
                                                  selectedPricing!.total +
                                                  selectedPricing!
                                                      .promoDeduction;

                                              // Clear promo data
                                              selectedPricing!.promoCode = "";
                                              selectedPricing!.promoDeduction =
                                                  0;
                                              selectedPromo = null;
                                            });

                                            toastification.show(
                                              context: context,
                                              title: Text('Promo Removed'),
                                              description: Text(
                                                'Promo code has been removed',
                                              ),
                                              type: ToastificationType.info,
                                              style: ToastificationStyle.flat,
                                              autoCloseDuration: Duration(
                                                seconds: 2,
                                              ),
                                              alignment: Alignment.topCenter,
                                              showProgressBar: true,
                                              pauseOnHover: true,
                                              dragToClose: true,
                                            );

                                            return true;
                                          }

                                          // Otherwise, apply the new promo
                                          ref
                                              .read(
                                                widget
                                                    .cartLoadingProvider
                                                    .notifier,
                                              )
                                              .update((r) => true);

                                          dynamic promoData = await widget.api
                                              .checkPromo(
                                                cartIds: selectedCartModel!
                                                    .items
                                                    .map((e) => e.cartID)
                                                    .toList(),
                                                promoCode: promo.promoCode,
                                                context: context,
                                              );

                                          ref
                                              .read(
                                                widget
                                                    .cartLoadingProvider
                                                    .notifier,
                                              )
                                              .update((r) => false);

                                          if (promoData == null) {
                                            debugPrint(
                                              "PROMO CODE INVALID OR ALREADY USED",
                                            );
                                            return false;
                                          }

                                          debugPrint(
                                            "SELECTED PRICING SUBTOTAL: ${promo.promoType}",
                                          );

                                          debugPrint(
                                            promo.isAllItems.toString(),
                                          );

                                          debugPrint(
                                            "APPLIED PROMO NEW TOTAL: $promoData",
                                          );

                                          setState(() {
                                            selectedPromo = promo;
                                            selectedPricing!.promoCode =
                                                promo.promoCode;
                                            selectedPricing!.total =
                                                selectedPricing!.total -
                                                double.parse(
                                                  promoData['discount']
                                                      .toString(),
                                                );
                                            selectedPricing!
                                                .promoDeduction = double.parse(
                                              promoData['discount'].toString(),
                                            );
                                          });

                                          toastification.show(
                                            // ignore: use_build_context_synchronously
                                            context: context,
                                            title: Text('Success!'),
                                            description: Text(
                                              'Promo code applied successfully!',
                                            ),
                                            type: ToastificationType.success,
                                            style: ToastificationStyle.flat,
                                            autoCloseDuration: Duration(
                                              seconds: 2,
                                            ),
                                            alignment: Alignment.topCenter,
                                            showProgressBar: true,
                                            pauseOnHover: true,
                                            dragToClose: true,
                                          );

                                          return true;
                                        },
                                        api: widget.api,
                                        currentLocationProvider:
                                            widget.currentLocationProvider,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // ImageIcon(
                                    //   AssetImage(
                                    //     "packages/nomnom_util/assets/icons/promo.png",
                                    //   ),
                                    //   color: orangePalette,
                                    // ),
                                    const Gap(10),
                                    Text(
                                      "Promo code",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: orangePalette,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            },
                          ],
                        ),
                      ),

                      const SafeArea(child: SizedBox()),
                    ],
                  ),
                ),
              ),
              if (selectedPricing != null && selectedCartModel != null) ...{
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedPricing!.promoDeduction > 0) ...{
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Discount",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "-${selectedPricing!.promoDeduction.toInt().toAmount()}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "",
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Gap(5),
                        },

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: "Total",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                children: [],
                              ),
                            ),
                            Text(
                              selectedPricing!.total.ceil().toAmount(),
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: "",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(10),
                            if (next != null && orderTime != null) ...{
                              if (orderTime! > 0) ...{
                                checkoutButton(
                                  isForSomeone: loc!.isForSomeone,
                                  isenabled: true,
                                  delDate: orderTime == 2
                                      ? next! > 1
                                            ? DateTime.now().add(
                                                getNextOperatingDay(
                                                  selectedCartModel!.merchant,
                                                ).days,
                                              )
                                            : DateTime.now().add(1.days)
                                      : selectedCartModel!
                                            .merchant
                                            .currentSchedule
                                            .startTime
                                            .toTimeOfDay
                                            .toDateTime(),
                                  delTime: orderTime == 2
                                      ? next! > 1
                                            ? DateTime.now()
                                                  .add(
                                                    getNextOperatingDay(
                                                      selectedCartModel!
                                                          .merchant,
                                                    ).days,
                                                  )
                                                  .toTimeOfDay()
                                            : DateTime.now()
                                                  .add(1.days)
                                                  .toTimeOfDay()
                                      : selectedCartModel!
                                            .merchant
                                            .currentSchedule
                                            .startTime
                                            .toTimeOfDay,
                                  forPreOrder: false,
                                  containsPreOrderItem:
                                      !isPreorder &&
                                      selectedCartModel!.items
                                          .map((e) => e.orderType.id)
                                          .contains(2),
                                ),
                              } else ...{
                                checkoutButton(
                                  isenabled: true,
                                  delDate: deliveryDate,
                                  delTime: deliveryTime,
                                  forPreOrder: isPreorder,
                                  containsPreOrderItem:
                                      !isPreorder &&
                                      selectedCartModel!.items
                                          .map((e) => e.orderType.id)
                                          .contains(2),
                                  isForSomeone: loc!.isForSomeone,
                                ),
                              },
                            },
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              },
            ],
          );
  }

  Widget checkoutButton({
    required DateTime delDate,
    required bool isenabled,
    required TimeOfDay delTime,
    required bool forPreOrder,
    required bool containsPreOrderItem,
    required bool isForSomeone,
  }) => Column(
    children: [
      MaterialButton(
        height: 55,
        disabledColor: grey,
        color: orangePalette,
        onPressed: isenabled || isForSomeone
            ? () async {
                if (widget.orderForSomeoneElse) {
                  await orderSomeOne();
                  return;
                }
                if (selectedCartModel != null && selectedPricing != null) {
                  if (containsPreOrderItem) {
                    Fluttertoast.showToast(
                      msg:
                          "Cart contains item/s that can only be purchased as pre-order",
                    );
                    return;
                  }

                  final AreaSetting? settings = ref.watch(
                    widget.areaSettingsProvider,
                  );

                  if (settings == null) {
                    Fluttertoast.showToast(
                      msg: "Something went wrong please try again later.",
                    );
                    return;
                  }

                  final eta = await averageEtaWithPrepTime(
                    store: selectedCartModel!.merchant.coordinates,
                    settings: settings,
                    merchantId: selectedCartModel!.merchant.id,
                    service: widget.service,
                    currentLocationProvider: widget.currentLocationProvider,
                    ref: ref,
                  );

                  debugPrint("CARTPAGE $eta");

                  widget.onCheckout(
                    CheckoutData(
                      hasUtensils: hasUtensils,
                      cart: selectedCartModel!,
                      deliveryDate: delDate,
                      deliveryTime: delTime,
                      deliveryType: selectedDeliveryType,
                      isForFriend: isForSomeone,
                      isPreorder: forPreOrder,
                      pricing: selectedPricing!,
                      note: selectedItemUnavailability,
                      etaMinute: selectedDeliveryType.id == 1 ? eta : 0,
                    ),
                  );
                }
              }
            : null,
        elevation: 0,
        child: Center(
          child: Column(
            children: [
              Text(
                "Proceed to check-out",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (forPreOrder) ...{
                Text(
                  "Preorder",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              },
            ],
          ),
        ),
      ),
    ],
  );
}
