class UserEx<T, X> {
  final Object value;
  const UserEx({required this.value});
  Object get() => value;

  @override
  String toString() => 'UserEx($value)';

  R fold<R>(R Function(T val) onT, R Function(X val) onX) {
    if (value is T) {
      return onT(value as T);
    } else {
      return onX(value as X);
    }
  }
}
