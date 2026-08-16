import 'package:flutter/material.dart';

import '../models/alert_info.dart';
import '../models/bus_info.dart';
import '../models/bus_route.dart';
import '../models/bus_stop.dart';
import '../models/live_location.dart';
import '../models/search_result.dart';
import '../providers/firestore_provider.dart';
import '../services/bus_data_service.dart';

class BusDataProvider extends ChangeNotifier {
  final List<BusInfo> _favouriteBuses = [];
  final List<BusRoute> _favouriteRoutes = [];
  final List<BusStop> _favouriteStops = [];
  final List<String> _recentSearches = [];
  String _searchQuery = '';
  FirestoreProvider? _firestoreProvider;

  List<BusInfo> get favouriteBuses => List.unmodifiable(_favouriteBuses);
  List<BusRoute> get favouriteRoutes => List.unmodifiable(_favouriteRoutes);
  List<BusStop> get favouriteStops => List.unmodifiable(_favouriteStops);
  List<String> get recentSearches =>
      List.unmodifiable(_recentSearches.reversed);
  String get searchQuery => _searchQuery;

  bool get isFirestoreLoading => _firestoreProvider?.isLoading ?? false;
  String? get firestoreErrorMessage => _firestoreProvider?.errorMessage;
  bool get hasLoadedFirestore => _firestoreProvider?.hasLoaded ?? false;

  List<BusInfo> get firestoreBuses => List.unmodifiable(_firestoreProvider?.buses ?? const []);

  List<BusInfo> get nearbyBuses {
    final source = _firestoreProvider?.buses;
    final hasLoaded = _firestoreProvider?.hasLoaded ?? false;
    if (hasLoaded) {
      return source ?? const [];
    }
    return (source != null && source.isNotEmpty)
        ? source
        : BusDataService.buses;
  }

  List<BusRoute> get popularRoutes {
    final source = _firestoreProvider?.routes;
    return (source != null && source.isNotEmpty)
        ? source
        : BusDataService.routes;
  }

  List<AlertInfo> get alerts => BusDataService.alerts;

  List<BusStop> get allStops {
    final source = _firestoreProvider?.stops;
    return (source != null && source.isNotEmpty)
        ? source
        : BusDataService.stops;
  }

  bool hasLiveLocation(String busNumber) =>
      _firestoreProvider?.getLiveLocationForBus(busNumber) != null;

  LiveLocation? getLiveLocation(String busNumber) =>
      _firestoreProvider?.getLiveLocationForBus(busNumber);

  void setFirestoreProvider(FirestoreProvider provider) {
    if (_firestoreProvider == provider) {
      return;
    }

    _firestoreProvider?.removeListener(_handleFirestoreUpdate);
    _firestoreProvider = provider;
    _firestoreProvider?.addListener(_handleFirestoreUpdate);

    if (!_firestoreProvider!.isLoading) {
      _handleFirestoreUpdate();
    }

    _firestoreProvider!.loadInitialData();
  }

  void _handleFirestoreUpdate() {
    notifyListeners();
  }

  List<SearchResult> get searchResults {
    if (_searchQuery.isEmpty) {
      return [];
    }

    final lowerQuery = _searchQuery.toLowerCase();
    final results = <SearchResult>[];

    final busSource = hasLoadedFirestore ? firestoreBuses : nearbyBuses;
    final routeSource = hasLoadedFirestore
        ? (_firestoreProvider?.routes ?? const [])
        : BusDataService.routes;
    final stopSource = hasLoadedFirestore
        ? (_firestoreProvider?.stops ?? const [])
        : BusDataService.stops;

    final matchedBuses = busSource.where((bus) {
      if (_matchesCategory(lowerQuery, bus)) {
        return true;
      }
      return bus.busNumber.toLowerCase().contains(lowerQuery) ||
          bus.routeNumber.toLowerCase().contains(lowerQuery) ||
          bus.routeName.toLowerCase().contains(lowerQuery) ||
          bus.startingPoint.toLowerCase().contains(lowerQuery) ||
          bus.destination.toLowerCase().contains(lowerQuery) ||
          bus.stops.any(
            (stop) => stop.toLowerCase().contains(lowerQuery),
          );
    });

    results.addAll(
      matchedBuses.map(
        (bus) => SearchResult(
          type: SearchResultType.bus,
          title: bus.busNumber,
          subtitle: '${bus.routeName} • ${bus.statusLabel}',
          item: bus,
        ),
      ),
    );

    results.addAll(
      routeSource
          .where((route) {
            return route.routeNumber.toLowerCase().contains(lowerQuery) ||
                route.title.toLowerCase().contains(lowerQuery) ||
                route.stops.any(
                  (stop) => stop.toLowerCase().contains(lowerQuery),
                );
          })
          .map(
            (route) => SearchResult(
              type: SearchResultType.route,
              title: 'Route ${route.routeNumber}',
              subtitle: route.title,
              item: route,
            ),
          ),
    );

    results.addAll(
      stopSource
          .where((stop) {
            return stop.name.toLowerCase().contains(lowerQuery);
          })
          .map(
            (stop) => SearchResult(
              type: SearchResultType.stop,
              title: stop.name,
              subtitle: 'Bus stop',
              item: stop,
            ),
          ),
    );

    return results;
  }

