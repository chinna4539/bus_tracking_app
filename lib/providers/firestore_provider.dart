import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

import '../models/bus_info.dart';
import '../models/bus_route.dart';
import '../models/bus_stop.dart';
import '../models/live_location.dart';
import '../services/firestore_service.dart';

class FirestoreProvider extends ChangeNotifier {
  final FirestoreService _service;

  FirestoreProvider({FirestoreService? service})
      : _service = service ?? FirestoreService() {
    _startRealtimeListeners();
    _authSubscription = firebase_auth.FirebaseAuth.instance.authStateChanges().listen((_) {
      if (firebase_auth.FirebaseAuth.instance.currentUser != null) {
        _restartRealtimeListeners();
      }
    });
  }

  bool _isLoading = true;
  String? _errorMessage;
  bool _hasLoaded = false;
  List<BusInfo> _buses = [];
  List<BusRoute> _routes = [];
  List<BusStop> _stops = [];
  final Map<String, LiveLocation> _liveLocations = {};
  StreamSubscription<List<BusInfo>>? _busesSubscription;
  StreamSubscription<List<BusRoute>>? _routesSubscription;
  StreamSubscription<List<BusStop>>? _stopsSubscription;
  StreamSubscription<firebase_auth.User?>? _authSubscription;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoaded => _hasLoaded;
  List<BusInfo> get buses => List.unmodifiable(_buses);
  List<BusRoute> get routes => List.unmodifiable(_routes);
  List<BusStop> get stops => List.unmodifiable(_stops);
  Map<String, LiveLocation> get liveLocations =>
      Map.unmodifiable(_liveLocations);

  LiveLocation? getLiveLocationForBus(String busId) =>
      _liveLocations[busId];

  void _startRealtimeListeners() {
    _busesSubscription = _service.watchBuses().listen(
      (buses) {
        _buses = buses;
        _isLoading = false;
        _hasLoaded = true;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _hasLoaded = true;
        _errorMessage = 'Unable to reach Firebase. Please check your connection.';
        notifyListeners();
      },
    );

    _routesSubscription = _service.watchRoutes().listen(
      (routes) {
        _routes = routes;
        notifyListeners();
      },
      onError: (_) {
        // Route stream error is non-fatal for bus data.
      },
    );

    _stopsSubscription = _service.watchStops().listen(
      (stops) {
        _stops = stops;
        notifyListeners();
      },
      onError: (_) {
        // Stops stream error is non-fatal for bus data.
      },
    );
  }

  void _restartRealtimeListeners() {
    _busesSubscription?.cancel();
    _routesSubscription?.cancel();
    _stopsSubscription?.cancel();
    _errorMessage = null;
    _isLoading = true;
    _hasLoaded = false;
    _startRealtimeListeners();
  }

  Future<void> loadInitialData() async {
    // Realtime listeners already provide initial data.
    // This method is kept for backward compatibility.
    if (_hasLoaded && !_isLoading) {
      return;
    }
  }

  @override
  void dispose() {
    _busesSubscription?.cancel();
    _routesSubscription?.cancel();
    _stopsSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
