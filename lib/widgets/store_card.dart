// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:intl/intl.dart';
// import 'package:nomnom_util/api/base_firebase_firestore_support.dart';
// import 'package:nomnom_util/api/base_store_api.dart';
// import 'package:nomnom_util/extensions/color_opacity.dart';
// import 'package:nomnom_util/extensions/string_capitalize.dart';
// import 'package:nomnom_util/extensions/string_parser.dart';
// import 'package:nomnom_util/extensions/time_of_day_parser.dart';
// import 'package:nomnom_util/models/merchant/merchant_with_city.dart';
// import 'package:nomnom_util/models/merchant/operating_day.dart';
// import 'package:nomnom_util/models/user_model.dart';
// import 'package:nomnom_util/providers/user_provider.dart';
// import 'package:nomnom_util/utils/color_pallete.dart';
// import 'package:nomnom_util/widgets/store_details_page.dart';

// // ── Optimization 1: compute() payload — plain data class, no Flutter objects ──
// // compute() isolates require all args to be sendable across isolate boundaries.
// class _SchedulePayload {
//   const _SchedulePayload({
//     required this.rawData,
//     required this.operatingDays,
//     required this.nowMs,
//   });
//   final Map<String, dynamic>? rawData;
//   final List<OperatingDay> operatingDays;
//   final int nowMs; // DateTime.now().millisecondsSinceEpoch
// }

// class _ScheduleResult {
//   const _ScheduleResult({required this.nextDay, required this.orderTime});
//   final int nextDay;
//   final int orderTime;
// }

// // ── Top-level function required by compute() — cannot be a closure or method ──
// _ScheduleResult _computeSchedule(_SchedulePayload payload) {
//   final now = DateTime.fromMillisecondsSinceEpoch(payload.nowMs);
//   final rawData = payload.rawData;

//   bool isOpen = false;
//   if (rawData != null) {
//     final schedule = rawData['current_schedule'] as Map<String, dynamic>? ?? {};
//     final overrideStatus = rawData['override_status'] as String?;
//     isOpen = _isStoreOpen(
//       overrideStatus: overrideStatus,
//       schedule: schedule,
//       now: now,
//     );
//   }

//   int nextDay = 0;
//   if (!isOpen) {
//     nextDay = _getNextDay(
//       operatingDays: payload.operatingDays,
//       now: now,
//       rawData: rawData,
//     );
//   }

//   // orderTime: 0 = open now, 1 = order later today, 2 = future day
//   int orderTime = 0;
//   if (nextDay > 0) {
//     orderTime = nextDay > 1 ? 2 : 1;
//   }

//   return _ScheduleResult(nextDay: nextDay, orderTime: orderTime);
// }

// bool _isStoreOpen({
//   required String? overrideStatus,
//   required Map schedule,
//   required DateTime now,
// }) {
//   if (overrideStatus == 'open') return true;
//   if (overrideStatus == 'closed') return false;

//   final String openTimeStr = schedule['open'] ?? '00:00:00';
//   final String closeTimeStr = schedule['close'] ?? '00:00:00';
//   final String? dateStr = schedule['date'];
//   if (dateStr == null) return false;

//   try {
//     final date = DateTime.parse(dateStr);
//     final openParts = openTimeStr.split(':').map(int.parse).toList();
//     final closeParts = closeTimeStr.split(':').map(int.parse).toList();
//     final open = DateTime(
//       date.year,
//       date.month,
//       date.day,
//       openParts[0],
//       openParts[1],
//     );
//     final close = DateTime(
//       date.year,
//       date.month,
//       date.day,
//       closeParts[0],
//       closeParts[1],
//     );
//     return now.isAfter(open) && now.isBefore(close);
//   } catch (_) {
//     return false;
//   }
// }

// int _getNextDay({
//   required List<OperatingDay> operatingDays,
//   required DateTime now,
//   required Map<String, dynamic>? rawData,
// }) {
//   final currentDayOfWeek = now.weekday;
//   final activeDays = operatingDays.where((d) => d.enable).toList()
//     ..sort((a, b) => a.day.compareTo(b.day));

