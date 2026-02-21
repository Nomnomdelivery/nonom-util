import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/models/menu/menu_item.dart';
import 'package:nomnom_util/models/type_menu_item.dart';

class MealInclusionView extends StatelessWidget {
  const MealInclusionView({
    super.key,
    required this.items,
    required this.placeholderImage,
  });
  final List<TypedMenuItem> items;
  final String placeholderImage;
  @override
  Widget build(BuildContext context) {
    final double optionHeight = 130;
    items.sort((a, b) => a.menu.price.compareTo(b.menu.price));
    bool isBundle = items.any((e) => e.type == "meal_items");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: "${isBundle ? "Meal" : "Menu"} Inclusions",
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              children: [],
            ),
          ),
          const Gap(10),
          SizedBox(
            height: optionHeight,
            width: double.infinity,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                final MenuItem item = items[i].menu;
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: CachedNetworkImage(
                        imageUrl:
                            item.photoUrl.contains("placeholder") ||
                                item.photoUrl.contains("no_image")
                            ? placeholderImage
                            : item.photoUrl,
                        fit: BoxFit.cover,
                        width: optionHeight * 0.8,
                        height: optionHeight * 0.8,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.name.capitalize(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, i) => const SizedBox(width: 10),
              itemCount: items.length,
            ),
          ),
        ],
      ),
    );
  }
}
