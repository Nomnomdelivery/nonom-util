import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/api/base_store_api.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/merchant/merchant_details.dart';
import 'package:nomnom_util/models/merchant/merchant_with_city.dart';
import 'package:nomnom_util/models/promo.dart';
import 'package:nomnom_util/models/store_feedback.dart';
import 'package:nomnom_util/models/user_model.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/custom_loader.dart';
import 'package:nomnom_util/widgets/refresh_widget.dart';
import 'package:nomnom_util/widgets/store_promo_viewer.dart';
import 'package:nomnom_util/widgets/store_review_viewer.dart';

class StoreDetailsContentPage extends ConsumerStatefulWidget {
  const StoreDetailsContentPage({
    super.key,
    required this.model,
    required this.rateProvider,
    required this.changePage,
    required this.promoProvider,
    required this.areaSettingsProvider,
    required this.api,
    required this.currentUserProvider,
  });
  final MerchantWithCity model;
  final FutureProvider<StoreFeedback> rateProvider;
  final FutureProvider<List<PromoModel>> promoProvider;
  final VoidCallback changePage;
  final StateProvider<AreaSetting?> areaSettingsProvider;
  final BaseStoreApi api;
  final StateNotifierProvider<CurrentUserNotifier, UserModel?>
  currentUserProvider;
  @override
  ConsumerState<StoreDetailsContentPage> createState() =>
      _StoreDetailsContentPageState();
}

class _StoreDetailsContentPageState
    extends ConsumerState<StoreDetailsContentPage>
    with SingleTickerProviderStateMixin, ColorPalette {
  int currentIndex = 0;
  late final TabController _controller = TabController(
    length: _tabs.length,
    vsync: this,
  );
  late final detailsProvider = FutureProvider<MerchantDetails>((ref) async {
    final u = ref.read(widget.currentUserProvider);

    return await widget.api.getDetails(widget.model.id, isPublic: u == null);
  });
  late final scheduleProvider = FutureProvider<Map<String, dynamic>>((
    ref,
  ) async {
    final doc = await FirebaseFirestore.instance
        .collection('store-schedule')
        .doc(widget.model.id.toString())
        .get();
    return doc.data()?['current_schedule'] as Map<String, dynamic>? ?? {};
  });
  late final List<Widget> _tabContents = [
    StoreReviewViewer(
      provider: widget.rateProvider,
      onSizeChanged: (Size s) {
        setState(() {
          contentSize = s.height;
        });
      },
    ),
    StoreAboutViewer(desc: widget.model.description),
    StorePromoViewer(
      provider: widget.promoProvider,
      onSizeChanged: (Size s) {
        setState(() {
          contentSize = s.height;
        });
      },
    ),
  ];
  final List<Widget> _tabs = [
    Tab(text: "Reviews"),
    Tab(text: "About"),
    Tab(text: "Promo codes"),
  ];

  double contentSize = 100;
  Widget contentBuilder({
    required String title,
    required String value,
    required Widget icon,
    double initTitleSize = 15,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      icon,
      const Gap(15),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: initTitleSize,
                fontWeight: FontWeight.w500,
              ),
              maxLines: value.isEmpty ? 2 : 1,
            ),
            if (value.isNotEmpty) ...{
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  color: grey,
                ),
              ),
            },
          ],
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final double appBarExpandedSize = 300;
    final details = ref.watch(detailsProvider);
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      body: RefreshWidget(
        onRefresh: () {
          if (currentIndex == 0) {
            ref.invalidate(widget.rateProvider);
          } else {
            ref.invalidate(widget.promoProvider);
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: BackButton(
                onPressed: () {
                  widget.changePage();
                },
              ),
              expandedHeight: appBarExpandedSize,
              collapsedHeight: 56,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: LayoutBuilder(
                    builder: (context, c) => Column(
                      children: [
                        Hero(
                          tag: widget.model.id,
                          child: CachedNetworkImage(
                            imageUrl: widget.model.coverPhotoUrl,
                            fit: BoxFit.cover,
                            height: c.maxHeight * 0.45,
                            width: c.maxWidth,
                          ),
                        ),
                        Expanded(
                          child: details.when(
                            data: (data) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: contentBuilder(
                                        title: data.rating.averageRating
                                            .toStringAsFixed(1),
                                        value: "${data.rating.count} Reviews",
                                        icon: Icon(
                                          Icons.star_border_outlined,
                                          color: orangePalette,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: contentBuilder(
                                        title: data.displayAddressString,
                                        value: "",
                                        initTitleSize: 14,
                                        icon: Icon(
                                          Icons.location_on_rounded,
                                          color: orangePalette,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Consumer(
                                        builder: (context, ref, child) {
                                          final schedule = ref.watch(
                                            scheduleProvider,
                                          );
                                          return schedule.when(
                                            data: (scheduleData) {
                                              final String openTime =
                                                  scheduleData['open'] != null
                                                  ? scheduleData['open']
                                                        .toString()
                                                        .toTimeOfDay
                                                        .format(context)
                                                  : "--:--";
                                              final String closeTime =
                                                  scheduleData['close'] != null
                                                  ? scheduleData['close']
                                                        .toString()
                                                        .toTimeOfDay
                                                        .format(context)
                                                  : "--:--";

                                              return contentBuilder(
                                                title: "Opening Hours",
                                                value: "$openTime - $closeTime",
                                                icon: Icon(
                                                  Icons.access_time,
                                                  color: orangePalette,
                                                ),
                                              );
                                            },
                                            loading: () => contentBuilder(
                                              title: "Opening Hours",
                                              value: "Loading...",
                                              icon: Icon(
                                                Icons.access_time,
                                                color: orangePalette,
                                              ),
                                            ),
                                            error: (e, s) => contentBuilder(
                                              title: "Opening Hours",
                                              value: "No schedule available",
                                              icon: Icon(
                                                Icons.access_time,
                                                color: orangePalette,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            error: (e, s) => Container(),
                            loading: () => CustomLoader(
                              color: darkGrey,
                              label:
                                  "Fetching ${widget.model.name.capitalize()} details",
                            ),
                          ),
                        ),
                        SizedBox(height: 56),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(56),
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    isScrollable: false,
                    unselectedLabelColor: Colors.black,
                    labelColor: orangePalette,
                    indicatorColor: orangePalette,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 4,
                    tabs: _tabs,
                    controller: _controller,
                    onTap: (i) {
                      setState(() {
                        currentIndex = i;
                      });
                    },
                    dividerColor: const Color.fromRGBO(0, 0, 0, 0),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: 800.ms,
                child: Column(children: [_tabContents[currentIndex]]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoreAboutViewer extends StatelessWidget {
  const StoreAboutViewer({super.key, required this.desc});
  final String desc;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Gap(20),
          Text(desc),
        ],
      ),
    );
  }
}
