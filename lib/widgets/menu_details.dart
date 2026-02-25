import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/api/base_app_api.dart';
import 'package:nomnom_util/api/base_cart_api.dart';
import 'package:nomnom_util/api/base_data_cacher.dart';
import 'package:nomnom_util/api/base_firebase_firestore_support.dart';
import 'package:nomnom_util/api/base_store_api.dart';
import 'package:nomnom_util/extensions/list2_ext.dart';
import 'package:nomnom_util/extensions/num_currency_format.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/cart.dart';
import 'package:nomnom_util/models/cart_item.dart';
import 'package:nomnom_util/models/menu/menu_item.dart';
import 'package:nomnom_util/models/menu/menu_item_details.dart';
import 'package:nomnom_util/models/menu_variation.dart';
import 'package:nomnom_util/models/option/option_category.dart';
import 'package:nomnom_util/models/selected_option.dart';
import 'package:nomnom_util/models/selected_option_cat.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/models/user_model.dart';
import 'package:nomnom_util/providers/cart.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/custom_loader.dart';
import 'package:nomnom_util/widgets/fly_to_cart_overlay.dart';
import 'package:nomnom_util/widgets/meal_inclusion_page.dart';
import 'package:nomnom_util/widgets/optiona_category_display.dart';
import 'package:nomnom_util/widgets/quantity_button.dart';
import 'package:nomnom_util/widgets/variation_display.dart';

class MenuDetails extends ConsumerStatefulWidget {
  const MenuDetails({
    super.key,
    required this.item,
    this.preorderDateTime,
    this.isReplacement = false,
    this.originalCartItem,
    this.replacementIndex,
    this.orderId,
    this.fromSearch = false,
    required this.api,
    required this.currentUserCartProvider,
    required this.currentUserProvider,
    required this.cartApi,
    required this.firestore,
    required this.areaSettingsProvider,
    required this.currentLocationProvider,
    required this.appApi,
    required this.prefs,
  });
  final MenuItem item;
  final DateTime? preorderDateTime;
  final bool isReplacement;
  final CartItem? originalCartItem;
  final int? replacementIndex;
  final String? orderId;
  final BaseStoreApi api;
  final StateNotifierProvider<CurrentUserNotifier, UserModel?>
  currentUserProvider;
  final StateNotifierProvider<CurrentUserCartNotifier, List<CartModel>>
  currentUserCartProvider;
  final BaseCartApi cartApi;
  final BaseFirebaseFirestoreSupport firestore;
  final StateProvider<AreaSetting?> areaSettingsProvider;
  final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider;
  final BaseAppApi appApi;
  final BaseDataCacher prefs;
  final bool fromSearch;

  @override
  ConsumerState<MenuDetails> createState() => _MenuDetailsState();
}

class _MenuDetailsState extends ConsumerState<MenuDetails> with ColorPalette {
  final TextEditingController _specialInstruction = TextEditingController();

  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _kFormVariation = GlobalKey<FormState>();
  final GlobalKey _cartButtonKey = GlobalKey();
  final GlobalKey _addToBagButtonKey = GlobalKey();
  MenuVariation? selectedVariant;

