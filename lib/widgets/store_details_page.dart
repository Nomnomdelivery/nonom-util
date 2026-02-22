// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nomnom_util/api/base_app_api.dart';
// import 'package:nomnom_util/api/base_cart_api.dart';
// import 'package:nomnom_util/api/base_data_cacher.dart';
// import 'package:nomnom_util/api/base_firebase_firestore_support.dart';
// import 'package:nomnom_util/api/base_store_api.dart';
// import 'package:nomnom_util/extensions/string_capitalize.dart';
// import 'package:nomnom_util/models/area_setting.dart';
// import 'package:nomnom_util/models/cart.dart';
// import 'package:nomnom_util/models/categorized_menu.dart';
// import 'package:nomnom_util/models/menu/menu_item.dart';
// import 'package:nomnom_util/models/menu/menu_result.dart';
// import 'package:nomnom_util/models/merchant/merchant_with_city.dart';
// import 'package:nomnom_util/models/promo.dart';
// import 'package:nomnom_util/models/store_feedback.dart';
// import 'package:nomnom_util/models/user_address.dart';
// import 'package:nomnom_util/models/user_model.dart';
// import 'package:nomnom_util/providers/cart.dart';
// import 'package:nomnom_util/providers/user_provider.dart';
// import 'package:nomnom_util/widgets/custom_loader.dart';
// import 'package:nomnom_util/widgets/store_details_content_page.dart';
// import 'package:nomnom_util/widgets/store_menu_details_page.dart';

// class GlobalKeySections {
//   final int index;
//   final GlobalKey key;
//   final String name;
//   const GlobalKeySections({
//     required this.index,
//     required this.key,
//     required this.name,
//   });
// }

// class StoreDetailsPage extends ConsumerStatefulWidget {
//   const StoreDetailsPage({
//     super.key,
//     required this.model,
//     this.deliveryDate,
//     required this.api,
//     required this.currentUserProvider,
//     required this.areaSettingsProvider,
//     required this.appApi,
//     required this.currentUserCartProvider,
//     required this.cartApi,
//     required this.firestore,
//     required this.currentLocationProvider,
//     required this.prefs,
//   });
//   final MerchantWithCity model;
//   final DateTime? deliveryDate;
//   final BaseStoreApi api;
//   final StateNotifierProvider<CurrentUserNotifier, UserModel?>
//   currentUserProvider;
//   final StateProvider<AreaSetting?> areaSettingsProvider;
//   final BaseAppApi appApi;
//   final StateNotifierProvider<CurrentUserCartNotifier, List<CartModel>>
//   currentUserCartProvider;
//   final BaseCartApi cartApi;
//   final BaseFirebaseFirestoreSupport firestore;
//   final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
//   currentLocationProvider;
//   final BaseDataCacher prefs;
//   @override
//   ConsumerState<StoreDetailsPage> createState() => _StoreDetailsPageState();
// }

// class _StoreDetailsPageState extends ConsumerState<StoreDetailsPage>
//     with TickerProviderStateMixin {
//   List<Tab> menutabs = [];
//   List<MenuItem> uncategorizedMenu = [];
//   List<CategorizedMenu> categorizedMenu = [];
//   final List<GlobalKeySections> _sections = [];

//   late final ratingProvider = FutureProvider<StoreFeedback>((ref) async {
//     final u = ref.read(widget.currentUserProvider);
//     final result = await widget.api.getRatingsAndFeedback(
//       widget.model.id,
//       isPublic: u == null,
//     );
//     return result;
//   });
//   late final promoProvider = FutureProvider<List<PromoModel>>((ref) async {
//     final u = ref.read(widget.currentUserProvider);
//     return await widget.api.getOngoingPromo(
//       ids: [widget.model.id],
//       isPublic: u == null,
//     );
//   });
//   late final dataProvider = FutureProvider<MenuResult>((ref) async {
//     final u = ref.read(widget.currentUserProvider);
//     final result = await widget.api.getMenu(
//       widget.model.id,
//       isPublic: u == null,
//     );
//     generateTabsAndSections(result);

//     return result;
//   });

//   Widget _buildContent(int index, MenuResult data) {
//     if (index == 0) {
//       return StoreDetailsMenuPage(
//         categorizedMenu: categorizedMenu,
//         uncategoriedItems: uncategorizedMenu,
//         preorderDateTime: widget.deliveryDate,
//         onRefresh: () {},
//         model: widget.model,
//         tabs: menutabs,
//         sections: _sections,
//         changePage: () {
//           _controller.animateTo(1);
//         },
//         dataProvider: dataProvider,
//         api: widget.api,
//         currentUserProvider: widget.currentUserProvider,
//         areaSettingsProvider: widget.areaSettingsProvider,
//         currentUserCartProvider: widget.currentUserCartProvider,
//         cartApi: widget.cartApi,
//         firestore: widget.firestore,
//         currentLocationProvider: widget.currentLocationProvider,
//         appApi: widget.appApi,
//         prefs: widget.prefs,
//       );
//     } else {
//       return StoreDetailsContentPage(
//         changePage: () {
//           _controller.animateTo(0);
//         },
//         promoProvider: promoProvider,
//         model: widget.model,
//         rateProvider: ratingProvider,
//         areaSettingsProvider: widget.areaSettingsProvider,
//         api: widget.api,
//         currentUserProvider: widget.currentUserProvider,
//       );
//     }
//   }

//   void generateTabsAndSections(MenuResult result) {
//     setState(() {
//       menutabs.clear();
//       _sections.clear();
//     });
//     if (result.popularItems.isNotEmpty) {
//       menutabs.add(Tab(text: "Popular"));
//       _sections.add(
//         GlobalKeySections(index: 0, key: GlobalKey(), name: "Popular"),
//       );
//     }
//     result.categorizedMenu.sort((a, b) => a.name.compareTo(b.name));
//     if (result.categorizedMenu.isNotEmpty) {
//       int index = result.popularItems.isEmpty ? 0 : 1;
//       for (CategorizedMenu cats in result.categorizedMenu) {
//         if (cats.name.toLowerCase() == "uncategorized") {
//           setState(() {
//             uncategorizedMenu.addAll(cats.items);
//           });
//         } else {
//           final GlobalKey nKey = GlobalKey();
//           _sections.add(
//             GlobalKeySections(
//               index: index,
//               key: nKey,
//               name: cats.name.capitalizeWords(),
//             ),
//           );
//           menutabs.add(Tab(text: cats.name.capitalizeWords()));
//           categorizedMenu.add(cats);
//           index += 1;
//           setState(() {});
//         }
//       }
//     }
//   }

//   late final TabController _controller = TabController(length: 2, vsync: this);
//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(() {
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     _controller.removeListener(() {});
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final res = ref.watch(dataProvider);
//     final Size size = MediaQuery.of(context).size;
//     return res.when(
//       data: (data) => _buildContent(_controller.index, data),
//       error: (e, s) => Container(),
//       loading: () => Material(
//         color: Colors.transparent,
//         elevation: 0,
//         child: Container(
//           color: Colors.white,
//           width: size.width,
//           height: size.height,
//           child: Center(
//             child: CustomLoader(
//               color: Colors.black.withValues(alpha: .5),
//               label: "Loading details",
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
