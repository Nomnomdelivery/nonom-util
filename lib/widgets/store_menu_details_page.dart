import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/api/base_app_api.dart';
import 'package:nomnom_util/api/base_cart_api.dart';
import 'package:nomnom_util/api/base_data_cacher.dart';
import 'package:nomnom_util/api/base_firebase_firestore_support.dart';
import 'package:nomnom_util/api/base_store_api.dart';
import 'package:nomnom_util/extensions/color_ext.dart';
import 'package:nomnom_util/extensions/color_opacity.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/cart.dart';
import 'package:nomnom_util/models/cart_button.dart';
import 'package:nomnom_util/models/categorized_menu.dart';
import 'package:nomnom_util/models/menu/menu_item.dart';
import 'package:nomnom_util/models/menu/menu_result.dart';
import 'package:nomnom_util/models/merchant/merchant_details.dart';
import 'package:nomnom_util/models/merchant/merchant_with_city.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/models/user_model.dart';
import 'package:nomnom_util/providers/cart.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/back_circle_button.dart';
import 'package:nomnom_util/widgets/custom_loader.dart';
import 'package:nomnom_util/widgets/debounce_text_field.dart';
import 'package:nomnom_util/widgets/menu_card.dart';
import 'package:nomnom_util/widgets/popular_card.dart';
import 'package:nomnom_util/widgets/refresh_widget.dart';
import 'package:nomnom_util/widgets/search_menu_page.dart';
import 'package:nomnom_util/widgets/store_details_page.dart';
import 'package:nomnom_util/widgets/store_header.dart';

class StoreDetailsMenuPage extends ConsumerStatefulWidget {
  const StoreDetailsMenuPage({
    super.key,
    required this.model,
    required this.changePage,
    required this.onRefresh,
    required this.dataProvider,
    this.preorderDateTime,
    required this.uncategoriedItems,
    required this.sections,
    required this.categorizedMenu,
    required this.tabs,
    required this.api,
    required this.currentUserProvider,
    required this.areaSettingsProvider,
    required this.currentUserCartProvider,
    required this.cartApi,
    required this.firestore,
    required this.currentLocationProvider,
    required this.appApi,
    required this.prefs,
  });
  final MerchantWithCity model;
  final VoidCallback changePage;
  final FutureProvider<MenuResult> dataProvider;
  final List<Tab> tabs;
  final List<CategorizedMenu> categorizedMenu;
  final List<MenuItem> uncategoriedItems;
  final DateTime? preorderDateTime;
  final Function() onRefresh;
  final List<GlobalKeySections> sections;
  final BaseStoreApi api;
  final StateNotifierProvider<CurrentUserNotifier, UserModel?>
  currentUserProvider;

  final StateProvider<AreaSetting?> areaSettingsProvider;

  final StateNotifierProvider<CurrentUserCartNotifier, List<CartModel>>
  currentUserCartProvider;
  final BaseCartApi cartApi;
  final BaseFirebaseFirestoreSupport firestore;
  final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider;

  final BaseAppApi appApi;
  final BaseDataCacher prefs;

  @override
  ConsumerState<StoreDetailsMenuPage> createState() =>
      _StoreDetailsMenuPageState();
}

