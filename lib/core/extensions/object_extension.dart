
extension ObjectExtension on Object? {
  T? castOrNull<T>() => this is T ? this as T : null;

  T castOrFallback<T>(T fallback) => this is T ? this as T : fallback;

  String toSafeString() {
    if (this == null) {
      return 'null';
    } else if (this is String) {
      return this as String;
    } else if (this is num || this is bool) {
      return toString();
    } else {
      return 'Unsupported type';
    }
  }
}