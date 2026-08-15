import 'package:bus_tracking_app/providers/bus_data_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clearRecentSearches removes stored searches', () {
    final provider = BusDataProvider();

    provider.addRecentSearch('MVP Colony');
    provider.addRecentSearch('Airport');

    provider.clearRecentSearches();

    expect(provider.recentSearches, isEmpty);
  });
}
