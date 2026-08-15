import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../models/bus_route.dart';
import '../../models/search_result.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/bus_data_provider.dart';
import '../../widgets/search_results_sheet.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusDataProvider>();
    final routes = _selectedFilter == 'All'
        ? provider.popularRoutes
        : provider.popularRoutes.where((route) {
            if (_selectedFilter == 'City Express') {
              return route.stops.length <= 10;
            }
            if (_selectedFilter == 'Coastal') {
              return route.distance.contains('km');
            }
            if (_selectedFilter == 'Night') {
              return route.firstBus.contains('PM') || route.lastBus.contains('PM');
            }
            return true;
          }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildSearchField(context),
              const SizedBox(height: 18),
              _buildFilterChips(context),
              const SizedBox(height: 24),
              const Text(
                'Available routes',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildRouteList(context, routes)),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Routes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Find best commute paths with live route options.',
                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<AppStateProvider>().updateSelectedTab(1);
          },
          icon: const Icon(Icons.map_outlined, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return GestureDetector(
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search route name or stop',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = ['All', 'City Express', 'Coastal', 'Night'];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return ChoiceChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedFilter = filter);
          },
          selectedColor: AppColors.primary.withAlpha(51),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        );
      }).toList(),
    );
  }

  Widget _buildRouteList(BuildContext context, List<BusRoute> routes) {
    return ListView.separated(
      itemCount: routes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final route = routes[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.routeDetails,
              arguments: {
                'name': route.title,
                'details': route.description,
                'stops': '${route.totalStops} stops',
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
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 20,
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(36),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        route.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${route.startingPoint} → ${route.destination}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildBadge(
                        '${route.totalStops} stops',
                        Icons.stop_circle_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildBadge(route.distance, Icons.map_outlined),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildBadge(route.duration, Icons.access_time_outlined),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