//   for (final day in activeDays) {
//     if (day.day == currentDayOfWeek) {
//       if (now.isBefore(day.endTime.toDateTime())) return 0;
//     } else if (day.day > currentDayOfWeek) {
//       return day.day - currentDayOfWeek;
//     }
//   }

//   if (activeDays.isNotEmpty) {
//     return (7 - currentDayOfWeek) + activeDays.first.day;
//   }
//   return 0;
// }

// // ─────────────────────────────────────────────────────────────────────────────

// class StoreCard extends StatefulWidget {
//   const StoreCard({
//     super.key,
//     required this.store,
//     this.isGridView = false,
//     required this.ffs,
//     required this.api,
//     required this.currentUserProvider,
//   });
//   final MerchantWithCity store;
//   final bool isGridView;
//   final BaseFirebaseFirestoreSupport ffs;
//   final BaseStoreApi api;
//   final StateNotifierProvider<CurrentUserNotifier, UserModel?>
//   currentUserProvider;

//   // ── Optimization 2: static singleton ──────────────────────────────────────

//   @override
//   State<StoreCard> createState() => _StoreCardState();
// }

// class _StoreCardState extends State<StoreCard> with ColorPalette {
//   // ── Optimization 3: static formatters — created once for all StoreCard instances
//   static final DateFormat _dateFormat = DateFormat('EEE, MMM dd');
//   static final DateFormat _timeFormat = DateFormat('h:mm a');

//   // ── Optimization 4: cache the async schedule result ────────────────────────
//   _ScheduleResult? _scheduleResult;
//   Map<String, dynamic>? _lastRawData;

//   // ── Optimization 5: compute() schedule off the main thread ────────────────
//   Future<void> _updateSchedule(Map<String, dynamic>? rawData) async {
//     // Skip if data hasn't changed
//     if (rawData == _lastRawData) return;
//     _lastRawData = rawData;

//     final result = await compute(
//       _computeSchedule,
//       _SchedulePayload(
//         rawData: rawData,
//         operatingDays: widget.store.operatingDays,
//         nowMs: DateTime.now().millisecondsSinceEpoch,
//       ),
//     );

//     if (mounted) {
//       setState(() => _scheduleResult = result);
//     }
//   }

//   // ── Optimization 6: responsive font computed once, cached ─────────────────
//   double? _cachedFontSize;
//   double _getResponsiveFontSize(double screenWidth) {
//     if (_cachedFontSize != null) return _cachedFontSize!;
//     if (widget.isGridView) {
//       _cachedFontSize = screenWidth < 360
//           ? 11.0
//           : screenWidth < 400
//           ? 12.0
//           : screenWidth < 500
//           ? 13.0
//           : 14.0;
//     } else {
//       _cachedFontSize = screenWidth < 360
//           ? 11.0
//           : screenWidth < 400
//           ? 13.0
//           : 13.0;
//     }
//     return _cachedFontSize!;
//   }

//   // static const Widget _imageFallback = Image(
//   //   image: AssetImage('packages/nomnom_util/assets/images/customer.jpg'),
//   //   height: 70,
//   //   width: 70,
//   //   fit: BoxFit.fill,
//   // );

//   // static const Widget _imageFallback80 = Image(
//   //   image: AssetImage('packages/nomnom_util/assets/images/customer.jpg'),
//   //   height: 80,
//   //   width: 80,
//   //   fit: BoxFit.fill,
//   // );

