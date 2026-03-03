import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/option/sub_option.dart';

class SubOptionSelection extends ConsumerStatefulWidget {
  const SubOptionSelection({
    super.key,
    required this.choices,
    required this.onSelect,
    required this.groupname,
    required this.areaSettingsProvider,
  });
  final List<SubOption> choices;
  final ValueChanged<SubOption> onSelect;
  final String groupname;
  final StateProvider<AreaSetting?> areaSettingsProvider;
  @override
  ConsumerState<SubOptionSelection> createState() => _SubOptionSelectionState();
}

class _SubOptionSelectionState extends ConsumerState<SubOptionSelection> {
  @override
  Widget build(BuildContext context) {
    widget.choices.sort((a, b) => a.price.compareTo(b.price));
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Text(
                "Please select 1 item from ${widget.groupname}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Gap(20),
              ...widget.choices.map(
                (e) => ListTile(
                  onTap: () {
                    widget.onSelect(e);
                    Navigator.of(context).pop();
                  },
                  title: Text(e.name),
                  subtitleTextStyle: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: e.availability == 1
                        ? Colors.grey.shade600
                        : Colors.red,
                  ),
                  titleTextStyle: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: e.availability == 1
                        ? Colors.grey.shade800
                        : Colors.red,
                  ),
                  subtitle: Text(
                    e.price == 0
                        ? "No additional charge"
                        : "+${calculateTotalSubtotal(e.price).toStringAsFixed(2)}",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double calculateTotalSubtotal(double price) {
    final AreaSetting? settings = ref.watch(widget.areaSettingsProvider);
    final markUpRate = settings == null
        ? .05
        : settings.setting.markupRate / 100;
    return (price * (1 + markUpRate)).ceilToDouble();
  }
}
