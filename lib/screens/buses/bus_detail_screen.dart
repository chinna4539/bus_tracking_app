import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/bus_info.dart';
import '../../providers/bus_data_provider.dart';

class BusDetailScreen extends StatelessWidget {
  final BusInfo bus;

  const BusDetailScreen({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusDataProvider>();
    final isFavourite = provider.isFavouriteBus(bus);

    return Scaffold(
      appBar: AppBar(
        title: Text(bus.busNumber),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              provider.toggleFavouriteBus(bus);
            },
            icon: Icon(
              isFavourite ? Icons.favorite : Icons.favorite_border,
              color: isFavourite ? Colors.redAccent : AppColors.primary,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, provider),
            const SizedBox(height: 20),
            _buildInfoGrid(context, provider),
            const SizedBox(height: 20),
            _buildStopsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BusDataProvider provider) {
    final isFavourite = provider.isFavouriteBus(bus);

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
          Row(
            children: [
              Expanded(
                child: Text(
                  '${bus.busNumber} • ${bus.routeNumber}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bus.status == BusStatus.cancelled
                      ? Colors.redAccent.withAlpha(31)
                      : AppColors.primary.withAlpha(31),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  bus.statusLabel,
                  style: TextStyle(
                    color: bus.status == BusStatus.cancelled
                        ? Colors.redAccent
                        : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bus.routeName,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildBadge(
                context,
                bus.isActive
                    ? Icons.wifi_rounded
                    : Icons.wifi_off_rounded,
                bus.isActive ? 'Active' : 'Inactive',
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildBadge(
                context,
                Icons.route_rounded,
                '${bus.startingPoint} → ${bus.destination}',
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildBadge(
                context,
                Icons.star_rounded,
                isFavourite ? 'Favourite' : 'Not saved',
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, BusDataProvider provider) {
    final liveLocation = provider.getLiveLocation(bus.busNumber);
    final hasLiveLocation = liveLocation != null;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildInfoTile(
          context,
          'Current stop',
          bus.currentStop,
          Icons.location_on_outlined,
        ),
        _buildInfoTile(context, 'Next stop', bus.nextStop, Icons.alt_route_rounded),
        _buildInfoTile(context, 'ETA', bus.eta, Icons.access_time_outlined),
        _buildInfoTile(context, 'Type', bus.typeLabel, Icons.directions_bus_rounded),
        _buildInfoTile(context, 'Driver', bus.driverName, Icons.person_outline),
        _buildInfoTile(context, 'Seats', bus.occupancyLabel, Icons.event_seat_outlined),
        _buildInfoTile(
          context,
          'Speed',
          '${bus.speed.toStringAsFixed(1)} km/h',
          Icons.speed_rounded,
        ),
        _buildInfoTile(
          context,
          hasLiveLocation
              ? '${liveLocation.latitude.toStringAsFixed(5)}, ${liveLocation.longitude.toStringAsFixed(5)}'
              : 'Live location unavailable',
          'Live location',
          hasLiveLocation
              ? Icons.gps_fixed_rounded
              : Icons.gps_off_rounded,
        ),
        _buildInfoTile(
          context,
          'Last update',
          bus.lastUpdated,
          Icons.update_rounded,
        ),
      ],
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Route stops',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...bus.stops.map(
            (stop) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(stop)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Distance remaining: ${bus.distanceRemaining} • Est. ${bus.estimatedJourneyTime}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
