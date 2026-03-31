import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomnom_util/api/base_app_api.dart';
import 'package:nomnom_util/api/base_cart_api.dart';
import 'package:nomnom_util/api/base_data_cacher.dart';
import 'package:nomnom_util/api/base_firebase_firestore_support.dart';
import 'package:nomnom_util/api/base_store_api.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/cart.dart';
import 'package:nomnom_util/models/cart_item.dart';
import 'package:nomnom_util/models/categorized_menu.dart';
import 'package:nomnom_util/models/menu/menu_result.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/models/user_model.dart';
import 'package:nomnom_util/providers/cart.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/menu_card.dart';
import 'package:nomnom_util/widgets/menu_details.dart';
import 'package:nomnom_util/widgets/search_menu_page.dart';

class MenuReplacementContent extends ConsumerStatefulWidget {
  const MenuReplacementContent({
    super.key,
    required this.merchantId,
    required this.merchantName,
    required this.itemToReplace,
    required this.scrollController,
    required this.orderId,
    required this.menuProvider,
    required this.areaSettingsProvider,
    required this.api,
    required this.currentUserCartProvider,
    required this.cartApi,
    required this.firestore,
    required this.currentLocationProvider,
    required this.currentUserProvider,
    required this.appApi,
    required this.prefs,
    required this.city,
  });

  final int merchantId;
  final String merchantName;
  final CartItem itemToReplace;
  final ScrollController scrollController;
  final String? orderId;
  final FutureProvider<MenuResult> menuProvider;
  final BaseStoreApi api;
  final StateNotifierProvider<CurrentUserCartNotifier, List<CartModel>>
  currentUserCartProvider;
  final BaseCartApi cartApi;
  final BaseFirebaseFirestoreSupport firestore;
  final StateProvider<AreaSetting?> areaSettingsProvider;
  final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider;
  final StateNotifierProvider<CurrentUserNotifier, UserModel?>
  currentUserProvider;
  final BaseAppApi appApi;
  final BaseDataCacher prefs;
  final String city;

  @override
  ConsumerState<MenuReplacementContent> createState() =>
      _MenuReplacementContentState();
}

