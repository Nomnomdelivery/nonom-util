extension CurrencyFormat on num {
  String toAmount({String currency = "₱"}) {
    return "$currency${toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
  }
}
