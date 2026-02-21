import 'package:nomnom_util/models/categorized_promo.dart';
import 'package:nomnom_util/models/promo.dart';

extension LISTPARSER on List<PromoModel> {
  String mapPromoTypeToString(int promoType) {
    switch (promoType) {
      case 1:
        return "Free Delivery";
      case 2:
        return "Order Discount";
      case 3:
        return "Total Order Discount";
      default:
        return "Unknown Type";
    }
  }

  List<CategorizedPromoModel> categorize() {
    final Map<int, List<PromoModel>> groupedPromos = {};
    // Group promos by promoType
    for (var promo in this) {
      if (!groupedPromos.containsKey(promo.promoType)) {
        groupedPromos[promo.promoType] = [];
      }
      groupedPromos[promo.promoType]!.add(promo);
    }
    return groupedPromos.entries.map((entry) {
      final promoType = entry.key;
      return CategorizedPromoModel(
        promoType: promoType,
        promoTypeString: mapPromoTypeToString(promoType),
        promos: entry.value,
      );
    }).toList();
  }
}
