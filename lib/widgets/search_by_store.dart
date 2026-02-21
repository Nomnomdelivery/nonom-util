import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/api/firebase_firestore_support.dart';
import 'package:nomnom_util/models/merchant/merchant_with_city.dart';
import 'package:nomnom_util/widgets/custom_loader.dart';
import 'package:nomnom_util/widgets/store_card.dart';

class BuildSearchByStore extends StatelessWidget {
  const BuildSearchByStore({
    super.key,
    required this.dataProvider,
    required this.isWholePage,
    required this.ffs,
  });
  final FutureProvider<List<MerchantWithCity>> dataProvider;
  final bool isWholePage;
  final FirebaseFirestoreSupport ffs;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Consumer(
      builder: (context, ref, child) {
        final result = ref.watch(dataProvider);

        return result.when(
          data: (data) {
            if (data.isEmpty) {
              return SizedBox(
                width: double.infinity,
                height: isWholePage ? size.height - 250 : 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //TODO: fix image
                    // Image.asset(
                    //   "packages/nomnom_util/assets/images/rider.png",
                    //   height: 100,
                    // ),
                    const Gap(20),
                    Text("No result found"),
                  ],
                ),
              );
            }
            return SafeArea(
              top: false,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 20,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  final MerchantWithCity m = data[i];
                  // return StoreCard(store: m, ffs: ffs);
                },
                separatorBuilder: (context, i) => const Gap(10),
                itemCount: data.length,
              ),
            );
          },
          error: (e, s) => Container(),
          loading: () => SizedBox(
            width: double.infinity,
            height: isWholePage ? size.height - 250 : 200,
            child: CustomLoader(
              color: const Color(0xFF3F3F3F),
              label: "Searching shops or restaurants",
            ),
          ),
        );
      },
    );
  }
}
