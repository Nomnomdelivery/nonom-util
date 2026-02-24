import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomnom_util/api/base_app_api.dart';
import 'package:nomnom_util/api/base_data_cacher.dart';
import 'package:nomnom_util/api/base_firebase_firestore_support.dart';
import 'package:nomnom_util/api/base_store_api.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/menu/menu_item.dart';
import 'package:nomnom_util/models/menu/raw_category.dart';
import 'package:nomnom_util/models/merchant/merchant_with_city.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/debounce_text_field.dart';
import 'package:nomnom_util/widgets/search_by_store.dart';

class SearchMenuPage extends ConsumerStatefulWidget {
  const SearchMenuPage({
    super.key,
    required this.classification,
    required this.type, // 0 = class, 1= store only, 2=item only
    required this.keyword,
    this.merchantID,
    required this.api,
    required this.appApi,
    required this.prefs,
    required this.currentLocationProvider,
    required this.areaSettingsProvider,
    required this.ffs,
    required this.city,
  });
  final RawCategory? classification;
  final int type;
  final String? keyword;
  final int? merchantID;
  final BaseStoreApi api;
  final BaseAppApi appApi;
  final BaseDataCacher prefs;
  final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider;
  final StateProvider<AreaSetting?> areaSettingsProvider;
  final BaseFirebaseFirestoreSupport ffs;
  final String city;
  @override
  ConsumerState<SearchMenuPage> createState() => _SearchMenuPageState();
}

