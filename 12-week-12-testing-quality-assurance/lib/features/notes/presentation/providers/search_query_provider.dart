import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier modern Riverpod 3 untuk menampung query pencarian judul catatan.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);
