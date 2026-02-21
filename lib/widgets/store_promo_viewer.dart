import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nomnom_util/models/promo.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/custom_loader.dart';
import 'package:nomnom_util/widgets/ticket_clipper.dart';

class StorePromoViewer extends ConsumerStatefulWidget {
  const StorePromoViewer({
    super.key,
    required this.provider,
    required this.onSizeChanged,
  });
  final FutureProvider<List<PromoModel>> provider;
  final ValueChanged<Size> onSizeChanged;
  @override
  ConsumerState<StorePromoViewer> createState() => _StorePromoViewerState();
}

class _StorePromoViewerState extends ConsumerState<StorePromoViewer> {
  final DateFormat format = DateFormat('dd MMM yyyy');
  @override
  Widget build(BuildContext context) {
    final result = ref.watch(widget.provider);
    final Size size = MediaQuery.of(context).size;
    return result.when(
      data: (data) {
        if (data.isEmpty) {
          return SizedBox(
            height: size.height - 356,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/rider.png", height: 120),
                  const Gap(20),
                  Text("No promos generated yet."),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemBuilder: (_, i) {
            final PromoModel promo = data[i];
            return GestureDetector(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: promo.promoCode));
                Fluttertoast.showToast(msg: "Code copied to clipboard");
              },
              child: ClipPath(
                clipper: TicketClipper(),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            promo.promoType == 1
                                ? "Free Delivery"
                                : "Rewards: ${promo.valueType == 1 ? "₱" : ""}${promo.value.toInt()}${promo.valueType == 2 ? "%" : ""} OFF",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "${promo.valueType == 1 ? "₱" : ""}${promo.valueType == 1 ? promo.value.toStringAsFixed(2) : promo.value.toInt()}${promo.valueType == 2 ? "%" : ""}",
                            style: TextStyle(
                              fontFamily: "",
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        promo.promoCode,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ColorPalette.orange,
                        ),
                      ),
                      // Text(format.format(promo.startDate)),
                      const Gap(15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            promo.minimumOrderAmount > 0
                                ? "₱ ${promo.minimumOrderAmount.toStringAsFixed(2)} minimum"
                                : "No minimum order",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Valid until ${format.format(promo.endDate).toLowerCase()}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: ColorPalette.sTextField),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (_, i) => const Gap(10),
          itemCount: data.length,
        );
      },
      error: (e, s) => Container(),
      loading: () {
        return SizedBox(
          height: 250,
          child: Center(
            child: CustomLoader(
              label: "Fetching store promos",
              color: Colors.black.withValues(alpha: .5),
            ),
          ),
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);

    // Create wave
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 60);
    var secondEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
