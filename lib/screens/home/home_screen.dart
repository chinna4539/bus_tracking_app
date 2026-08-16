import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../models/bus_info.dart';
import '../../models/bus_route.dart';
import '../../models/search_result.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/bus_data_provider.dart';
import '../../screens/alerts/alerts_screen.dart';
import '../../screens/map/map_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/routes/routes_screen.dart';
import '../../utils/responsive.dart';
import '../../widgets/search_results_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _currentAddress;
  bool _isLoadingLocation = false;
  String? _locationError;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled. Please enable them in settings.';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError = 'Location permission needed';
          _isLoadingLocation = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permission permanently denied. Please enable from app settings.';
          _isLoadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      setState(() {
        _currentAddress = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _isLoadingLocation = false;
      });
    } on Exception catch (_) {
      setState(() {
        _locationError = 'Unable to get current location.';
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.watch<AppStateProvider>().selectedTab;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: _buildTabView(context, selectedTab)),
      bottomNavigationBar: _buildBottomNavigation(context, selectedTab),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSearchWithQuery(context, ''),
        label: const Text('Search buses'),
        icon: const Icon(Icons.search_rounded),
        backgroundColor: AppColors.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTabView(BuildContext context, int selectedTab) {
    switch (selectedTab) {
      case 1:
        return const MapScreen();
      case 2:
        return const RoutesScreen();
      case 3:
        return const AlertsScreen();
      case 4:
        return const ProfileScreen();
      case 0:
      default:
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingCard(context),
              const SizedBox(height: 20),
              _buildSearchField(context),
              const SizedBox(height: 22),
              _buildQuickSummary(context),
              const SizedBox(height: 22),
              _buildSectionHeader(context, 'Bus categories', 'See all', () => _openSearchWithQuery(context, 'bus')),
              const SizedBox(height: 16),
              _buildBusCategories(context),
              const SizedBox(height: 22),
              _buildSectionHeader(context, 'Live buses', 'View all', () => _openSearchWithQuery(context, 'bus')),
              const SizedBox(height: 16),
              _buildLiveBuses(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Popular routes', 'Explore', () => context.read<AppStateProvider>().updateSelectedTab(2)),
              const SizedBox(height: 16),
              _buildRouteCards(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Bus stop shortcuts', 'Edit', () => _showShortcutsDialog(context)),
              const SizedBox(height: 16),
              _buildShortcuts(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Recent searches', 'Clear', () {
                context.read<BusDataProvider>().clearRecentSearches();
              }),
              const SizedBox(height: 16),
              _buildRecentSearches(context),
              const SizedBox(height: 26),
              _buildFooterNote(context),
            ],
          ),
        );
    }
  }

  Widget _buildGreetingCard(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final rawName = appState.profileName.trim();
    final displayName = rawName.isEmpty || rawName == 'chinna' ? 'there' : rawName;

    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    String locationText;
    if (_locationError != null) {
      locationText = _locationError!;
    } else if (_currentAddress != null) {
      locationText = _currentAddress!;
    } else if (_isLoadingLocation) {
      locationText = 'Updating location...';
    } else {
      locationText = 'Location permission needed';
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(56),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current location',
                      style: TextStyle(color: Colors.white.withAlpha(179)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      locationText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final provider = context.read<BusDataProvider>();
    return GestureDetector(
      onTap: () => showSearchSheet(
        context: context,
        provider: provider,
        onResultSelected: (result) => _handleSearchSelection(context, result),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                provider.searchQuery.isEmpty
                    ? 'Search buses, stops, or routes'
                    : provider.searchQuery,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSummary(BuildContext context) {
    final provider = context.watch<BusDataProvider>();
    final isWide = context.isLargeScreen;
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Nearby buses',
            '${provider.nearbyBuses.length} active',
            Icons.bus_alert_rounded,
            () {
              _openSearchWithQuery(context, 'bus');
            },
            context,
          ),
        ),
        if (!isWide) const SizedBox(width: 16),
        if (isWide)
          Expanded(
            child: _buildSummaryCard(
              'Popular routes',
              '${provider.popularRoutes.length} routes',
              Icons.route_rounded,
              () {
                context.read<AppStateProvider>().updateSelectedTab(2);
              },
              context,
            ),
          )
        else
          Expanded(
            child: _buildSummaryCard(
              'Routes',
              '${provider.popularRoutes.length} popular',
              Icons.route_rounded,
              () {
                context.read<AppStateProvider>().updateSelectedTab(2);
              },
              context,
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(56),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String action, VoidCallback? onAction) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(action, style: const TextStyle(color: AppColors.primary)),
          )
        else
          Text(action, style: const TextStyle(color: AppColors.primary)),
      ],
    );
  }

  Widget _buildLiveBuses(BuildContext context) {
    final provider = context.watch<BusDataProvider>();

    if (provider.isFirestoreLoading) {
      return const SizedBox(
        height: 170,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (provider.firestoreErrorMessage != null && provider.hasLoadedFirestore) {
      return Container(
        height: 170,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.redAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                provider.firestoreErrorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    final buses = provider.nearbyBuses;
    if (buses.isEmpty) {
      return Container(
        height: 170,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.directions_bus_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No buses available right now.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final bus in buses)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _liveBusCard(
                context,
                bus.busNumber,
                '${bus.startingPoint} → ${bus.destination}',
                bus.eta,
                provider.hasLiveLocation(bus.busNumber),
                bus,
              ),
            ),
        ],
      ),
    );
  }

  Widget _liveBusCard(
    BuildContext context,
    String title,
    String route,
    String eta,
    bool isLive,
    BusInfo bus,
  ) {
    return GestureDetector(
      onTap: () => _openBusDetails(context, bus),
      child: SizedBox(
        width: 260,
        height: 170,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isLive
                          ? AppColors.accent.withAlpha(41)
                          : AppColors.secondary.withAlpha(61),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.directions_bus_rounded,
                      size: 20,
                      color: isLive ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          route,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ETA',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          eta,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isLive ? AppColors.accent : AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isLive ? 'Live' : 'Scheduled',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCards(BuildContext context) {
    final routes = context.watch<BusDataProvider>().popularRoutes;
    return Column(
      children: [
        for (final route in routes)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _routeTile(
              context,
              route.title,
              '${route.startingPoint} → ${route.destination}',
              Icons.route_rounded,
              route,
            ),
          ),
      ],
    );
  }

  Widget _buildBusCategories(BuildContext context) {
    final categories = [
      {
        'label': 'Express',
        'icon': Icons.flash_on_rounded,
        'color': AppColors.primary,
      },
      {
        'label': 'City',
        'icon': Icons.location_city_rounded,
        'color': AppColors.secondary,
      },
      {
        'label': 'Night',
        'icon': Icons.nightlight_round,
        'color': AppColors.accent,
      },
    ];

    return Row(
      children: categories.map((category) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _openSearchWithQuery(
                context,
                category['label'] as String,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (category['color'] as Color).withAlpha(41),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: category['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      category['label'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShortcuts(BuildContext context) {
    final shortcuts = [
      'Central Stop',
      'Airport Gate',
      'MVP Junction',
      'Beach Road',
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: shortcuts.map((shortcut) {
        return ActionChip(
          label: Text(shortcut),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          onPressed: () => _openSearchWithQuery(context, shortcut),
        );
      }).toList(),
    );
  }

  Widget _routeTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    BusRoute route,
  ) {
    return GestureDetector(
      onTap: () => _openRouteDetails(context, route),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(31),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final provider = context.watch<BusDataProvider>();
    final searches = provider.recentSearches;
    return Wrap(
      runSpacing: 12,
      spacing: 12,
      children: [
        if (searches.isEmpty)
          Text(
            'Search for buses, routes, or stops to build a recent list.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          )
        else
          ...searches.map(
            (text) => _chipLabel(context, text, () {
              provider.updateSearchQuery(text);
              showSearchSheet(
                context: context,
                provider: provider,
                onResultSelected: (result) =>
                    _handleSearchSelection(context, result),
              );
            }),
          ),
      ],
    );
  }

  Widget _chipLabel(BuildContext context, String text, VoidCallback onTap) {
    return ActionChip(
      label: Text(text),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      onPressed: onTap,
    );
  }

  Widget _buildFooterNote(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather update',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bright and breezy in Vizag, 29°C',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.wb_sunny_rounded,
            color: AppColors.primary,
            size: 34,
          ),
        ],
      ),
    );
  }

  void _handleSearchSelection(BuildContext context, SearchResult result) {
    switch (result.type) {
      case SearchResultType.bus:
        _openBusDetails(context, result.item as BusInfo);
        break;
      case SearchResultType.route:
        _openRouteDetails(context, result.item as BusRoute);
        break;
      case SearchResultType.stop:
        _openSearchWithQuery(context, result.title);
        break;
    }
  }

  void _openBusDetails(BuildContext context, BusInfo bus) {
    Navigator.pushNamed(context, AppRoutes.busDetails, arguments: bus);
  }

  void _openRouteDetails(BuildContext context, BusRoute route) {
    Navigator.pushNamed(
      context,
      AppRoutes.routeDetails,
      arguments: {
        'name': route.title,
        'details': route.description,
        'stops': route.totalStops.toString(),
        'distance': route.distance,
        'duration': route.duration,
        'routeNumber': route.routeNumber,
        'startingPoint': route.startingPoint,
        'destination': route.destination,
        'firstBus': route.firstBus,
        'lastBus': route.lastBus,
        'frequency': route.frequency,
        'stopNames': route.stops,
      },
    );
  }

  void _openSearchWithQuery(BuildContext context, String query) {
    final provider = context.read<BusDataProvider>();
    provider.updateSearchQuery(query);
    showSearchSheet(
      context: context,
      provider: provider,
      onResultSelected: (result) => _handleSearchSelection(context, result),
    );
  }

  void _showShortcutsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bus stop shortcuts'),
        content: const Text(
          'Shortcut management will be available in a future update. For now, you can tap any shortcut chip to search for that stop.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, int selectedTab) {
    return BottomNavigationBar(
      currentIndex: selectedTab,
      onTap: context.read<AppStateProvider>().updateSelectedTab,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 18,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Map'),
        BottomNavigationBarItem(
          icon: Icon(Icons.commute_rounded),
          label: 'Routes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_rounded),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
