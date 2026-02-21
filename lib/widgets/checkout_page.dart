// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nomnom_util/models/checkout_data.dart';

// class CheckoutPage extends ConsumerStatefulWidget {
//   const CheckoutPage({super.key, required this.data});
//   final CheckoutData data;
//   @override
//   ConsumerState<CheckoutPage> createState() => CheckoutPageState();
// }

// class CheckoutPageState extends ConsumerState<CheckoutPage> {
//   @override
//   Widget build(BuildContext context) {
//     final isCurrentAsync = ref.watch(isCurrentLocationProvider);
//     return isCurrentAsync.when(
//       data: (isCurrent) =>
//           PlaceOrderPage(data: widget.data, isForFriend: isCurrent),
//       loading: () =>
//           const Scaffold(body: Center(child: CircularProgressIndicator())),
//       error: (error, stack) => PlaceOrderPage(
//         data: widget.data,
//         isForFriend:
//             widget.data.isForFriend, // Fallback to original value on error
//       ),
//     );
//   }
// }