class _StoreDetailsMenuPageState extends ConsumerState<StoreDetailsMenuPage>
    with ColorPalette, SingleTickerProviderStateMixin {
  late final TimeOfDay endTime =
      widget.model.currentSchedule.endTime.toTimeOfDay;

  late List<Tab> tabs = widget.tabs;
  late final ScrollController _scrollController;
  late final detailsProvider = FutureProvider<MerchantDetails>((ref) async {
    final u = ref.read(widget.currentUserProvider);

    return await widget.api.getDetails(widget.model.id, isPublic: u == null);
  });
  late final List<GlobalKeySections> _sections = widget.sections;
  late TabController controller = TabController(
    length: tabs.length,
    vsync: this,
  );

  // ── Optimization 1: pre-sort categories once in initState ──────────────────
  late final List<CategorizedMenu> _sortedCategories;

  // ── Optimization 2: cache built slivers so scroll events don't rebuild them ─
  List<Widget>? _cachedMenuSlivers;
  MenuResult? _cachedMenuResult;

  // ── Optimization 3: throttle scroll listener to ~60 fps ───────────────────
  int _lastScrollMs = 0;

  void _scrollListener() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs - _lastScrollMs < 16) return; // cap at ~60 fps
    _lastScrollMs = nowMs;

    _updateVisibleSection();
    // Only setState for title opacity — no full rebuild needed beyond that.
    // The title itself uses AnimatedBuilder so setState is NOT called here.
  }

  void _updateVisibleSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    for (final section in _sections) {
      final renderObject = section.key.currentContext?.findRenderObject();
      if (renderObject == null) continue;
      final renderBox = renderObject as RenderBox;
      final dy = renderBox.localToGlobal(Offset.zero).dy;
      // Section is "active" when its top edge is in the upper half of the screen
      if (dy >= 0 && dy < screenHeight * 0.5) {
        if (controller.index != section.index) {
          controller.animateTo(section.index);
        }
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Pre-sort once — avoids repeated sort inside build/slivers
    _sortedCategories = widget.categorizedMenu.map((category) {
      final sortedItems = List<MenuItem>.from(category.items)
        ..sort((a, b) => a.name.compareTo(b.name));
      return CategorizedMenu(
        name: category.name,
        items: sortedItems,
        createdAt: category.createdAt,
      );
    }).toList();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // ── Returns cached slivers when MenuResult hasn't changed ─────────────────
  List<Widget> _getMenuSlivers({
    required MenuResult data,
    required double markUpRate,
    required Color grey,
    required Color orangePalette,
  }) {
    if (_cachedMenuResult == data && _cachedMenuSlivers != null) {
      return _cachedMenuSlivers!;
    }
    _cachedMenuResult = data;
    _cachedMenuSlivers = _buildMenuSlivers(
      data: data,
      sections: _sections,
      sortedCategories: _sortedCategories,
      model: widget.model,
      preorderDateTime: widget.preorderDateTime,
      markUpRate: markUpRate,
      grey: grey,
      orangePalette: orangePalette,
    );
    return _cachedMenuSlivers!;
  }

  List<Widget> _buildMenuSlivers({
    required MenuResult data,
    required List<GlobalKeySections> sections,
    required List<CategorizedMenu> sortedCategories,
    required MerchantWithCity model,
    required DateTime? preorderDateTime,
    required double markUpRate,
    required Color grey,
    required Color orangePalette,
  }) {
    if (data.categorizedMenu.isEmpty && data.popularItems.isEmpty) {
      return [const SliverToBoxAdapter(child: SizedBox.shrink())];
    }

    // ── Optimization 4: use firstWhere instead of List.from + where + firstOrNull
    final uncategorizedMenu = data.categorizedMenu
        .firstWhere(
          (e) => e.name == 'uncategorized',
          orElse: () =>
              CategorizedMenu(name: '', items: [], createdAt: DateTime(0)),
        )
        .items;

    final List<Widget> slivers = [const SliverToBoxAdapter(child: Gap(5))];

    // Popular items section
    if (data.popularItems.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      key: sections.first.key,
                      children: [
                        Icon(Icons.whatshot, color: orangePalette),
                        const Gap(10),
                        const Text(
                          'Popular now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.popularItems.length,
                        separatorBuilder: (_, _) => const Gap(10),
                        itemBuilder: (_, i) => PopularCard(
                          placeholderImage: model.photoUrl,
                          preorderDateTime: preorderDateTime,
                          item: data.popularItems[i],
                          width: 110,
                          areaSettingsProvider: widget.areaSettingsProvider,
                          api: widget.api,
                          currentUserCartProvider:
                              widget.currentUserCartProvider,
                          cartApi: widget.cartApi,
                          firestore: widget.firestore,
                          currentLocationProvider:
                              widget.currentLocationProvider,
                          currentUserProvider: widget.currentUserProvider,
                          appApi: widget.appApi,
                          prefs: widget.prefs,
                        ),
                      ),
                    ),
                    const Gap(10),
                  ],
                ),
              ),
              Divider(color: grey.lighten(.25), thickness: 5),
            ],
          ),
        ),
      );
    }

    // Categorized menu sections
    for (int i = 0; i < sortedCategories.length; i++) {
      final int sectionIndex = data.popularItems.isEmpty ? i : i + 1;
      final category = sortedCategories[i];

      slivers.add(
        SliverPadding(
          padding: EdgeInsets.only(
            top: i == 0 && data.popularItems.isEmpty ? 15 : 0,
            bottom: 10,
          ),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                key: sections[sectionIndex].key,
                category.name.capitalizeWords(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      );

      slivers.add(const SliverToBoxAdapter(child: Gap(15)));

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index.isOdd) {
                return Divider(color: grey.withValues(alpha: .5));
              }
              return MenuCard(
                item: category.items[index ~/ 2],
                preorderDateTime: preorderDateTime,
                markupRate: markUpRate,
                currentUserCartProvider: widget.currentUserCartProvider,
                cartApi: widget.cartApi,
                firestore: widget.firestore,
                areaSettingsProvider: widget.areaSettingsProvider,
                currentLocationProvider: widget.currentLocationProvider,
                api: widget.api,
                currentUserProvider: widget.currentUserProvider,
                appApi: widget.appApi,
                prefs: widget.prefs,
              );
            }, childCount: category.items.length * 2 - 1),
          ),
        ),
      );

      if (i < sortedCategories.length - 1 || uncategorizedMenu.isNotEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: Divider(color: grey.lighten(.25), thickness: 5),
          ),
        );
      }
    }

    // Uncategorized items
    if (uncategorizedMenu.isNotEmpty) {
      slivers.add(
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Others',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );

      slivers.add(const SliverToBoxAdapter(child: Gap(15)));

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index.isOdd) {
                return Divider(color: grey.withValues(alpha: .3));
              }
              return MenuCard(
                item: uncategorizedMenu[index ~/ 2],
                preorderDateTime: preorderDateTime,
                markupRate: markUpRate,
                currentUserCartProvider: widget.currentUserCartProvider,
                cartApi: widget.cartApi,
                firestore: widget.firestore,
                areaSettingsProvider: widget.areaSettingsProvider,
                currentLocationProvider: widget.currentLocationProvider,
                api: widget.api,
                currentUserProvider: widget.currentUserProvider,
                appApi: widget.appApi,
                prefs: widget.prefs,
              );
            }, childCount: uncategorizedMenu.length * 2 - 1),
          ),
        ),
      );
    }

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final menuResult = ref.watch(widget.dataProvider);
    final Size size = MediaQuery.of(context).size;
    const double appBarExpandedSize = 320;
    final AreaSetting? settings = ref.watch(widget.areaSettingsProvider);
    final markUpRate = settings == null
        ? .03
        : settings.setting.markupRate / 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshWidget(
        onRefresh: () {},
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              leading: const BackCircleButton(),
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              actions: [
                CartButton(
                  badgeColor: red,
                  isFilled: false,
                  mainColor: Colors.black,
                  textColor: Colors.white,
                  currentLocationProvider: widget.currentLocationProvider,
                  currentUserCartProvider: widget.currentUserCartProvider,
                ),
                const Gap(10),
              ],
              centerTitle: false,
              // ── Optimization 5: AnimatedBuilder scopes rebuilds to title only ──
              title: _AnimatedTitle(
                controller: _scrollController,
                title: widget.model.name.capitalizeWords(),
              ),
              elevation: 1,
              collapsedHeight: 56,
              expandedHeight: appBarExpandedSize,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: StoreHeader(
                  model: widget.model,
                  changePage: widget.changePage,
                  size: size,
                ),
              ),
              backgroundColor: scaffoldColor,
              bottom: menuResult.when(
                data: (data) => PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: grey.withValues(alpha: .5)),
                      ),
                    ),
                    child: TabBar(
                      onTap: (int index) {
                        final sectionKey = _sections[index].key;
                        Scrollable.ensureVisible(
                          sectionKey.currentContext!,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      isScrollable: true,
                      unselectedLabelColor: Colors.black,
                      labelColor: orangePalette,
                      indicatorColor: orangePalette,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabAlignment: TabAlignment.start,
                      indicatorWeight: 4,
                      tabs: tabs,
                      controller: controller,
                      dividerColor: const Color.fromRGBO(0, 0, 0, 0),
                    ),
                  ),
                ),
                error: (e, s) => null,
                loading: () => PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Center(
                    child: CustomLoader(
                      color: darkGrey,
                      label: 'Fetching data',
                    ),
                  ),
                ),
              ),
            ),

            // ── Pinned search bar ─────────────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchBarHeaderDelegate(
                // ── Optimization 6: extract search bar to avoid rebuilds ──────
                child: _SearchBarContent(
                  model: widget.model,
                  grey: grey,
                  orangePalette: orangePalette,
                  api: widget.api,
                  appApi: widget.appApi,
                  prefs: widget.prefs,
                  currentLocationProvider: widget.currentLocationProvider,
                  firestore: widget.firestore,
                  areaSettingsProvider: widget.areaSettingsProvider,
                ),
              ),
            ),

            // ── Menu slivers (cached) ─────────────────────────────────────────
            ...menuResult.when(
              data: (data) => _getMenuSlivers(
                data: data,
                markUpRate: markUpRate,
                grey: grey,
                orangePalette: orangePalette,
              ),
              error: (e, s) => [
                const SliverToBoxAdapter(child: SizedBox.shrink()),
              ],
              loading: () => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CustomLoader(label: 'Fetching menu', color: grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Optimization 5: title opacity scoped to this widget only ─────────────────
class _AnimatedTitle extends StatelessWidget {
  const _AnimatedTitle({required this.controller, required this.title});

  final ScrollController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final offset = controller.hasClients ? controller.offset : 0.0;
        final opacity = (offset / 217).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
        );
      },
    );
  }
}