  late final detailsProvider = FutureProvider<MenuItemDetails?>((ref) async {
    final u = ref.read(widget.currentUserProvider);
    final res = await widget.api.getMenuDetails(
      widget.item.id,
      isPublic: u == null,
    );
    if (res == null) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return null;
    }
    final initList = [];
    for (int i = 0; i < res.optionCategories.length; i++) {
      initList.add(
        SelectedOptionCat(
          name: res.optionCategories[i].name,
          id: res.optionCategories[i].id,
          options: [],
        ),
      );
    }
    _selectedOptions = List.from(initList);

    setState(() {});
    return res;
  });
  bool checkOptionChoicesValid() {
    final details = ref.watch(detailsProvider);

    if (details.hasValue) {
      final detailsData = details.value;

      if (detailsData != null) {
        for (int i = 0; i < detailsData.optionCategories.length; i++) {
          final category = detailsData.optionCategories[i];
          final selectedOptions = _selectedOptions[i].options;

          // Skip validation if no options are required
          if (category.requiredOptionCount == 0) {
            continue;
          }

          // Return false immediately if the count doesn't match
          if (category.requiredOptionCount != selectedOptions.length) {
            Fluttertoast.showToast(
              msg:
                  "${category.name} requires ${category.requiredOptionCount}, selected ${selectedOptions.length}",
            );
            return false;
          }
        }
        // All categories are valid
        return true;
      }
    }

    // Return false if details are invalid

    return false;
  }

  int quantity = 1;
  List<SelectedOptionCat> _selectedOptions = [];

  @override
  void initState() {
    super.initState();
    if (widget.isReplacement && widget.originalCartItem != null) {
      quantity = widget.originalCartItem!.quantity;
      _specialInstruction.text = widget.originalCartItem!.instruction;
    }
  }

  Widget titler({
    Widget? icon,
    required String title,
    required String subtitle,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) => LayoutBuilder(
    builder: (context, c) {
      return Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: alignment == CrossAxisAlignment.start
                ? MainAxisAlignment.start
                : alignment == CrossAxisAlignment.center
                ? MainAxisAlignment.center
                : MainAxisAlignment.end,
            children: [
              icon ?? Container(),
              if (icon != null) ...{const Gap(5)},
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: c.maxWidth * .8),
                child: Tooltip(
                  message: title,
                  child: Text(
                    title.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: .5),
            ),
          ),
        ],
      );
    },
  );
  bool isLoading = false;
  bool _skipLoadingOverlay = false;

  @override
  void dispose() {
    _specialInstruction.dispose();
    super.dispose();
  }

  double calculateSubtotal(double markupRate, List<MenuVariation> variants) {
    double subtotal = 0;
    for (SelectedOptionCat cat in _selectedOptions) {
      if (cat.options.isNotEmpty) {
        for (SelectedOption opt in cat.options) {
          subtotal +=
              ((opt.suboption?.price ?? opt.price ?? 0) * (1 + markupRate))
                  .ceilToDouble();
        }
      }
    }
    double? variantPrice;
    if (selectedVariant == null && variants.isNotEmpty) {
      variantPrice = variants.map((e) => e.price).toList().reduce(min);
    } else {
      variantPrice = selectedVariant?.price;
    }
    final double markedUpPrice =
        ((variantPrice ?? widget.item.price) * (1 + markupRate)).ceilToDouble();
    return ((subtotal + markedUpPrice) * quantity).ceilToDouble();
  }

  CartItem? existingCartItem() {
    final List<CartModel> cart = ref.read(widget.currentUserCartProvider);
    final CartModel? merchant = cart
        .where((e) => e.merchant.id == widget.item.merchantId)
        .firstOrNull;
    if (merchant == null) {
      return null;
    }
    final CartItem? item = merchant.items.where((e) {
      final bool sameID = e.menuId == widget.item.id;
      final bool sameVariant = e.selectedVariant?.id == selectedVariant?.id;
      final bool sameOptions = e.options.isSameWith(_selectedOptions);
      return sameID && sameVariant && sameOptions;
    }).firstOrNull;

    return item;
  }

  Future<void> updateQuantity(CartItem item) async {
    final newQuantity = item.quantity + quantity;
    await widget.cartApi.updateQuantity(item.cartID, newQuantity);
  }

  Future<bool> addToCart({
    required double markUpRate,
    required List<MenuVariation> variants,
    required List<OptionCategory> optionCatChoices,
    bool skipLoadingOverlay = false,
  }) async {
    _skipLoadingOverlay = skipLoadingOverlay;
    // Safety timeout to prevent permanent loading state on device power management issues
    Timer? safetyTimer = Timer(Duration(seconds: 45), () {
      if (mounted && isLoading) {
        debugPrint('Safety timer triggered - resetting loading state');
        _setLoadingState(false);
        _showErrorToast("Operation timed out. Please try again.", isLong: true);
      }
    });

    try {
      if (widget.isReplacement && widget.originalCartItem != null) {
        final result = await _replaceCartItem(
          markUpRate: markUpRate,
          variants: variants,
          replaceItemId: widget.originalCartItem!.cartID,
        );
        safetyTimer.cancel();
        return result;
      } else {
        final CartItem? existing = existingCartItem();

        if (existing != null) {
          final result = await _updateExistingCartItem(existing);
          safetyTimer.cancel();
          return result;
        } else {
          final result = await _addNewCartItem(markUpRate, variants);
          safetyTimer.cancel();
          return result;
        }
      }
    } catch (e) {
      safetyTimer.cancel();
      debugPrint("Error in add To Cart: $e");
      _setLoadingState(false);

      // Provide more specific error messages for common issues
      String errorMessage = widget.isReplacement
          ? "An error occurred while replacing the item. Please try again."
          : "An error occurred while adding to cart. Please try again.";
      if (e is TimeoutException) {
        errorMessage =
            "Request timed out. Please check your connection and try again.";
      } else if (e is SocketException) {
        errorMessage = "Network error. Please check your internet connection.";
      }

      _showErrorToast(errorMessage, isLong: true);
      return false;
    }
  }

  Future<bool> _updateExistingCartItem(CartItem existing) async {
    if ((existing.quantity + quantity) > widget.item.quantityLimit) {
      _showErrorToast("Quantity limit reached");
      return false;
    }

    _setLoadingState(true);

    try {
      await updateQuantity(existing);
      await _refreshCartWithRetry(
        validateCart: (cart) => cart.any(
          (cartModel) => cartModel.items.any(
            (item) =>
                item.menuId == widget.item.id &&
                item.quantity >= existing.quantity + quantity,
          ),
        ),
      );

      _setLoadingState(false);
      _showSuccessToast(_successMessage);
      return true;
    } catch (e) {
      _setLoadingState(false);
      rethrow;
    }
  }

  Future<bool> _addNewCartItem(
    double markUpRate,
    List<MenuVariation> variants,
  ) async {
    if (!_validateForms()) {
      return false;
    }

    final double subtotal = calculateSubtotal(markUpRate, variants);
    _setLoadingState(true);

    try {
      final bool added = await widget.cartApi.add(
        markupRate: markUpRate,
        menuItemID: widget.item.id,
        instruction: _specialInstruction.text,
        quantity: quantity,
        subtotal: subtotal,
        optionSelection: _selectedOptions,
        orderType: 1,
        variationId: selectedVariant?.id,
      );

      if (added) {
        _specialInstruction.clear();
        await _refreshCartWithRetry(
          initialDelay: Duration(milliseconds: 300),
          validateCart: (cart) => cart.any(
            (cartModel) =>
                cartModel.items.any((item) => item.menuId == widget.item.id),
          ),
        );
        return true;
      } else {
        _showErrorToast(
          "Failed to add item to cart. Please try again.",
          isLong: true,
        );
        return false;
      }
    } finally {
      _setLoadingState(false);
    }
  }

  Future<bool> _replaceCartItem({
    double? markUpRate,
    List<MenuVariation>? variants,
    required int replaceItemId,
  }) async {
    if (!_validateForms()) {
      return false;
    }

    final double subtotal = calculateSubtotal(markUpRate!, variants!);
    _setLoadingState(true);

    try {
      debugPrint("ORDER ID ${widget.orderId}");
      // Then add the new item

      // final bool added = true;

      debugPrint(
        _selectedOptions
            .map((e) => "${e.name}: ${e.options.map((o) => o.name).join(", ")}")
            .join(" | "),
      );

      debugPrint(
        "Selected variant: ${selectedVariant != null ? selectedVariant!.name : "None"}",
      );

      final bool added = await widget.cartApi.add(
        markupRate: markUpRate,
        menuItemID: widget.item.id,
        instruction: _specialInstruction.text,
        quantity: quantity,
        subtotal: subtotal,
        optionSelection: _selectedOptions,
        orderType: 1,
        variationId: selectedVariant?.id,
        replaceItemId: replaceItemId,
        orderId: widget.orderId,
      );

      if (added) {
        _specialInstruction.clear();
        await _refreshCartWithRetry(
          initialDelay: Duration(milliseconds: 500),
          validateCart: (cart) => cart.any(
            (cartModel) => cartModel.items.any(
              (item) =>
                  item.menuId == widget.item.id &&
                  item.cartID != widget.originalCartItem!.cartID,
            ),
          ),
        );
        return true;
      } else {
        _showErrorToast(
          "Failed to replace item. Please try again.",
          isLong: true,
        );
        return false;
      }
    } finally {
      _setLoadingState(false);
    }
  }

  bool _validateForms() {
    if (_kFormVariation.currentState != null) {
      return (_kFormVariation.currentState?.validate() ?? true) &&
          (_kForm.currentState?.validate() ?? true);
    }
    return _kForm.currentState?.validate() ?? true;
  }

  Future<void> _refreshCartWithRetry({
    Duration? initialDelay,
    required bool Function(List<CartModel>) validateCart,
  }) async {
    final currentUser = ref.read(widget.currentUserProvider);
    if (currentUser == null) return;

    if (initialDelay != null) {
      await Future.delayed(initialDelay);
    }

    const maxRetries = 5; // Increase retries for power management scenarios
    List<CartModel> cart = [];

    for (int retries = 0; retries < maxRetries; retries++) {
      try {
        cart = await widget.firestore
            .getCart(userID: currentUser.id)
            .timeout(
              Duration(seconds: 10), // Add timeout for Firestore calls
              onTimeout: () => throw TimeoutException(
                'Firestore timeout during cart refresh',
                Duration(seconds: 10),
              ),
            );

        if (validateCart(cart)) {
          break;
        }
      } catch (e) {
        debugPrint('Cart refresh retry $retries failed: $e');
        // Continue to next retry unless it's the last one
        if (retries == maxRetries - 1) {
          debugPrint('All cart refresh retries failed');
        }
      }

      if (retries < maxRetries - 1) {
        // Exponential backoff with jitter for power management scenarios
        final delay = Duration(
          milliseconds: (500 * (retries + 1)) + (100 * retries),
        );
        await Future.delayed(delay);
      }
    }

    ref.read(widget.currentUserCartProvider.notifier).update(cart);
  }

  void _setLoadingState(bool loading) {
    if (!_skipLoadingOverlay) {
      setState(() {
        isLoading = loading;
      });
    }
  }

  void _showErrorToast(String message, {bool isLong = false}) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.CENTER,
      toastLength: isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(msg: message, gravity: ToastGravity.CENTER);
  }

  bool loading = false;

  String get _successMessage => widget.isReplacement
      ? "Item replaced successfully"
      : "Cart updated successfully";

  @override
  Widget build(BuildContext context) {
    final AreaSetting? settings = ref.watch(widget.areaSettingsProvider);
    final markUpRate = settings == null
        ? .03
        : settings.setting.markupRate / 100;
    final details = ref.watch(detailsProvider);
    final bool hasImage =
        !widget.item.photoUrl.contains("placeholder") ||
        !widget.item.photoUrl.contains("no_image");
    return PopScope(
      canPop: !isLoading,
      child: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          pinned: true,
                          expandedHeight: hasImage ? 300 : null,
                          flexibleSpace: hasImage
                              ? FlexibleSpaceBar(
                                  background: Hero(
                                    tag:
                                        "${widget.item.id}${widget.item.photoUrl}",
                                    child: CachedNetworkImage(
                                      imageUrl: selectedVariant == null
                                          ? widget.item.photoUrl
                                          : selectedVariant!.photoUrl.contains(
                                              "placeholder",
                                            )
                                          ? widget.item.photoUrl
                                          : selectedVariant!.photoUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                            'packages/nomnom_util/assets/images/customer.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                    ),
                                  ),
                                )
                              : null,
                          surfaceTintColor: Colors.white,
                          title: !hasImage
                              ? Text(
                                  widget.isReplacement
                                      ? "Replace Item"
                                      : "Menu Details",
                                )
                              : null,
                          titleTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SliverList.list(
                          children: [
                            details.when(
                              data: (data) {
                                debugPrint(
                                  "data.optionCategories ${data?.optionCategories.length}",
                                );
                                if (data == null) return Container();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Gap(20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              text: widget.item.name
                                                  .capitalizeWords()
                                                  .trimLeft(),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              children: [],
                                            ),
                                          ),

                                          if (widget
                                              .item
                                              .description
                                              .isNotEmpty) ...{
                                            Text(
                                              widget.item.description
                                                  .capitalize(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFFABABAB),
                                              ),
                                            ),
                                          },
                                          const Gap(10),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: textField.withValues(alpha: .5),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: titler(
                                              title:
                                                  widget.item.preparationDays ==
                                                      0
                                                  ? "${widget.item.preparationTime} min"
                                                  : "${widget.item.preparationDays} day${widget.item.preparationDays > 1 ? "s" : ""}",
                                              icon: Icon(
                                                Icons.access_time_outlined,
                                                color: darkGrey,
                                                size: 15,
                                              ),
                                              subtitle: "Prep. Time",
                                            ),
                                          ),
                                          Expanded(
                                            child: titler(
                                              title: data.category.name,
                                              alignment:
                                                  CrossAxisAlignment.center,
                                              icon: Icon(
                                                Icons.category,
                                                color: darkGrey,
                                                size: 15,
                                              ),
                                              subtitle: "Category",
                                            ),
                                          ),
                                          Expanded(
                                            child: titler(
                                              alignment: CrossAxisAlignment.end,
                                              title:
                                                  "${widget.item.quantityLimit}",
                                              icon: Icon(
                                                Icons.countertops,
                                                color: darkGrey,
                                                size: 15,
                                              ),
                                              subtitle: "Limit per order",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (data.typedMenuItem.isNotEmpty) ...{
                                      const Gap(15),
                                      MealInclusionView(
                                        items: data.typedMenuItem,
                                        placeholderImage:
                                            data.merchant.photoUrl,
                                      ),
                                    },
                                    if (data.itemVariation != null &&
                                        data
                                            .itemVariation!
                                            .variations
                                            .isNotEmpty) ...{
                                      const Gap(15),
                                      Form(
                                        key: _kFormVariation,
                                        child: VariationDisplay(
                                          model: data.itemVariation!,
                                          optionChoices:
                                              data.itemVariation!.variations,
                                          onChanged: (MenuVariation? value) {
                                            setState(() {
                                              selectedVariant = value;
                                            });
                                          },
                                          markup: markUpRate,
                                          placeholderImage:
                                              data.merchant.photoUrl,
                                        ),
                                      ),
                                    },
                                    if (data.optionCategories.isNotEmpty) ...{
                                      const Gap(15),
                                      Form(
                                        key: _kForm,
                                        child: ListView.separated(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 0,
                                            vertical: 0,
                                          ),
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (_, i) {
                                            final OptionCategory cat =
                                                data.optionCategories[i];

                                            return OptionCategoryDisplay(
                                              markup: markUpRate,
                                              optionChoices: cat.options,
                                              requiredCount:
                                                  cat.requiredOptionCount,
                                              placeholderImage:
                                                  data.merchant.photoUrl,
                                              model: cat,
                                              onChanged: (va) {
                                                setState(() {
                                                  _selectedOptions[i] =
                                                      SelectedOptionCat(
                                                        name: cat.name,
                                                        id: cat.id,
                                                        options: va,
                                                      );
                                                });
                                                _kForm.currentState!.validate();
                                              },
                                              areaSettingsProvider:
                                                  widget.areaSettingsProvider,
                                            );
                                          },
                                          separatorBuilder: (_, i) =>
                                              const Gap(15),
                                          itemCount: data.optionCategories
                                              .where(
                                                (e) => e.options.isNotEmpty,
                                              )
                                              .length,
                                        ),
                                      ),
                                    },
                                    const Gap(10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Special Instructions",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Gap(10),
                                          TextField(
                                            cursorHeight: 14,
                                            controller: _specialInstruction,
                                            maxLines: 3,
                                            keyboardType:
                                                TextInputType.multiline,
                                            decoration: InputDecoration(
                                              hintText: "e.g. no mayo",
                                              hintStyle: TextStyle(
                                                fontSize: 13,
                                                color: grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                              error: (error, s) => Container(),
                              loading: () => SizedBox(
                                height: 300,
                                child: CustomLoader(color: darkGrey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  details.when(
                    data: (data) {
                      if (data == null) {
                        return Container();
                      }
                      return SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const Gap(10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Subtotal:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    calculateSubtotal(
                                      markUpRate,
                                      data.itemVariation?.variations ?? [],
                                    ).toAmount(),
                                    style: TextStyle(
                                      fontFamily: "",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(5),
                              Row(
                                children: [
                                  QuantityButton(
                                    withBox: true,
                                    limit: widget.item.quantityLimit,
                                    value: quantity,
                                    callback: (int i) {
                                      setState(() {
                                        quantity = i;
                                      });
                                    },
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: details.when(
                                      data: (data) {
                                        return MaterialButton(
                                          key: _addToBagButtonKey,
                                          elevation: 0,
                                          height: 50,
                                          disabledColor: Colors.grey,
                                          onPressed:
                                              data == null || !data.isAvailable
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    debugPrint("loading true");
                                                    loading = true;
                                                  });
                                                  final navigator =
                                                      Navigator.of(context);

                                                  if (!checkOptionChoicesValid()) {
                                                    debugPrint(
                                                      "Option choices are not valid",
                                                    );
                                                    return;
                                                  }
                                                  if (widget.isReplacement) {
                                                    debugPrint(
                                                      "Replacing item in cart",
                                                    );
                                                    debugPrint(
                                                      "Selected variant: ${data.itemVariation?.variations}",
                                                    );

                                                    debugPrint(
                                                      "Selected optionCategories: ${data.optionCategories}",
                                                    );

                                                    final isSuccess =
                                                        await addToCart(
                                                          markUpRate:
                                                              markUpRate,
                                                          variants:
                                                              data
                                                                  .itemVariation
                                                                  ?.variations ??
                                                              [],
                                                          optionCatChoices: data
                                                              .optionCategories,
                                                          skipLoadingOverlay:
                                                              true,
                                                        );

                                                    debugPrint(
                                                      "Successfully replace item: $isSuccess",
                                                    );

                                                    if (isSuccess) {
                                                      if (mounted) {
                                                        navigator.pop();
                                                      }
                                                      if (widget.fromSearch) {
                                                        navigator.pop();
                                                      }
                                                    }
                                                  } else {
                                                    FlyToCartOverlay.showAnimation(
                                                      context: context,
                                                      itemWidget:
                                                          CachedNetworkImage(
                                                            imageUrl:
                                                                selectedVariant !=
                                                                    null
                                                                ? selectedVariant!
                                                                      .photoUrl
                                                                : widget
                                                                      .item
                                                                      .photoUrl,
                                                            fit: BoxFit.cover,
                                                          ),
                                                      cartButtonKey:
                                                          _cartButtonKey,
                                                      sourceKey:
                                                          _addToBagButtonKey,
                                                      onComplete: () async {
                                                        setState(() {
                                                          debugPrint(
                                                            "loading true",
                                                          );
                                                          loading = true;
                                                        });
                                                        final navigator =
                                                            Navigator.of(
                                                              context,
                                                            );

                                                        await addToCart(
                                                          markUpRate:
                                                              markUpRate,
                                                          variants:
                                                              data
                                                                  .itemVariation
                                                                  ?.variations ??
                                                              [],
                                                          optionCatChoices: data
                                                              .optionCategories,
                                                          skipLoadingOverlay:
                                                              true,
                                                        ).then((
                                                          bool isSuccess,
                                                        ) {
                                                          debugPrint(
                                                            "Successfully added to cart: $isSuccess",
                                                          );

                                                          if (!mounted) return;
                                                          navigator.pop();

                                                          if (widget
                                                              .fromSearch) {
                                                            navigator.pop();
                                                          }
                                                        });
                                                      },
                                                    );
                                                  }
                                                },
                                          color: orangePalette,
                                          child: Center(
                                            child: loading
                                                ? CircularProgressIndicator.adaptive(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  )
                                                : data!.isAvailable
                                                ? Text(
                                                    widget.isReplacement
                                                        ? "Replace Item"
                                                        : "Add to bag",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Text(
                                                    "Item not available",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        );
                                      },
                                      error: (error, s) => Container(),
                                      loading: () => Container(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                            ],
                          ),
                        ),
                      );
                    },
                    error: (e, s) => Container(),
                    loading: () => Container(),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) ...{
            Positioned.fill(
              child: Material(
                color: Colors.black.withValues(alpha: .5),
                child: Center(
                  child: CustomLoader(label: "Adding to cart, please wait"),
                ),
              ),
            ),
          },
        ],
      ),
    );
  }
}
