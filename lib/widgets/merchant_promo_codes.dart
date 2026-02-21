import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nomnom_util/api/base_store_api.dart';
import 'package:nomnom_util/extensions/list_ext.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/models/categorized_promo.dart';
import 'package:nomnom_util/models/faq.dart';
import 'package:nomnom_util/models/promo.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/custom_loader.dart';
import 'package:nomnom_util/widgets/terms_and_condition_page.dart';

class MerchantPromoCodes extends ConsumerStatefulWidget {
  const MerchantPromoCodes({
    super.key,
    required this.merchantID,
    required this.onPromoSelected,
    this.selectedPromo,
    this.isValidPromo = false,
    required this.api,
    required this.currentLocationProvider,
  });
  final int merchantID;
  final Future<bool> Function(PromoModel) onPromoSelected;
  final PromoModel? selectedPromo;
  final bool isValidPromo;
  final BaseStoreApi api;
  final StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider;

  @override
  ConsumerState<MerchantPromoCodes> createState() => _MerchantPromoCodesState();
}

class _MerchantPromoCodesState extends ConsumerState<MerchantPromoCodes>
    with ColorPalette {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  PromoModel? _selectedPromo;

  final List<FAQItem> items = [
    FAQItem(
      question: "Add items to your bag",
      answer: "Choose your favorite items and add them to your bag.",
    ),
    FAQItem(
      question: "Proceed to Checkout",
      answer: "Go to the checkout screen after finalizing your order.",
    ),
    FAQItem(
      question: "Enter Promo Code",
      answer:
          "Tap on the \"Promo Code\" button, enter your code or select from the choices, and apply it.",
    ),
    FAQItem(
      question: "See the Discount",
      answer:
          "The discount will be applied automatically if the promo code is valid and meets the conditions.",
    ),
    FAQItem(
      question: "Complete Your Order",
      answer:
          "Select your payment method and place your order. Enjoy the savings and happy ordering with Nom Nom!",
    ),
  ];

  late final categorizedPromoProvider =
      FutureProvider<List<CategorizedPromoModel>>((ref) async {
        final currentLocation = ref.watch(widget.currentLocationProvider);
        final res = await widget.api.getOngoingPromo(
          ids: [],
          addressId: currentLocation?.id,
        );
        return res.categorize();
      });

  final DateFormat format = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _selectedPromo = widget.selectedPromo;
  }

  @override
  void didUpdateWidget(MerchantPromoCodes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPromo != widget.selectedPromo) {
      setState(() {
        _selectedPromo = widget.selectedPromo;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategorizedPromoModel> _filterPromos(List<CategorizedPromoModel> data) {
    if (_searchQuery.isEmpty) return data;

    return data
        .map((category) {
          final filteredPromos = category.promos.where((promo) {
            return promo.promoCode.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();

          return CategorizedPromoModel(
            promoType: category.promoType,
            promoTypeString: category.promoTypeString,
            promos: filteredPromos,
          );
        })
        .where((category) => category.promos.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(categorizedPromoProvider);
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: SafeArea(
                    top: _selectedPromo!.isUsed,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 60,
                              height: 5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: textField,
                              ),
                            ),
                          ),
                          const Gap(15),
                          Center(
                            child: Text(
                              "Common FAQs",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Gap(15),
                          Text(
                            "How to use?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(5),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (_, i) {
                              final FAQItem item = items[i];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${i + 1}. ${item.question}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(item.answer),
                                ],
                              );
                            },
                            separatorBuilder: (_, i) => const Gap(10),
                            itemCount: items.length,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            icon: Icon(Icons.info, color: grey),
          ),
        ],
        title: Text(
          "Promo code",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search promo code...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ColorPalette.orange),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: result.when(
              data: (data) {
                final filteredData = _filterPromos(data);

                if (data.isEmpty) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //TODO: fix image
                        // Image.asset(
                        //   "packages/nomnom_util/assets/images/rider.png",
                        //   height: 120,
                        // ),
                        const Gap(20),
                        Text("No promos generated yet."),
                      ],
                    ),
                  );
                }

                if (filteredData.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const Gap(20),
                        Text(
                          "No promo codes found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          "Try searching with a different code",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemBuilder: (_, i) {
                    final CategorizedPromoModel model = filteredData[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.promoTypeString,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Gap(10),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (_, ii) {
                            final PromoModel promo = model.promos[ii];
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        //TODO: fix image
                                        // ClipRRect(
                                        //   borderRadius: BorderRadius.only(
                                        //     topLeft: Radius.circular(8),
                                        //     bottomLeft: Radius.circular(8),
                                        //   ),
                                        //   child: SizedBox(
                                        //     width: 120,
                                        //     child: Image.asset(
                                        //       promo.promoType == 1
                                        //           ? "packages/nomnom_util/assets/images/delivery.jpg"
                                        //           : promo.promoType == 2
                                        //           ? "packages/nomnom_util/assets/images/price.jpg"
                                        //           : "packages/nomnom_util/assets/images/delivery_price.jpg",
                                        //       fit: BoxFit.cover,
                                        //       width: 120,
                                        //     ),
                                        //   ),
                                        // ),
                                        // Ticket edge notches
                                        Positioned(
                                          right: -6,
                                          top: 20,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF8F8F8),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: -6,
                                          bottom: 20,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF8F8F8),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Right content section
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Header with title and selection
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Main title
                                                      Text(
                                                        promo.title
                                                            .capitalizeWords(),
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: promo.isUsed
                                                              ? Colors
                                                                    .grey
                                                                    .shade600
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        promo.promoCode
                                                            .capitalizeWords(),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: promo.isUsed
                                                              ? Colors
                                                                    .grey
                                                                    .shade600
                                                              : ColorPalette()
                                                                    .orangePalette,
                                                        ),
                                                      ),
                                                      Gap(4),
                                                      // Minimum spend
                                                      Text(
                                                        promo.minimumOrderAmount >
                                                                0
                                                            ? "Min. Spend ₱${promo.minimumOrderAmount.toInt()}"
                                                            : "Min. Spend ₱0",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Selection circle
                                                GestureDetector(
                                                  onTap: promo.isUsed
                                                      ? null
                                                      : () async {
                                                          final navigator =
                                                              Navigator.of(
                                                                context,
                                                              );
                                                          // Check if tapping on already selected promo to deselect
                                                          if (_selectedPromo
                                                                  ?.promoCode ==
                                                              promo.promoCode) {
                                                            debugPrint(
                                                              "DESELECTING PROMO",
                                                            );

                                                            // Call the callback to notify parent about deselection
                                                            await widget
                                                                .onPromoSelected(
                                                                  promo,
                                                                );

                                                            setState(() {
                                                              _selectedPromo =
                                                                  null;
                                                            });
                                                            navigator.pop();
                                                            return;
                                                          }

                                                          // Otherwise, select the promo
                                                          final shouldPop =
                                                              await widget
                                                                  .onPromoSelected(
                                                                    promo,
                                                                  );

                                                          debugPrint(
                                                            "PROMO IS : ${promo.toJson()}",
                                                          );

                                                          debugPrint(
                                                            "SELECTED PRICING SUBTOTAL: ${promo.promoType}",
                                                          );

                                                          setState(() {
                                                            if (shouldPop) {
                                                              _selectedPromo =
                                                                  promo;
                                                            }
                                                          });

                                                          if (shouldPop) {
                                                            navigator.pop();
                                                          }
                                                        },
                                                  child: Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: promo.isUsed
                                                          ? Colors.grey.shade300
                                                          : (_selectedPromo
                                                                        ?.promoCode ==
                                                                    promo
                                                                        .promoCode
                                                                ? ColorPalette
                                                                      .orange
                                                                : Colors
                                                                      .transparent),
                                                      border: Border.all(
                                                        color: promo.isUsed
                                                            ? Colors
                                                                  .grey
                                                                  .shade300
                                                            : (_selectedPromo
                                                                          ?.promoCode ==
                                                                      promo
                                                                          .promoCode
                                                                  ? ColorPalette
                                                                        .orange
                                                                  : Colors
                                                                        .grey
                                                                        .shade400),
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child:
                                                        (promo.isUsed ||
                                                            _selectedPromo
                                                                    ?.promoCode ==
                                                                promo.promoCode)
                                                        ? Icon(
                                                            Icons.check,
                                                            color: promo.isUsed
                                                                ? Colors
                                                                      .grey
                                                                      .shade600
                                                                : Colors.white,
                                                            size: 16,
                                                          )
                                                        : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Gap(8),
                                            Row(
                                              children: [
                                                Text(
                                                  "Valid Till: ${format.format(promo.endDate)}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                Gap(8),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            TermsAndConditionsPage(),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    "T&C",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, ii) => const Gap(10),
                          itemCount: model.promos.length,
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (_, i) => const Gap(20),
                  itemCount: filteredData.length,
                );
              },
              error: (error, s) => Container(),
              loading: () => Center(
                child: CustomLoader(
                  color: darkGrey,
                  label: "Fetching promo codes",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