  bool _matchesCategory(String lowerQuery, BusInfo bus) {
    if (lowerQuery == 'express') {
      return bus.busType == BusType.express;
    }
    if (lowerQuery == 'city') {
      return bus.busType == BusType.standard;
    }
    if (lowerQuery == 'night') {
      final routeSource = hasLoadedFirestore
          ? (_firestoreProvider?.routes ?? BusDataService.routes)
          : BusDataService.routes;
      final route = routeSource
          .firstWhere((r) => r.routeNumber == bus.routeNumber, orElse: () => routeSource.first);
      return route.lastBus.toLowerCase().contains('pm');
    }
    return false;
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  void addRecentSearch(String query) {
    if (query.isEmpty) return;
    _recentSearches.remove(query);
    _recentSearches.add(query);
    if (_recentSearches.length > 5) {
      _recentSearches.removeAt(0);
    }
    notifyListeners();
  }

  void toggleFavouriteBus(BusInfo bus) {
    if (_favouriteBuses.contains(bus)) {
      _favouriteBuses.remove(bus);
    } else {
      _favouriteBuses.add(bus);
    }
    notifyListeners();
  }

  void toggleFavouriteBusByNumber(String busNumber) {
    final busSource = hasLoadedFirestore ? firestoreBuses : BusDataService.buses;
    final bus = busSource.firstWhere(
      (candidate) => candidate.busNumber == busNumber,
      orElse: () => busSource.first,
    );
    toggleFavouriteBus(bus);
  }

  void toggleFavouriteRoute(BusRoute route) {
    if (_favouriteRoutes.contains(route)) {
      _favouriteRoutes.remove(route);
    } else {
      _favouriteRoutes.add(route);
    }
    notifyListeners();
  }

  void toggleFavouriteRouteByNumber(String routeNumber) {
    final routeSource = hasLoadedFirestore
        ? (_firestoreProvider?.routes ?? BusDataService.routes)
        : BusDataService.routes;
    final route = routeSource.firstWhere(
      (candidate) => candidate.routeNumber == routeNumber,
      orElse: () => routeSource.first,
    );
    toggleFavouriteRoute(route);
  }

  void toggleFavouriteStop(BusStop stop) {
    if (_favouriteStops.contains(stop)) {
      _favouriteStops.remove(stop);
    } else {
      _favouriteStops.add(stop);
    }
    notifyListeners();
  }

  void toggleFavouriteStopByName(String stopName) {
    final stopSource = hasLoadedFirestore
        ? (_firestoreProvider?.stops ?? BusDataService.stops)
        : BusDataService.stops;
    final stop = stopSource.firstWhere(
      (candidate) => candidate.name == stopName,
      orElse: () => stopSource.first,
    );
    toggleFavouriteStop(stop);
  }

  bool isFavouriteBus(BusInfo bus) => _favouriteBuses.contains(bus);
  bool isFavouriteRoute(BusRoute route) => _favouriteRoutes.contains(route);
  bool isFavouriteStop(BusStop stop) => _favouriteStops.contains(stop);
}