//   Widget _buildListLayout(BoxConstraints cc) {
//     return Column(
//       children: [
//         SizedBox(
//           height: cc.maxHeight * .6,
//           width: double.infinity,
//           child: Hero(
//             tag: widget.store.coverPhotoUrl,
//             child: CachedNetworkImage(
//               imageUrl: widget.store.coverPhotoUrl,
//               fit: BoxFit.cover,
//               memCacheWidth: 600,
//               filterQuality: FilterQuality.low,
//               fadeInDuration: const Duration(milliseconds: 200),
//               fadeOutDuration: Duration.zero,
//               placeholder: (_, _) => const _ImageShimmer(
//                 width: double.infinity,
//                 height: double.infinity,
//               ),
//               errorWidget: (_, _, _) => Container(
//                 color: const Color(0xFFE0E0E0),
//                 child: const Icon(
//                   Icons.restaurant,
//                   size: 50,
//                   color: Color(0xFF9E9E9E),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(6),
//                   child: Hero(
//                     tag: widget.store.photoUrl,
//                     child: CachedNetworkImage(
//                       imageUrl: widget.store.photoUrl,
//                       height: 70,
//                       width: 70,
//                       fit: BoxFit.fill,
//                       memCacheWidth: 140, // 2× display size
//                       memCacheHeight: 140,
//                       filterQuality: FilterQuality.low,
//                       fadeInDuration: const Duration(milliseconds: 200),
//                       fadeOutDuration: Duration.zero,
//                       placeholder: (_, _) =>
//                           const _ImageShimmer(width: 70, height: 70),
//                       //TODO: fix image
//                       // errorWidget: (_, _, _) => _imageFallback, // static const
//                     ),
//                   ),
//                 ),
//                 const Gap(10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.store.name.capitalizeWords(),
//                         maxLines: 2,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           height: 1,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const Gap(2),
//                       // ── Optimization 7: star row extracted ────────────────
//                       _StarRow(
//                         rating: widget.store.rating,
//                         orangePalette: orangePalette,
//                       ),
//                       Text(
//                         widget.store.displayAddressString,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w400,
//                           color: Colors.black.hasOpacity(.5),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildGridLayout(double screenWidth) {
//     return Container(
//       padding: const EdgeInsets.all(5),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Center(
//             child: Hero(
//               tag: widget.store.id,
//               child: Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   color: Colors.white,
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Color(0x1A000000),
//                       blurRadius: 8,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: CachedNetworkImage(
//                     imageUrl: widget.store.photoUrl,
//                     fit: BoxFit.fill,
//                     width: 80,
//                     height: 80,
//                     memCacheWidth: 160, // 2× display size
//                     memCacheHeight: 160,
//                     filterQuality: FilterQuality.low,
//                     fadeInDuration: const Duration(milliseconds: 200),
//                     fadeOutDuration: Duration.zero,
//                     placeholder: (_, _) =>
//                         const _ImageShimmer(width: 80, height: 80),
//                     //TODO: fix image
//                     // errorWidget: (_, _, _) => _imageFallback80, // static const
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(5),
//             child: Center(
//               child: Text(
//                 widget.store.name.capitalizeWords(),
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: _getResponsiveFontSize(screenWidth),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.sizeOf(context).width;

//     return RepaintBoundary(
//       child: StreamBuilder<Map<String, dynamic>?>(
//         stream: widget.ffs.listenMerchantSchedule(id: widget.store.id),
//         builder: (context, snapshot) {
//           // ── Kick off compute when stream data changes ──────────────────────
//           if (snapshot.hasData) {
//             _updateSchedule(snapshot.data);
//           }

//           final result = _scheduleResult;
//           final int nextDay = result?.nextDay ?? 0;
//           final int orderTime = result?.orderTime ?? 0;
//           //TODO: implement StoreDetails page
//           // void goToStore() {
//           //   Navigator.of(context).push(
//           //     MaterialPageRoute(
//           //       builder: (_) => StoreDetailsPage(
//           //         model: widget.store,
//           //         deliveryDate: nextDay > 1
//           //             ? DateTime.now().add(Duration(days: nextDay))
//           //             : widget.store.currentSchedule.startTime.toTimeOfDay
//           //                   .toDateTime(),
//           //         api: widget.api,
//           //         currentUserProvider: widget.currentUserProvider,
//           //       ),
//           //     ),
//           //   );
//           // }

//           return ClipRRect(
//             borderRadius: BorderRadius.circular(6),
//             child: GestureDetector(
//               // onTap: goToStore,
//               child: Consumer(
//                 builder: (context, ref, _) {
//                   ref.watch(widget.currentUserProvider);
//                   return SizedBox(
//                     width: double.infinity,
//                     height: 230,
//                     child: ColoredBox(
//                       color: widget.isGridView
//                           ? Colors.transparent
//                           : Colors.white,
//                       child: Stack(
//                         children: [
//                           Positioned.fill(
//                             child: LayoutBuilder(
//                               builder: (_, cc) => widget.isGridView
//                                   ? _buildGridLayout(screenWidth)
//                                   : _buildListLayout(cc),
//                             ),
//                           ),

