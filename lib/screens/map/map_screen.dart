import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/app_routes.dart';
import '../../models/bus_route.dart';
import '../../models/search_result.dart';
import '../../providers/bus_data_provider.dart';
import '../../widgets/search_results_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _visakhapatnamCoordinates = LatLng(17.6868, 83.2185);
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _visakhapatnamCoordinates,
    zoom: 13.5,
  );

  GoogleMapController? _mapController;
  bool _locationPermissionGranted = false;
  bool _permissionDenied = false;
  String? _permissionMessage;
  Position? _currentPosition;
  final Set<String> _selectedRouteNumbers = {};
  final Set<String> _selectedBusNumbers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _initLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _permissionDenied = true;
        _permissionMessage =
            'Location services are disabled. Please enable them in settings.';
      });
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      setState(() {
        _locationPermissionGranted = false;
        _permissionDenied = true;
        _permissionMessage =
            'Location permission denied. The map still works, but current location is unavailable.';
      });
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationPermissionGranted = false;
        _permissionDenied = true;
        _permissionMessage =
            'Location permission denied permanently. Please enable it from app settings.';
      });
      return;
    }

    setState(() {
      _locationPermissionGranted = true;
      _permissionDenied = false;
      _permissionMessage = null;
    });

    await _updateCurrentLocation();
  }

  Future<void> _updateCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    } catch (_) {
      setState(() {
        _permissionDenied = true;
        _permissionMessage =
            'Unable to get current location. Please try again or allow location permission.';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _handleMapTap(LatLng position) {
    _showMessage(
      context,
      'Tapped map at ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
    );
  }

  Future<void> _centerOnUserLocation() async {
    if (!_locationPermissionGranted) {
      if (_permissionDenied) {
        _showMessage(
          context,
          _permissionMessage ?? 'Location permission denied.',
        );
      } else {
        _showMessage(context, 'Requesting location permission...');
        await _initLocation();
      }
      return;
    }

    if (_currentPosition != null && _mapController != null) {
      final target = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      _mapController!.animateCamera(CameraUpdate.newLatLng(target));
      return;
    }

    await _updateCurrentLocation();

    if (_currentPosition != null && _mapController != null) {
      final target = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      _mapController!.animateCamera(CameraUpdate.newLatLng(target));
    }
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              Expanded(child: _buildMapPanel(context)),
              const SizedBox(height: 20),
              _buildLegendCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final provider = context.read<BusDataProvider>();
                        showSearchSheet(
                          context: context,
                          provider: provider,
                          onResultSelected: (result) {
                            Navigator.pop(context);
                            if (result.type == SearchResultType.bus) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.busDetails,
                                arguments: result.item,
                              );
                            } else if (result.type == SearchResultType.route) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.routeDetails,
                                arguments: {
                                  'name': (result.item as BusRoute).title,
                                  'details': (result.item as BusRoute).description,
                                  'stops': '${(result.item as BusRoute).totalStops} stops',
                                  'distance': (result.item as BusRoute).distance,
                                  'duration': (result.item as BusRoute).duration,
                                  'routeNumber': (result.item as BusRoute).routeNumber,
                                  'startingPoint': (result.item as BusRoute).startingPoint,
                                  'destination': (result.item as BusRoute).destination,
                                  'firstBus': (result.item as BusRoute).firstBus,
                                  'lastBus': (result.item as BusRoute).lastBus,
                                  'frequency': (result.item as BusRoute).frequency,
                                  'stopNames': (result.item as BusRoute).stops,
                                },
                              );
                            }
                          },
                        );
                      },
                      child: Text(
                        'Search map or route',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: _centerOnUserLocation,
            icon: const Icon(Icons.my_location_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPanel(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(child: _buildGoogleMap()),
              ..._buildBusMarkers(constraints, context.watch<BusDataProvider>()),
              Positioned(
                left: 20,
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withAlpha(220),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF8FD3F4),
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You are near MVP Colony. Tap refresh to update local buses.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 20,
                top: 120,
                child: Column(
                  children: [
                    _buildFloatingMapButton(
                      context,
                      Icons.add,
                      'Zoom in',
                      _zoomIn,
                    ),
                    const SizedBox(height: 12),
                    _buildFloatingMapButton(
                      context,
                      Icons.remove,
                      'Zoom out',
                      _zoomOut,
                    ),
                  ],
                ),
              ),
              if (_permissionDenied || !_locationPermissionGranted)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 170,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      _permissionMessage ??
                          'Location permission is required to show your current location.',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              Positioned(
                left: 20,
                bottom: 120,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withAlpha(220),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Bus markers are live demo positions. Good for planning your walk to the stop.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 20,
                right: 20,
                child: _buildFilterBar(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showRouteFilterDialog(BuildContext context) async {
    final provider = context.read<BusDataProvider>();
    final routes = provider.popularRoutes;
    final currentSelection = ValueNotifier(<String>{});
    if (_selectedRouteNumbers.isNotEmpty) {
      currentSelection.value = Set<String>.from(_selectedRouteNumbers);
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: currentSelection,
          builder: (context, selection, child) {
            return AlertDialog(
              title: const Text('Filter routes'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    CheckboxListTile(
                      value: selection.isEmpty,
                      title: const Text('All Routes'),
                      onChanged: (value) {
                        if (value == true) {
                          currentSelection.value = <String>{};
                        }
                      },
                    ),
                    ...routes.map((route) {
                      return CheckboxListTile(
                        value: selection.contains(route.routeNumber),
                        title: Text(route.title),
                        subtitle: Text(route.routeNumber),
                        onChanged: (value) {
                          final newSelection = Set<String>.from(selection);
                          if (value == true) {
                            newSelection.add(route.routeNumber);
                          } else {
                            newSelection.remove(route.routeNumber);
                          }
                          currentSelection.value = newSelection;
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedRouteNumbers.clear();
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedRouteNumbers
                        ..clear()
                        ..addAll(currentSelection.value);
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showBusFilterDialog(BuildContext context) async {
    final provider = context.read<BusDataProvider>();
    final buses = provider.nearbyBuses;
    final currentSelection = ValueNotifier(<String>{});
    if (_selectedBusNumbers.isNotEmpty) {
      currentSelection.value = Set<String>.from(_selectedBusNumbers);
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: currentSelection,
          builder: (context, selection, child) {
            return AlertDialog(
              title: const Text('Filter buses'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    CheckboxListTile(
                      value: selection.isEmpty,
                      title: const Text('All Buses'),
                      onChanged: (value) {
                        if (value == true) {
                          currentSelection.value = <String>{};
                        }
                      },
                    ),
                    ...buses.map((bus) {
                      return CheckboxListTile(
                        value: selection.contains(bus.busNumber),
                        title: Text(bus.busNumber),
                        subtitle: Text(bus.routeName),
                        onChanged: (value) {
                          final newSelection = Set<String>.from(selection);
                          if (value == true) {
                            newSelection.add(bus.busNumber);
                          } else {
                            newSelection.remove(bus.busNumber);
                          }
                          currentSelection.value = newSelection;
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedBusNumbers.clear();
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedBusNumbers
                        ..clear()
                        ..addAll(currentSelection.value);
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFloatingMapButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(235),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildFilterChip(context, 'Route filter', Icons.tune)),
        const SizedBox(width: 14),
        Expanded(
          child: _buildFilterChip(context, 'Bus filter', Icons.directions_bus),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (label == 'Route filter') {
          _showRouteFilterDialog(context);
        } else if (label == 'Bus filter') {
          _showBusFilterDialog(context);
        } else {
          _showMessage(context, '$label opened');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      myLocationEnabled: _locationPermissionGranted,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: _onMapCreated,
      onTap: _handleMapTap,
      mapType: MapType.normal,
      compassEnabled: true,
      trafficEnabled: false,
    );
  }

  Widget _buildLegendCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem('Live bus', AppColors.primary),
              _buildLegendItem('User location', Colors.green),
              _buildLegendItem('Stop alert', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          height: 14,
          width: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  List<Widget> _buildBusMarkers(BoxConstraints constraints, BusDataProvider provider) {
    final buses = provider.nearbyBuses;
    final filteredBuses = _selectedRouteNumbers.isEmpty && _selectedBusNumbers.isEmpty
        ? buses
        : buses.where((bus) {
            final routeMatch = _selectedRouteNumbers.isEmpty ||
                _selectedRouteNumbers.contains(bus.routeNumber);
            final busMatch = _selectedBusNumbers.isEmpty ||
                _selectedBusNumbers.contains(bus.busNumber);
            return routeMatch && busMatch;
          }).toList();

    final markerPositions = const [
      Offset(0.3, 0.35),
      Offset(0.63, 0.22),
      Offset(0.77, 0.62),
      Offset(0.18, 0.72),
    ];

    final markers = <Widget>[];

    for (var i = 0; i < markerPositions.length && i < filteredBuses.length; i++) {
      final bus = filteredBuses[i];
      final position = markerPositions[i];
      markers.add(
        Positioned(
          left: position.dx * constraints.maxWidth,
          top: position.dy * constraints.maxHeight,
          child: _MapMarker(label: bus.busNumber),
        ),
      );
    }

    markers.add(
      Positioned(
        left: constraints.maxWidth * 0.6,
        top: constraints.maxHeight * 0.46,
        child: const _UserLocationMarker(),
      ),
    );

    return markers;
  }
}

class _MapMarker extends StatelessWidget {
  final String label;

  const _MapMarker({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(46),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_bus, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.greenAccent.shade400,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withAlpha(115),
            blurRadius: 22,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: const Icon(Icons.my_location, color: Colors.white, size: 22),
    );
  }
}
