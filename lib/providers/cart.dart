import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomnom_util/models/cart.dart';

class CurrentUserCartNotifier extends StateNotifier<List<CartModel>> {
  CurrentUserCartNotifier(super.state);
  void update(List<CartModel> m) {
    state = m;
  }

  void reset() {
    state = [];
  }
}
