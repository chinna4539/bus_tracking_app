import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../models/bus_info.dart';
import '../../models/bus_route.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/bus_data_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              _buildProfileHeader(context),
              const SizedBox(height: 20),
              Expanded(child: _buildProfileOptions(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const Hero(
            tag: 'profileAvatar',
            child: CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 34, color: Colors.white),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.profileName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  appState.profileEmail,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  appState.profilePhone,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    final provider = context.watch<BusDataProvider>();
    final favouriteBuses = provider.favouriteBuses;
    final favouriteRoutes = provider.favouriteRoutes;

    return ListView.separated(
      itemCount: 8,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return _ProfileOption(
              icon: Icons.edit_outlined,
              label: 'Edit profile',
              subtitle: 'Update your name and contact details',
              onTap: () => _showEditProfileDialog(context),
            );
          case 1:
            return _ProfileOption(
              icon: Icons.star_border,
              label: 'Saved routes',
              subtitle: '${favouriteRoutes.length} saved routes',
              onTap: () => _showSavedRoutesDialog(context, favouriteRoutes),
            );
          case 2:
            return _ProfileOption(
              icon: Icons.favorite_border,
              label: 'Favourite buses',
              subtitle: '$favouriteBuses favourite buses',
              onTap: () => _showFavouriteBusesDialog(context, favouriteBuses),
            );
          case 3:
            return _ProfileOption(
              icon: Icons.settings_outlined,
              label: 'Settings',
              subtitle: 'Manage app preferences',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            );
          case 4:
            return _ProfileOption(
              icon: Icons.info_outline,
              label: 'About',
              subtitle: 'App version, privacy, and terms',
              onTap: () => _showAboutDialog(context),
            );
          case 5:
            return _ProfileOption(
              icon: Icons.help_outline,
              label: 'Help & support',
              subtitle: 'Guides and customer support',
              onTap: () => _showHelpDialog(context),
            );
          case 6:
            return _ProfileOption(
              icon: Icons.logout,
              label: 'Logout',
              subtitle: 'Sign out from this device',
              onTap: () => _handleLogout(context),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                     Text(
                       subtitle,
                       style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                     ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showEditProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Edit profile'),
      content: const Text(
        'Profile editing will be available once Firebase Auth is fully configured.',
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

void _showSavedRoutesDialog(BuildContext context, List<BusRoute> routes) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Saved routes'),
      content: SizedBox(
        width: double.maxFinite,
        child: routes.isEmpty
            ? const Text('No saved routes yet.')
            : SizedBox(
                height: 300,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: routes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    return ListTile(
                      title: Text(route.title),
                      subtitle: Text(
                        '${route.startingPoint} → ${route.destination}',
                      ),
                      onTap: () {
                        Navigator.pop(dialogContext);
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
                    );
                  },
                ),
              ),
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

void _showFavouriteBusesDialog(BuildContext context, List<BusInfo> buses) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Favourite buses'),
      content: SizedBox(
        width: double.maxFinite,
        child: buses.isEmpty
            ? const Text('No favourite buses yet.')
            : SizedBox(
                height: 300,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: buses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final bus = buses[index];
                    return ListTile(
                      title: Text(bus.busNumber),
                      subtitle: Text(bus.routeName),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.busDetails,
                          arguments: bus,
                        );
                      },
                    );
                  },
                ),
              ),
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

void _showAboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('About Vizag Bus Tracker'),
      content: const Text(
        'Version 1.0.0\nA premium app for live city buses, routes, and arrival insights in Visakhapatnam.',
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

void _showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Help & support'),
      content: const Text(
        'For support, contact us at support@vizagbustracker.com\n\nFeatures:\n• Search buses, routes, and stops\n• View live bus locations\n• Get arrival alerts\n• Save favourite routes and buses',
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

void _handleLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          },
          child: const Text('Logout'),
        ),
      ],
    ),
  );
}