// ── Optimization 6: search bar extracted so it never rebuilds unnecessarily ──
class _SearchBarContent extends StatelessWidget {
  const _SearchBarContent({
    required this.model,
    required this.grey,
    required this.orangePalette,
    required this.api,
    required this.appApi,
    required this.prefs,
    required this.currentLocationProvider,
    required this.firestore,
    required this.areaSettingsProvider,
  });

  final MerchantWithCity model;
  final Color grey;
  final Color orangePalette;
  final BaseStoreApi api;
  final BaseAppApi appApi;
  final BaseDataCacher prefs;
  final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider;
  final BaseFirebaseFirestoreSupport firestore;
  final StateProvider<AreaSetting?> areaSettingsProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 10, bottom: 5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DebouncedTextField(
              textColor: Colors.grey.shade800,
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade800.hasOpacity(1),
              ),
              hintText: "Search for ${model.name.capitalize()}'s menu",
              onDebouncedChange: (text) {
                if (text.trim().isEmpty) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchMenuPage(
                      keyword: text,
                      classification: null,
                      type: 2,
                      merchantID: model.id,
                      api: api,
                      appApi: appApi,
                      prefs: prefs,
                      currentLocationProvider: currentLocationProvider,
                      areaSettingsProvider: areaSettingsProvider,
                      ffs: firestore,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 5),
          color: grey.withValues(alpha: .2),
          child: Center(
            child: Text(
              'Menu is for reference only & subject to availability.',
              style: TextStyle(color: orangePalette, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SearchBarHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 95;

  @override
  double get maxExtent => 95;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          if (overlapsContent || shrinkOffset > 0)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarHeaderDelegate oldDelegate) =>
      oldDelegate.child != child;
}
