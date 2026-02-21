extension CAPITALIZER on String {
  String capitalize() =>
      "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  String capitalizeWords() {
    try {
      List<String> words = split(" ");
      for (int i = 0; i < words.length; i++) {
        String word = words[i];
        if (word.isNotEmpty) {
          words[i] = "${word[0].toUpperCase()}${word.substring(1)}";
        }
      }
      return words.join(" ");
    } catch (e) {
      return this;
    }
  }
}
