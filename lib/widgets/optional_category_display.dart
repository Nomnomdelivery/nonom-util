import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/extensions/color_ext.dart';
import 'package:nomnom_util/extensions/num_currency_format.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/option/neo_option.dart';
import 'package:nomnom_util/models/option/option_category.dart';
import 'package:nomnom_util/models/option/sub_option.dart';
import 'package:nomnom_util/models/selected_option.dart';
import 'package:nomnom_util/models/selected_sub_option.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/widgets/sub_selection.dart';

class OptionCategoryDisplay extends FormField<List<SelectedOption>> {
  OptionCategoryDisplay({
    super.key,
    required OptionCategory model,
    required String placeholderImage,
    required int requiredCount,
    required List<NeoOption> optionChoices,
    ValueChanged<List<SelectedOption>>? onChanged,
    FormFieldValidator<List<SelectedOption>>? validator,
    required StateProvider<AreaSetting?> areaSettingsProvider,
    required double markup,
  }) : super(
         initialValue: [],
         validator: (selectedOptions) {
           if (selectedOptions == null ||
               selectedOptions.length < requiredCount) {
             return "${model.name.capitalize()} requires $requiredCount option${requiredCount > 1 ? "s" : ""}, please select more.";
           }
           for (var option in selectedOptions) {
             final src = optionChoices.where((e) => e.id == option.id).first;
             if (src.subOptions.isNotEmpty && option.suboption == null) {
               return "${option.name} requires at least one sub-option to be selected.";
             }
           }
           return null;
         },
         builder: (FormFieldState<List<SelectedOption>> state) {
           return _OptionCategoryDisplay(
             markup: markup,
             model: model,
             placeholderImage: placeholderImage,
             selectedOptions: state.value!,
             onSelected: (updatedSelectedOptions) {
               state.didChange(updatedSelectedOptions);
               if (onChanged != null) {
                 onChanged(updatedSelectedOptions);
               }
             },
             errorText: state.errorText,
             areaSettingsProvider: areaSettingsProvider,
           );
         },
       );
}

class _OptionCategoryDisplay extends StatefulWidget {
  final OptionCategory model;
  final String placeholderImage;
  final List<SelectedOption> selectedOptions;
  final ValueChanged<List<SelectedOption>> onSelected;
  final String? errorText;
  final double markup;
  final StateProvider<AreaSetting?> areaSettingsProvider;

  const _OptionCategoryDisplay({
    required this.model,
    required this.placeholderImage,
    required this.selectedOptions,
    required this.onSelected,
    required this.markup,
    this.errorText,
    required this.areaSettingsProvider,
  });

  @override
  State<_OptionCategoryDisplay> createState() => _OptionCategoryDisplayState();
}

