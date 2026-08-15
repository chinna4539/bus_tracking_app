import 'package:flutter/material.dart';

import '../models/bus_info.dart';
import '../models/bus_route.dart';
import '../models/bus_stop.dart';
import '../models/live_location.dart';
import '../services/firestore_service.dart';

class FirestoreProvider extends ChangeNotifier {
  final FirestoreService _service;

  FirestoreProvider({FirestoreService? service})
    : _service = service ?? FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;
  List<BusInfo> _buses = [];
  List<BusRoute> _routes = [];
  List<BusStop> _stops = [];
  final Map<String, LiveLocation> _liveLocations = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BusInfo> get buses => List.unmodifiable(_buses);
  List<BusRoute> get routes => List.unmodifiable(_routes);
  List<BusStop> get stops => List.unmodifiable(_stops);
  Map<String, LiveLocation> get liveLocations =>
      Map.unmodifiable(_liveLocations);

  LiveLocation? getLiveLocationForBus(String busId) =>
      _liveLocations[busId];

  Future<void> loadInitialData() async {
    _setLoading(true);
    try {
      _errorMessage = null;
      _buses = await _service.fetchBuses();
      _routes = await _service.fetchRoutes();
      _stops = await _service.fetchStops();
      for (final bus in _buses) {
        final live = await _service.fetchLiveLocationForBus(bus.busNumber);
        if (live != null) {
          _liveLocations[bus.busNumber] = live;
        }
      }
    } catch (error) {
      _errorMessage = 'Unable to reach Firebase. Please check your connection.';
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
