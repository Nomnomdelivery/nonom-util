import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/models/feedback/customer_feedback.dart';
import 'package:nomnom_util/models/store_feedback.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/custom_loader.dart';

class StoreReviewViewer extends ConsumerStatefulWidget {
  const StoreReviewViewer({
    super.key,
    required this.provider,
    required this.onSizeChanged,
  });
  final FutureProvider<StoreFeedback> provider;
  final ValueChanged<Size> onSizeChanged;
  @override
  ConsumerState<StoreReviewViewer> createState() => _StoreReviewViewerState();
}

class _StoreReviewViewerState extends ConsumerState<StoreReviewViewer>
    with ColorPalette {
  final GlobalKey _key = GlobalKey();
  Size _oldSize = Size(0, 0);

  void _notifySize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _key.currentContext;
      if (context != null) {
        final size = context.size;
        if (_oldSize != size && size != null) {
          _oldSize = size;
          widget.onSizeChanged(size);
        }
      }
    });
  }

  final DateFormat format = DateFormat('MMMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifySize();
    });
  }

  @override
  void didUpdateWidget(StoreReviewViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifySize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final res = ref.watch(widget.provider);

    // Listen for changes in the provider and trigger size notification
    ref.listen(widget.provider, (previous, next) {
      if (next.hasValue) {
        _notifySize();
      }
    });

    return Container(
      key: _key,
      child: res.when(
        data: (data) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reviews",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                if (data.feedbacks.isEmpty) ...{
                  const Gap(20),
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset("assets/images/rider.png", height: 120),
                          const Gap(10),
                          Text("No reviews yet."),
                        ],
                      ),
                    ),
                  ),
                } else ...{
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0,
                    ),
                    itemBuilder: (_, i) {
                      final CustomerFeedback feedback = data.feedbacks[i];
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feedback.customer.email.obscureEmail(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  format.format(feedback.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withValues(alpha: .4),
                                  ),
                                ),
                                const Gap(5),
                                Text(
                                  feedback.feedback,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Gap(10),
                          Row(
                            children: [
                              Icon(Icons.star, color: orangePalette, size: 18),
                              Text(
                                feedback.rate.toStringAsFixed(1),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (_, i) => const Gap(10),
                    itemCount: data.feedbacks.length,
                  ),
                },
              ],
            ),
          );
        },
        error: (e, s) => Container(),
        loading: () {
          return SizedBox(
            height: 250,
            child: Center(
              child: CustomLoader(
                label: "Fetching store reviews",
                color: Colors.black.withValues(alpha: .5),
              ),
            ),
          );
        },
      ),
    );
  }
}
