import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/bus_route.dart';
import '../../providers/bus_data_provider.dart';

class RouteDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final int stops;
  final String distance;
  final String duration;
  final String routeNumber;
  final String startingPoint;
  final String destination;
  final String firstBus;
  final String lastBus;
  final String frequency;
  final List<String> stopNames;

  const RouteDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.stops,
    required this.distance,
    required this.duration,
    required this.routeNumber,
    required this.startingPoint,
    required this.destination,
    required this.firstBus,
    required this.lastBus,
    required this.frequency,
    required this.stopNames,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusDataProvider>();
    final route = BusRoute(
      routeNumber: routeNumber,
      title: title,
      startingPoint: startingPoint,
      destination: destination,
      stops: stopNames,
      distance: distance,
      duration: duration,
      totalStops: stops,
      firstBus: firstBus,
      lastBus: lastBus,
      frequency: frequency,
      description: description,
    );
    final isFavourite = provider.isFavouriteRoute(route);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route details'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => provider.toggleFavouriteRoute(route),
            icon: Icon(
              isFavourite ? Icons.favorite : Icons.favorite_border,
              color: isFavourite ? Colors.redAccent : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${routeNumber.isEmpty ? 'Route' : 'Route $routeNumber'} • $title',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildInfoChip(
                        context,
                        'Stops',
                        stops.toString(),
                        Icons.stop_circle_outlined,
                      ),
                      _buildInfoChip(context, 'Distance', distance, Icons.map_outlined),
                      _buildInfoChip(
                        context,
                        'Duration',
                        duration,
                        Icons.access_time_outlined,
                      ),
                      _buildInfoChip(
                        context,
                        'First bus',
                        firstBus,
                        Icons.schedule_outlined,
                      ),
                      _buildInfoChip(
                        context,
                        'Last bus',
                        lastBus,
                        Icons.schedule_outlined,
                      ),
                      _buildInfoChip(
                        context,
                        'Frequency',
                        frequency,
                        Icons.repeat_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$startingPoint → $destination',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Route overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 14),
            ...stopNames
                .asMap()
                .entries
            .map(
              (entry) => _buildStopTile(
                context,
                entry.value,
                '${entry.key + 1}${entry.key == 0 ? ' • Boarding point' : ''}',
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value, IconData icon) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
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

  Widget _buildStopTile(BuildContext context, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(36),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
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
    );
  }
}