class _SearchMenuPageState extends ConsumerState<SearchMenuPage>
    with ColorPalette {
  late final _keywordProvider = StateProvider<String>(
    (ref) => widget.keyword ?? "",
  );

  // Cache providers to store previous results
  late final _cachedMenuProvider = StateProvider<List<MenuItem>?>(
    (ref) => null,
  );
  late final _cachedStoreProvider = StateProvider<List<MerchantWithCity>?>(
    (ref) => null,
  );
  // late String keyword = widget.keyword ?? "";
  // late final T
  // List<Merchant> _merchantDisplay = [];
  late final dataProvider = FutureProvider<List<MenuItem>>((ref) async {
    // Return cached data immediately if available
    final cachedData = ref.read(_cachedMenuProvider);

    if (widget.type == 2 ||
        (widget.type == 3 && widget.keyword != null) ||
        widget.type == -1) {
      final key = ref.watch(_keywordProvider);

      // Setup cache key for persistent storage

      final cacheKey = widget.type == -1
          ? 'search_menu_public_$key'
          : 'search_menu_${key}_${widget.merchantID ?? 'all'}';

      // Try to get cached data from prefs for immediate display
      final cachedString = widget.prefs.getCacheString(cacheKey);
      if (cachedString != null && cachedData == null) {
        try {
          final List cachedList = jsonDecode(cachedString) as List;
          final cached = cachedList.map((e) => MenuItem.fromJson(e)).toList();
          Future.microtask(
            () => ref.read(_cachedMenuProvider.notifier).state = cached,
          );
        } catch (_) {}
      }

      // Fetch fresh data
      List<MenuItem> freshData;
      if (widget.type == -1) {
        freshData = await widget.api.publicSearchMenu(keyword: key);
      } else {
        freshData = await widget.api.searchMenu(
          keyword: key,
          merchantID: widget.merchantID,
        );
      }

      // Update cache with fresh data (deferred to avoid modifying providers while building)
      Future.microtask(
        () => ref.read(_cachedMenuProvider.notifier).state = freshData,
      );

      // Update persistent cache
      await widget.prefs.setCacheString(
        cacheKey,
        jsonEncode(freshData.map((e) => e.toJson()).toList()),
      );

      return freshData;
    }
    return cachedData ?? [];
  });

  // late final storeProvider = FutureProvider<List<MerchantWithCity>>((
  //   ref,
  // ) async {
  //   // Return cached data immediately if available
  //   final cachedData = ref.read(_cachedStoreProvider);

  //   if (widget.type == -1) {
  //     final key = ref.watch(_keywordProvider);

  //     final cacheKey = 'search_store_public_$key';
  //     final cachedString = widget.prefs.getCacheString(cacheKey);
  //     if (cachedString != null && cachedData == null) {
  //       try {
  //         final List cachedList = jsonDecode(cachedString) as List;
  //         final cached = cachedList
  //             .map((e) => MerchantWithCity.fromJson(e))
  //             .toList();
  //         ref.read(_cachedStoreProvider.notifier).state = cached;
  //       } catch (_) {}
  //     }

  //     final freshData = await widget.api.publicSearch(
  //       serviceID: 0,
  //       keyword: key,
  //     );
  //     ref.read(_cachedStoreProvider.notifier).state = freshData;

  //     // Update persistent cache
  //     await widget.prefs.setCacheString(
  //       cacheKey,
  //       jsonEncode(freshData.map((e) => e.toJson()).toList()),
  //     );

  //     return freshData;
  //   }

  //   final city = widget.city;
  //   final keyword = ref.watch(_keywordProvider);
  //   final cacheKey = widget.classification != null && widget.type == 1
  //       ? 'search_store_class_${widget.classification!.id}_$city'
  //       : 'search_store_${keyword}_$city';

  //   // Try to get cached data from prefs for immediate display
  //   final cachedString = widget.prefs.getCacheString(cacheKey);
  //   if (cachedString != null && cachedData == null) {
  //     try {
  //       final List cachedList = jsonDecode(cachedString) as List;
  //       final cached = cachedList
  //           .map((e) => MerchantWithCity.fromJson(e))
  //           .toList();
  //       Future.microtask(
  //         () => ref.read(_cachedStoreProvider.notifier).state = cached,
  //       );
  //     } catch (_) {}
  //   }

  //   // Fetch fresh data
  //   List<MerchantWithCity> freshData;
  //   if (widget.classification != null && widget.type == 1) {
  //     if (widget.classification!.id == 1) {
  //       freshData = await widget.appApi.fastfood(city);
  //     } else {
  //       freshData = await widget.appApi.searchByClass(
  //         widget.classification!.id,
  //       );
  //     }
  //   } else {
  //     freshData = await widget.api.search(
  //       keyword: keyword,
  //       city: city,
  //       serviceID: 0,
  //     );
  //   }

  //   // Update cache with fresh data (deferred to avoid modifying providers while building)
  //   Future.microtask(
  //     () => ref.read(_cachedStoreProvider.notifier).state = freshData,
  //   );

  //   // Update persistent cache
  //   await widget.prefs.setCacheString(
  //     cacheKey,
  //     jsonEncode(freshData.map((e) => e.toJson()).toList()),
  //   );

  //   return freshData;
  // });

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    super.initState();
  }

  String title() {
    if (widget.classification == null && widget.type == 2) {
      return "Menu";
    } else if (widget.classification != null) {
      return widget.classification!.name.capitalize();
    } else if (widget.type == 3) {
      return "";
    } else {
      return "Restaurants";
    }
  }

  bool showTextfield() {
    return widget.keyword != null &&
        widget.classification == null &&
        widget.type != 0;
  }

  @override
  Widget build(BuildContext context) {
    final keyword = ref.watch(_keywordProvider);
    final menu = ref.watch(dataProvider);
    // final store = ref.watch(storeProvider);
    // final menu = ref.watch(dataProvider);
    final Size size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: ColorPalette.sscaffoldColor,
        appBar: AppBar(
          backgroundColor: ColorPalette.sscaffoldColor,
          surfaceTintColor: ColorPalette.sscaffoldColor,
          title: Text(
            "Search ${title()}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: DebouncedTextField(
                onDebouncedChange: (text) {
                  ref.read(_keywordProvider.notifier).update((r) => text);
                  // ref.invalidate(storeProvider);
                },
                hintText: "Search",
                labelText: "Search",
                initText: keyword,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              // Show loader when both are loading
              if ((widget.type == 1 || widget.type == 3) && menu.isLoading) ...{
                SizedBox(
                  height: size.height * .4,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
              } else ...{
                if (widget.type != 1) ...{
                  // Text("MENU"),
                  menu.when(
                    data: (menuData) {
                      if (menuData.isEmpty) {
                        return Container();
                      }
                      // return BuildSearchByMenu(
                      //   dataProvider: dataProvider,
                      //   isWholePage: true,
                      //   areaSettingsProvider: widget.areaSettingsProvider,
                      // );
                      return Container();
                    },
                    error: (_, s) => Container(),
                    loading: () =>
                        Center(child: CircularProgressIndicator.adaptive()),
                  ),
                },
                // if (widget.type != 2) ...{
                //   store.when(
                //     data: (storeData) {
                //       if (storeData.isEmpty) {
                //         return Container();
                //       }
                //       return BuildSearchByStore(
                //         dataProvider: storeProvider,
                //         isWholePage: true,
                //         ffs: widget.ffs,
                //       );
                //     },
                //     error: (_, s) => Container(),
                //     loading: () =>
                //         Center(child: CircularProgressIndicator.adaptive()),
                //   ),
                // },
                // Show empty state only when both menu and store are empty
                if ((widget.type == 1 || widget.type == 3) &&
                    menu.hasValue &&
                    (menu.value?.isEmpty ?? true)) ...{
                  SizedBox(
                    height: size.height * .4,
                    child: Center(child: Text("No restaurant or menu found")),
                  ),
                },
              },
            ],
          ),
        ),
      ),
    );
  }
}