class _MenuReplacementContentState extends ConsumerState<MenuReplacementContent>
    with TickerProviderStateMixin, ColorPalette {
  late TabController _tabController;
  final List<GlobalKey> _sectionKeys = [];

  @override
  void initState() {
    super.initState();

    // Initialize with a default controller
    _tabController = TabController(length: 1, vsync: this);

    // Initialize the menu provider
  }

  @override
  Widget build(BuildContext context) {
    final menuResult = ref.watch(widget.menuProvider);
    final AreaSetting? settings = ref.watch(widget.areaSettingsProvider);
    final markUpRate = settings == null
        ? .05
        : settings.setting.markupRate / 100;

    final mainContentSlivers = menuResult.when<List<Widget>>(
      data: (data) {
        // Create tabs and sections
        final List<Tab> tabs = [];
        final List<CategorizedMenu> categories = [];

        if (data.popularItems.isNotEmpty) {
          tabs.add(Tab(text: "Popular"));
        }

        for (var category in data.categorizedMenu) {
          tabs.add(Tab(text: category.name.capitalizeWords()));
          categories.add(category);
        }

        // Initialize tab controller if not already done
        if (_tabController.length != tabs.length) {
          _tabController.dispose();
          _tabController = TabController(length: tabs.length, vsync: this);
          // Clear and rebuild section keys
          _sectionKeys.clear();
          for (int i = 0; i < tabs.length; i++) {
            _sectionKeys.add(GlobalKey());
          }
        }

        return [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search ${widget.merchantName} menu...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchMenuPage(
                        keyword: "",
                        classification: null,
                        type: -1,
                        merchantID: widget.merchantId,
                        api: widget.api,
                        appApi: widget.appApi,
                        prefs: widget.prefs,
                        currentLocationProvider: widget.currentLocationProvider,
                        areaSettingsProvider: widget.areaSettingsProvider,
                        ffs: widget.firestore,
                        city: widget.city,
                        cartApi: widget.cartApi,
                        currentUserCartProvider: widget.currentUserCartProvider,
                        currentUserProvider: widget.currentUserProvider,
                        orderId: widget.orderId!,
                        originalCartItem: widget.itemToReplace,
                      ),
                    ),
                  );
                },
                readOnly: true,
              ),
            ),
          ),

          // Category tabs
          if (tabs.isNotEmpty)
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabSliverDelegate(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: ColorPalette.orange,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: ColorPalette.orange,
                    tabAlignment: TabAlignment.start,
                    tabs: tabs,
                    onTap: (index) {
                      if (index < _sectionKeys.length) {
                        Scrollable.ensureVisible(
                          _sectionKeys[index].currentContext!,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ),
            ),

          // Menu content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Popular items section
                if (data.popularItems.isNotEmpty) ...[
                  Container(
                    key: _sectionKeys.isNotEmpty ? _sectionKeys[0] : null,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.whatshot, color: ColorPalette.orange),
                            SizedBox(width: 8),
                            Text(
                              'Popular Items',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: data.popularItems.length,
                          separatorBuilder: (_, i) =>
                              Divider(color: Colors.grey.shade300),
                          itemBuilder: (_, i) {
                            final item = data.popularItems[i];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MenuDetails(
                                      item: item,
                                      preorderDateTime: null,
                                      isReplacement: true,
                                      originalCartItem: widget.itemToReplace,
                                      orderId: widget.orderId,
                                      api: widget.api,
                                      currentUserCartProvider:
                                          widget.currentUserCartProvider,
                                      currentUserProvider:
                                          widget.currentUserProvider,
                                      cartApi: widget.cartApi,
                                      firestore: widget.firestore,
                                      areaSettingsProvider:
                                          widget.areaSettingsProvider,
                                      currentLocationProvider:
                                          widget.currentLocationProvider,
                                      appApi: widget.appApi,
                                      prefs: widget.prefs,
                                    ),
                                  ),
                                );
                              },
                              child: AbsorbPointer(
                                child: MenuCard(
                                  item: item,
                                  preorderDateTime: null,
                                  markupRate: markUpRate,
                                  currentUserCartProvider:
                                      widget.currentUserCartProvider,
                                  cartApi: widget.cartApi,
                                  firestore: widget.firestore,
                                  areaSettingsProvider:
                                      widget.areaSettingsProvider,
                                  currentLocationProvider:
                                      widget.currentLocationProvider,
                                  api: widget.api,
                                  currentUserProvider:
                                      widget.currentUserProvider,
                                  appApi: widget.appApi,
                                  prefs: widget.prefs,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(height: 8, color: Colors.grey.shade100),
                ],

                // Category sections
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, i) =>
                      Container(height: 8, color: Colors.grey.shade100),
                  itemBuilder: (_, i) {
                    final category = categories[i];
                    final keyIndex = data.popularItems.isNotEmpty ? i + 1 : i;

                    return Container(
                      key: keyIndex < _sectionKeys.length
                          ? _sectionKeys[keyIndex]
                          : null,
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name.capitalizeWords(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: category.items.length,
                            separatorBuilder: (_, i) =>
                                Divider(color: Colors.grey.shade300),
                            itemBuilder: (_, itemIndex) {
                              final item = category.items[itemIndex];
                              return GestureDetector(
                                onTap: () async {
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close bottom sheet first
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MenuDetails(
                                        item: item,
                                        preorderDateTime: null,
                                        isReplacement: true,
                                        originalCartItem: widget.itemToReplace,
                                        orderId: widget.orderId,
                                        api: widget.api,
                                        currentUserCartProvider:
                                            widget.currentUserCartProvider,
                                        currentUserProvider:
                                            widget.currentUserProvider,
                                        cartApi: widget.cartApi,
                                        firestore: widget.firestore,
                                        areaSettingsProvider:
                                            widget.areaSettingsProvider,
                                        currentLocationProvider:
                                            widget.currentLocationProvider,
                                        appApi: widget.appApi,
                                        prefs: widget.prefs,
                                      ),
                                    ),
                                  );
                                },
                                child: AbsorbPointer(
                                  child: MenuCard(
                                    item: item,
                                    preorderDateTime: null,
                                    markupRate: markUpRate,
                                    api: widget.api,
                                    currentUserCartProvider:
                                        widget.currentUserCartProvider,
                                    cartApi: widget.cartApi,
                                    firestore: widget.firestore,
                                    areaSettingsProvider:
                                        widget.areaSettingsProvider,
                                    currentLocationProvider:
                                        widget.currentLocationProvider,
                                    currentUserProvider:
                                        widget.currentUserProvider,
                                    appApi: widget.appApi,
                                    prefs: widget.prefs,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ];
      },
      loading: () => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: ColorPalette.orange),
                SizedBox(height: 16),
                Text('Loading menu...'),
              ],
            ),
          ),
        ),
      ],
      error: (error, stack) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Unable to load menu'),
                TextButton(
                  onPressed: () => ref.invalidate(widget.menuProvider),
                  child: Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                        'Replace "${widget.itemToReplace.menuName}"',
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
            ],
          ),
        ),
        ...mainContentSlivers,
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _TabSliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabSliverDelegate({required this.child});

  @override
  double get minExtent => 49.0;

  @override
  double get maxExtent => 49.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabSliverDelegate oldDelegate) {
    return true;
  }
}
