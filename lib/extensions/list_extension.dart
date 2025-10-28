extension ListExtension<T> on List<T> {
  List<T> uniqueBy<K>(K Function(T) keySelector) {
    final seen = <K>{};
    return where((element) => seen.add(keySelector(element))).toList();
  }
}
