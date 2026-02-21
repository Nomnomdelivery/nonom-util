import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nomnom_util/extensions/color_ext.dart';
import 'package:nomnom_util/extensions/num_currency_format.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/models/menu/item_variation.dart';
import 'package:nomnom_util/models/menu_variation.dart';
import 'package:nomnom_util/utils/color_pallete.dart';

class VariationDisplay extends FormField<MenuVariation?> {
  VariationDisplay({
    super.key,
    required String placeholderImage,
    required ItemVariation model,
    required List<MenuVariation> optionChoices,
    required ValueChanged<MenuVariation?> onChanged,
    required double markup,
  }) : super(
         initialValue: null,
         validator: (selected) {
           if (selected == null) {
             return "${model.name.capitalize()} is required";
           }
           return null;
         },
         builder: (FormFieldState<MenuVariation?> state) {
           return _VariationDisplay(
             model: model,
             errorText: state.errorText,
             onSelected: (onSelected) {
               state.didChange(onSelected);
               onChanged(onSelected);
             },
             selected: state.value,
             placeholderImage: placeholderImage,
             markup: markup,
           );
         },
       );
}

class _VariationDisplay extends StatefulWidget {
  const _VariationDisplay({
    required this.model,
    required this.errorText,
    required this.onSelected,
    required this.placeholderImage,
    required this.markup,
    required this.selected,
  });
  final ItemVariation model;
  final MenuVariation? selected;
  final String placeholderImage;
  final ValueChanged<MenuVariation?> onSelected;
  final String? errorText;
  final double markup;

  @override
  State<_VariationDisplay> createState() => _VariationDisplayState();
}

class _VariationDisplayState extends State<_VariationDisplay>
    with ColorPalette {
  late final List<MenuVariation> _displayData = List.from(
    widget.model.variations,
  );
  @override
  Widget build(BuildContext context) {
    // Sort variations by price (ascending)
    _displayData.sort((a, b) => a.price.compareTo(b.price));

    // Layout constants
    const double imageSize = 101;
    const double gapAfterImage = 6; // space between image and price
    const double gapAfterPrice = 4; // space between price and name
    const int maxNameLines = 6; // safety cap; adjust as needed

    // Text styles
    const TextStyle nameStyle = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 12,
      height: 1.1,
    );
    final TextStyle priceStyle = TextStyle(
      fontFamily: '',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: grey.darken(),
      height: 1.1,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text.rich(
            TextSpan(
              text: "Choose your ${widget.model.name}",
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(
                  text: " (1 Required)",
                  style: TextStyle(
                    color: orangePalette,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(10),
        // Horizontal scroll using Row so height grows naturally to tallest child (no manual measuring)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < _displayData.length; i++) ...[
                _VariationItem(
                  variation: _displayData[i],
                  isSelected: widget.selected?.id == _displayData[i].id,
                  imageSize: imageSize,
                  gapAfterImage: gapAfterImage,
                  gapAfterPrice: gapAfterPrice,
                  priceStyle: priceStyle,
                  nameStyle: nameStyle,
                  maxNameLines: maxNameLines,
                  markup: widget.markup,
                  placeholderImage: widget.placeholderImage,
                  onTap: () {
                    final opt = _displayData[i];
                    if (!opt.isActive) return;
                    if (widget.selected?.id == opt.id) {
                      widget.onSelected(null);
                    } else {
                      widget.onSelected(opt);
                    }
                    if (mounted) setState(() {});
                  },
                  orangeBorder: orangePalette,
                  neutralBorder: textField,
                ),
                if (i != _displayData.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        ),

        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 20),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _VariationItem extends StatelessWidget {
  const _VariationItem({
    required this.variation,
    required this.isSelected,
    required this.imageSize,
    required this.gapAfterImage,
    required this.gapAfterPrice,
    required this.priceStyle,
    required this.nameStyle,
    required this.maxNameLines,
    required this.markup,
    required this.placeholderImage,
    required this.onTap,
    required this.orangeBorder,
    required this.neutralBorder,
  });
  final MenuVariation variation;
  final bool isSelected;
  final double imageSize;
  final double gapAfterImage;
  final double gapAfterPrice;
  final TextStyle priceStyle;
  final TextStyle nameStyle;
  final int maxNameLines;
  final double markup;
  final String placeholderImage;
  final VoidCallback onTap;
  final Color orangeBorder;
  final Color neutralBorder;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: variation.name,
      child: GestureDetector(
        onTap: variation.isActive ? onTap : null,
        child: SizedBox(
          width: imageSize,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    height: imageSize,
                    width: imageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? orangeBorder : neutralBorder,
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: CachedNetworkImage(
                        imageUrl:
                            variation.photoUrl.contains("placeholder") ||
                                variation.photoUrl.contains("no_image")
                            ? placeholderImage
                            : variation.photoUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (!variation.isActive)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: gapAfterImage),
              Text(
                (variation.price * (1 + markup)).ceil().toAmount(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: priceStyle,
              ),
              SizedBox(height: gapAfterPrice),
              Text(
                variation.name.capitalize(),
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: maxNameLines,
                overflow: TextOverflow.ellipsis,
                style: nameStyle,
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