class _OptionCategoryDisplayState extends State<_OptionCategoryDisplay>
    with ColorPalette {
  late List<SelectedOption> selectedOptions;

  @override
  void initState() {
    super.initState();
    selectedOptions = List<SelectedOption>.from(widget.selectedOptions);
  }

  String selectedSubOptionPriceDisplay(NeoOption opt, double markup) {
    if (opt.subOptions.isEmpty) {
      return '+${(opt.price * (1 + markup)).ceilToDouble().toAmount()}';
    }
    final SelectedOption? s = selectedOptions
        .where((e) => e.id == opt.id)
        .firstOrNull;
    if (s == null) return 'Please select';
    if (s.suboption == null) {
      return 'Please select';
    } else {
      if (s.suboption!.price == 0) {
        return 'No additional charge';
      }
      return '+${(s.suboption!.price * (1 + markup)).ceilToDouble().toAmount()}(${s.suboption!.name})';
    }
  }

  Future<void> _handleTap(NeoOption opt, bool isAdded) async {
    if (isAdded) {
      if (opt.subOptions.isEmpty) {
        selectedOptions.removeWhere((e) => e.id == opt.id);
      } else {
        await showModalBottomSheet(
          context: context,
          barrierColor: Colors.black54,
          barrierLabel: "",
          isDismissible: true,
          backgroundColor: Colors.transparent,
          builder: (context) => SubOptionSelection(
            groupname: opt.groupName ?? "N/A",
            choices: opt.subOptions,
            onSelect: (SubOption sub) {
              selectedOptions.removeWhere((e) => e.id == opt.id);
              selectedOptions.add(
                SelectedOption(
                  id: opt.id,
                  name: opt.name,
                  imageUrl: opt.image,
                  suboption: SelectedSubOption(
                    id: sub.id,
                    name: sub.name,
                    price: sub.price,
                  ),
                  price: opt.price,
                ),
              );
            },
            areaSettingsProvider: widget.areaSettingsProvider,
          ),
        );
      }
    } else {
      if (widget.model.requiredOptionCount == 0) {
        await _addOrSelectSubOption(opt);
      }
      if (selectedOptions.length < widget.model.requiredOptionCount) {
        await _addOrSelectSubOption(opt);
      } else if (widget.model.requiredOptionCount > 0) {
        SelectedOption newOption;
        if (opt.subOptions.isNotEmpty) {
          await showModalBottomSheet(
            context: context,
            barrierColor: Colors.black54,
            barrierLabel: "",
            isDismissible: true,
            backgroundColor: Colors.transparent,
            builder: (context) => SubOptionSelection(
              groupname: opt.groupName ?? "N/A",
              choices: opt.subOptions,
              onSelect: (SubOption sub) {
                newOption = SelectedOption(
                  id: opt.id,
                  name: opt.name,
                  imageUrl: opt.image,
                  suboption: SelectedSubOption(
                    id: sub.id,
                    name: sub.name,
                    price: sub.price,
                  ),
                  price: opt.price,
                );
                if (selectedOptions.isNotEmpty) {
                  selectedOptions[0] = newOption;
                } else {
                  selectedOptions.add(newOption);
                }
              },
              areaSettingsProvider: widget.areaSettingsProvider,
            ),
          );
        } else {
          newOption = SelectedOption(
            id: opt.id,
            name: opt.name,
            imageUrl: opt.image,
            suboption: null,
            price: opt.price,
          );
          if (selectedOptions.isNotEmpty) {
            selectedOptions[0] = newOption;
          } else {
            selectedOptions.add(newOption);
          }
        }
      }
    }
  }

  Future<void> _addOrSelectSubOption(NeoOption opt) async {
    if (opt.subOptions.isNotEmpty) {
      await showModalBottomSheet(
        context: context,
        barrierColor: Colors.black54,
        barrierLabel: "",
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SubOptionSelection(
          groupname: opt.groupName ?? "N/A",
          choices: opt.subOptions,
          onSelect: (SubOption sub) {
            selectedOptions.add(
              SelectedOption(
                id: opt.id,
                name: opt.name,
                imageUrl: opt.image,
                suboption: SelectedSubOption(
                  id: sub.id,
                  name: sub.name,
                  price: sub.price,
                ),
                price: opt.price,
              ),
            );
          },
          areaSettingsProvider: widget.areaSettingsProvider,
        ),
      );
    } else {
      selectedOptions.add(
        SelectedOption(
          id: opt.id,
          name: opt.name,
          imageUrl: opt.image,
          suboption: null,
          price: opt.price,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort options by price
    widget.model.options.sort((a, b) => a.price.compareTo(b.price));

    const double imageSize = 101;
    const double gapAfterImage = 6;
    const double gapAfterPrice = 4;

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
                  text: widget.model.requiredOptionCount == 0
                      ? " (Optional)"
                      : " (${widget.model.requiredOptionCount} Required)",
                  style: TextStyle(
                    color: widget.model.requiredOptionCount == 0
                        ? Colors.grey
                        : orangePalette,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < widget.model.options.length; i++) ...[
                Builder(
                  builder: (_) {
                    final NeoOption opt = widget.model.options[i];
                    final bool isAdded = selectedOptions.any(
                      (e) => e.id == opt.id,
                    );

                    debugPrint("OPTIONS LEN ${widget.model.options.length}");
                    return _OptionItem(
                      option: opt,
                      isSelected: isAdded,
                      imageSize: imageSize,
                      gapAfterImage: gapAfterImage,
                      gapAfterPrice: gapAfterPrice,
                      priceStyle: priceStyle,
                      nameStyle: nameStyle,
                      placeholderImage: widget.placeholderImage,
                      priceText: selectedSubOptionPriceDisplay(
                        opt,
                        widget.markup,
                      ),
                      onTap: opt.availability == 1
                          ? () async {
                              await _handleTap(opt, isAdded);
                              if (mounted) setState(() {});
                              widget.onSelected(selectedOptions);
                            }
                          : null,
                      orangeBorder: orangePalette,
                      neutralBorder: textField,
                    );
                  },
                ),
                if (i != widget.model.options.length - 1)
                  const SizedBox(width: 10),
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

class _OptionItem extends StatelessWidget {
  const _OptionItem({
    required this.option,
    required this.isSelected,
    required this.imageSize,
    required this.gapAfterImage,
    required this.gapAfterPrice,
    required this.priceStyle,
    required this.nameStyle,
    required this.placeholderImage,
    required this.priceText,
    required this.onTap,
    required this.orangeBorder,
    required this.neutralBorder,
  });

  final NeoOption option;
  final bool isSelected;
  final double imageSize;
  final double gapAfterImage;
  final double gapAfterPrice;
  final TextStyle priceStyle;
  final TextStyle nameStyle;
  final String placeholderImage;
  final String priceText;
  final VoidCallback? onTap;
  final Color orangeBorder;
  final Color neutralBorder;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: option.name,
      child: GestureDetector(
        onTap: onTap,
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
                            option.image.contains("placeholder") ||
                                option.image.contains("no_image")
                            ? placeholderImage
                            : option.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (option.availability != 1)
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
                priceText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: priceStyle,
              ),
              SizedBox(height: gapAfterPrice),
              Text(
                option.name.capitalize(),
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: nameStyle,
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
