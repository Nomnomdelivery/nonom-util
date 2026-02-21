// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:nomnom_util/models/checkout_data.dart';
// import 'package:nomnom_util/utils/color_pallete.dart';
// import 'package:nomnom_util/widgets/cart_menu_listing.dart';
// import 'package:nomnom_util/widgets/custom_loader.dart';

// class CustomStep {
//   final String title;
//   final int index;
//   bool isEnabled;
//   CustomStep({
//     required this.isEnabled,
//     required this.title,
//     required this.index,
//   });
// }

// class CartPage extends ConsumerStatefulWidget {
//   const CartPage({super.key});

//   @override
//   ConsumerState<CartPage> createState() => _CartPageState();
// }

// class _CartPageState extends ConsumerState<CartPage>
//     with ColorPalette, SingleTickerProviderStateMixin {
//   int currentStep = 2;
//   final List<CustomStep> steps = [
//     CustomStep(isEnabled: false, title: "Menu", index: 1),
//     CustomStep(isEnabled: false, title: "Bag", index: 2),
//     CustomStep(isEnabled: false, title: "Checkout", index: 3),
//   ];
//   CheckoutData? checkoutData;
//   late final TabController _controller = TabController(
//     length: steps.length,
//     vsync: this,
//     initialIndex: 1,
//   );

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   final GlobalKey<CartMenuListingState> _kListing =
//       GlobalKey<CartMenuListingState>();
//   // final GlobalKey<CheckoutPageState> _kCheckout =
//   //     GlobalKey<CheckoutPageState>();

//   @override
//   Widget build(BuildContext context) {
//     final isLoading = ref.watch(cartLoadingProvider);
//     return PopScope(
//       canPop: !isLoading && currentStep == 2,
//       onPopInvokedWithResult: (didPop, result) {
//         if (!didPop && currentStep == 3) {
//           setState(() {
//             currentStep = 2;
//             checkoutData = null;
//           });
//           _controller.animateTo(1);
//         }
//       },
//       child: Stack(
//         children: [
//           Positioned.fill(
//             child: Scaffold(
//               backgroundColor: Colors.white,
//               appBar: PreferredSize(
//                 preferredSize: Size.fromHeight(120),
//                 child: Container(
//                   color: orangePalette,
//                   child: Stack(
//                     children: [
//                       Positioned.fill(
//                         child: Image.asset(
//                           "assets/images/vector_background.png",
//                           color: Colors.white.withOpacity(.5),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           AppBar(
//                             backgroundColor: Colors.transparent,
//                             elevation: 0,
//                             iconTheme: IconThemeData(color: Colors.white),
//                             centerTitle: true,
//                             title: Text(
//                               "Bag",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             height: 64,
//                             width: double.infinity,
//                             padding: const EdgeInsets.symmetric(horizontal: 0),
//                             child: LayoutBuilder(
//                               builder: (context, c) {
//                                 return Stack(
//                                   alignment: Alignment.center,
//                                   children: [
//                                     Positioned(
//                                       top: 64 * .3,
//                                       left: 0,
//                                       right: 0,
//                                       child: Container(
//                                         margin: const EdgeInsets.symmetric(
//                                           horizontal: 35,
//                                         ),
//                                         width: double.infinity,
//                                         height: 3,
//                                         color: Colors.white.withOpacity(.5),
//                                         child: LayoutBuilder(
//                                           builder: (context, cc) {
//                                             double containerWidth = 0;
//                                             if (currentStep == 2) {
//                                               containerWidth = cc.maxWidth * .5;
//                                             } else if (currentStep == 3) {
//                                               containerWidth = cc.maxWidth;
//                                             } else {
//                                               containerWidth = 0;
//                                             }
//                                             return Stack(
//                                               children: [
//                                                 Container(
//                                                   height: 3,
//                                                   width: containerWidth,
//                                                   color: Colors.white,
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                     Positioned(
//                                       top: 64 * .05,
//                                       left: 0,
//                                       right: 0,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: steps
//                                             .map(
//                                               (e) => InkWell(
//                                                 onTap: () {
//                                                   //
//                                                   if (currentStep > e.index) {
//                                                     if (e.index == 1) {
//                                                       Navigator.of(
//                                                         context,
//                                                       ).pop();
//                                                     } else if (e.index == 2) {
//                                                       setState(() {
//                                                         currentStep = 2;
//                                                         checkoutData = null;
//                                                       });
//                                                       _controller.animateTo(1);
//                                                     }
//                                                   }
//                                                 },
//                                                 child: SizedBox(
//                                                   height: 64,
//                                                   child: Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .center,
//                                                     children: [
//                                                       Container(
//                                                         width: c.maxHeight * .5,
//                                                         height:
//                                                             c.maxHeight * .5,
//                                                         decoration: BoxDecoration(
//                                                           color:
//                                                               currentStep >=
//                                                                   e.index
//                                                               ? Colors.white
//                                                               : orangePalette,
//                                                           border: Border.all(
//                                                             color: Colors.white,
//                                                             width: 1.5,
//                                                           ),
//                                                           shape:
//                                                               BoxShape.circle,
//                                                         ),
//                                                         child: Center(
//                                                           child: Text(
//                                                             e.index.toString(),
//                                                             style: TextStyle(
//                                                               color:
//                                                                   currentStep >=
//                                                                       e.index
//                                                                   ? orangePalette
//                                                                   : Colors
//                                                                         .white,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w600,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       const Gap(5),
//                                                       SizedBox(
//                                                         width: 62,
//                                                         child: Center(
//                                                           child: Text(
//                                                             e.title,
//                                                             style: TextStyle(
//                                                               fontSize: 12,
//                                                               color:
//                                                                   Colors.white,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w600,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             )
//                                             .toList(),
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               body: TabBarView(
//                 physics: const NeverScrollableScrollPhysics(),
//                 controller: _controller,
//                 children: [
//                   Container(color: Colors.blue),
//                   // CartMenuListing(
//                   //   key: _kListing,

//                   //   onCheckout: (CheckoutData data) async {
//                   //     setState(() {
//                   //       checkoutData = data;
//                   //       currentStep = 3;
//                   //     });
//                   //     _controller.animateTo(2);
//                   //   },
//                   // ),
//                   // if (checkoutData == null) ...{
//                   //   Container(),
//                   // } else ...{
//                   //   CheckoutPage(key: _kCheckout, data: checkoutData!),
//                   // },
//                 ],
//               ),
//             ),
//           ),
//           if (isLoading) ...{
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withOpacity(.5),
//                 child: Center(child: CustomLoader(label: "")),
//               ),
//             ),
//           },
//         ],
//       ),
//     );
//   }
// }