//                           // ── Closed / preorder overlay ─────────────────────
//                           if (orderTime > 0)
//                             Positioned.fill(
//                               child: _ClosedOverlay(
//                                 isGridView: widget.isGridView,
//                                 orderTime: orderTime,
//                                 nextDay: nextDay,
//                                 store: widget.store,
//                                 dateFormat: _dateFormat,
//                                 timeFormat: _timeFormat,
//                                 grey: grey,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ── Inline shimmer for images — lightweight, no package ──────────────────────
// class _ImageShimmer extends StatefulWidget {
//   const _ImageShimmer({required this.width, required this.height});
//   final double width;
//   final double height;

//   @override
//   State<_ImageShimmer> createState() => _ImageShimmerState();
// }

// class _ImageShimmerState extends State<_ImageShimmer>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 1200),
//   )..repeat();

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _ctrl,
//       builder: (_, _) => Container(
//         width: widget.width,
//         height: widget.height,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//             stops: [
//               (_ctrl.value - 0.3).clamp(0.0, 1.0),
//               _ctrl.value.clamp(0.0, 1.0),
//               (_ctrl.value + 0.3).clamp(0.0, 1.0),
//             ],
//             colors: const [
//               Color(0xFFE0E0E0),
//               Color(0xFFF5F5F5),
//               Color(0xFFE0E0E0),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Star row extracted — stable widget, skipped by Flutter if rating unchanged
// class _StarRow extends StatelessWidget {
//   const _StarRow({required this.rating, required this.orangePalette});
//   final dynamic rating; // your Rating model
//   final Color orangePalette;

//   @override
//   Widget build(BuildContext context) {
//     final avg = rating.averageRating;
//     final floor = avg.floor();
//     return Row(
//       children: [
//         for (int i = 0; i < 5; i++)
//           Icon(
//             i < floor ? Icons.star : Icons.star_border,
//             color: orangePalette,
//             size: 18,
//           ),
//         const Gap(5),
//         Text(avg.toString()),
//         Text(
//           '(${rating.count} reviews)',
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             color: Colors.black.hasOpacity(.5),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ── Closed overlay extracted — only built when orderTime > 0 ─────────────────
// class _ClosedOverlay extends StatelessWidget {
//   const _ClosedOverlay({
//     required this.isGridView,
//     required this.orderTime,
//     required this.nextDay,
//     required this.store,
//     required this.dateFormat,
//     required this.timeFormat,
//     required this.grey,
//   });

//   final bool isGridView;
//   final int orderTime;
//   final int nextDay;
//   final MerchantWithCity store;
//   final DateFormat dateFormat;
//   final DateFormat timeFormat;
//   final Color grey;

//   String get _label {
//     if (orderTime == 2) {
//       return nextDay > 1
//           ? dateFormat.format(DateTime.now().add(Duration(days: nextDay)))
//           : 'Order tomorrow';
//     }
//     return 'Order later at ${timeFormat.format(store.currentSchedule.startTime.toTimeOfDay.toDateTime())}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: isGridView ? null : Colors.black.hasOpacity(.3),
//       padding: isGridView
//           ? const EdgeInsets.only(top: 4)
//           : const EdgeInsets.all(30),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Container(
//             width: isGridView ? 83 : null,
//             height: isGridView ? 83 : null,
//             padding: EdgeInsets.symmetric(
//               horizontal: isGridView ? 6 : 15,
//               vertical: isGridView ? 4 : 10,
//             ),
//             decoration: BoxDecoration(
//               color: grey.hasOpacity(.6),
//               borderRadius: isGridView ? BorderRadius.circular(16) : null,
//             ),
//             child: Center(
//               child: Text(
//                 _label,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: isGridView ? 12 : 16,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
