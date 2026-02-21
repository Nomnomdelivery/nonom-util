import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/models/merchant/merchant_with_city.dart';
import 'package:nomnom_util/utils/computation.dart';

class StoreHeader extends StatelessWidget {
  const StoreHeader({
    super.key,
    required this.model,
    required this.changePage,
    required this.size,
  });

  final MerchantWithCity model;
  final VoidCallback changePage;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Hero(
              tag: "${model.id}${model.coverPhotoUrl}",
              child: CachedNetworkImage(
                imageUrl: model.coverPhotoUrl,
                fit: BoxFit.cover,
                height: c.maxHeight * 0.55,
                width: size.width,
                errorWidget: (context, url, error) => Container(
                  height: c.maxHeight * 0.55,
                  width: size.width,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.restaurant,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: 0,
              right: 0,
              child: Container(
                height: c.maxHeight * .7,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //TODO: fix image
                    // Hero(
                    //   tag: "${model.id}${model.photoUrl}",
                    //   child: ClipRRect(
                    //     borderRadius: BorderRadius.circular(10),
                    //     child: CachedNetworkImage(
                    //       imageUrl: model.photoUrl,
                    //       width: 80,
                    //       height: 80,
                    //       fit: BoxFit.cover,
                    //       errorWidget: (context, url, error) => Image.asset(
                    //         'packages/nomnom_util/assets/images/customer.jpg',
                    //         width: 80,
                    //         height: 80,
                    //         fit: BoxFit.cover,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const Gap(15),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, cc) {
                          return Container(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Hero(
                                        tag: model.name,
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 0,
                                          child: Text(
                                            model.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .fontSize!,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Gap(10),
                                    GestureDetector(
                                      onTap: changePage,
                                      child: const Icon(Icons.chevron_right),
                                    ),
                                  ],
                                ),
                                Hero(
                                  tag: model.displayAddressString,
                                  child: Material(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    child: Text(
                                      model.displayAddressString,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withValues(
                                          alpha: .5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),

                                StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('store-schedule')
                                      .doc(model.id.toString())
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Row(
                                        children: [
                                          const CircularProgressIndicator.adaptive(),
                                          const SizedBox(width: 5),
                                          Text(
                                            "Fetching Schedule",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black.withValues(
                                                alpha: 0.5,
                                              ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    if (!snapshot.data!.exists ||
                                        !snapshot.hasData) {
                                      return Row(
                                        children: [
                                          Text(
                                            "No Schedule",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black.withValues(
                                                alpha: 0.5,
                                              ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    final rawData =
                                        snapshot.data!.data()
                                            as Map<String, dynamic>;
                                    final schedule =
                                        rawData['current_schedule']
                                            as Map<String, dynamic>? ??
                                        {};
                                    final overrideStatus =
                                        rawData['override_status'] as String?;

                                    final now = DateTime.now();
                                    final isOpen = computeStoreOpenStatus(
                                      overrideStatus: overrideStatus,
                                      schedule: schedule,
                                      now: now,
                                    );

                                    final label = isOpen ? "Open" : "Closed";

                                    final Color badgeColor = isOpen
                                        ? Colors.green
                                        : Colors.red;

                                    final String untilTime = isOpen
                                        ? schedule['close']
                                              .toString()
                                              .toTimeOfDay
                                              .format(context)
                                        : schedule['open']
                                              .toString()
                                              .toTimeOfDay
                                              .format(context);

                                    return Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: badgeColor,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            label,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Until $untilTime",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black.withValues(
                                              alpha: 0.5,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
