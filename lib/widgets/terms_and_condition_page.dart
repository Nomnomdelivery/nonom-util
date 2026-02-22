// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:nomnom_util/utils/color_pallete.dart';

// class TermsAndConditionsPage extends StatelessWidget with ColorPalette {
//   TermsAndConditionsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF8F8F8),
//       appBar: AppBar(
//         elevation: 0,
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         title: Text(
//           "Terms & Conditions",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.05),
//                     blurRadius: 8,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Promo Code Terms & Conditions",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: ColorPalette.orange,
//                     ),
//                   ),
//                   const Gap(16),

//                   _buildSection("General Terms", [
//                     "Promo codes are valid for a limited time and subject to availability.",
//                     "Each promo code can only be used once per customer account.",
//                     "Promo codes cannot be combined with other offers unless explicitly stated.",
//                     "Nom Nom reserves the right to modify or cancel any promo code at any time.",
//                   ]),

//                   const Gap(20),

//                   _buildSection("Usage Requirements", [
//                     "Minimum order amount must be met for the promo to be valid.",
//                     "Promo codes are applicable only to eligible items and restaurants.",
//                     "Free delivery promos apply to standard delivery charges only.",
//                     "Discount promos have maximum discount caps as specified.",
//                   ]),

//                   const Gap(20),

//                   _buildSection("Restrictions", [
//                     "Promo codes cannot be transferred to other accounts.",
//                     "No cash value or refund for unused promo codes.",
//                     "Expired promo codes cannot be honored or extended.",
//                     "Promo codes are void if copied, sold, or transferred.",
//                   ]),

//                   const Gap(20),

//                   _buildSection("Important Notes", [
//                     "Technical issues may prevent promo code redemption.",
//                     "Contact customer support for assistance with promo code issues.",
//                     "Standard delivery fees may apply for areas outside coverage zones.",
//                     "These terms are subject to change without prior notice.",
//                   ]),

//                   const Gap(24),

//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: ColorPalette.orange.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: ColorPalette.orange.withValues(alpha: 0.3),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.info_outline,
//                           color: ColorPalette.orange,
//                           size: 20,
//                         ),
//                         const Gap(8),
//                         Expanded(
//                           child: Text(
//                             "For questions about promo codes, contact our customer support through the app.",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: ColorPalette.orange,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSection(String title, List<String> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const Gap(8),
//         ...items.map(
//           (item) => Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 4,
//                   height: 4,
//                   margin: const EdgeInsets.only(top: 8, right: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade600,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     item,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade700,
//                       height: 1.4,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
