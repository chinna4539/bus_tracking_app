import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  String _language = 'English';
  String _locationStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    setState(() {
      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          _locationStatus = 'Allowed';
        case LocationPermission.denied:
          _locationStatus = 'Denied';
        case LocationPermission.deniedForever:
          _locationStatus = 'Permanently denied';
        default:
          _locationStatus = 'Unknown';
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    await _checkLocationPermission();
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showMessage('Permission permanently denied. Please enable in app settings.');
      }
    } else if (permission == LocationPermission.denied) {
      if (mounted) {
        _showMessage('Location permission denied.');
      }
    }
  }

  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
    await _checkLocationPermission();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final darkMode = appState.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildToggleTile(
            title: 'Dark Mode',
            subtitle: 'Use a comfortable night-friendly theme',
            value: darkMode,
            onChanged: (value) => appState.updateThemeMode(value ? ThemeMode.dark : ThemeMode.light),
          ),
          const SizedBox(height: 12),
          _buildToggleTile(
            title: 'Notifications',
            subtitle: 'Receive route alerts and service updates',
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
          const SizedBox(height: 12),
          _buildLocationTile(),
          const SizedBox(height: 12),
          _buildOptionTile(
            title: 'Language',
            subtitle: _language,
            icon: Icons.language,
            onTap: () => _showLanguageDialog(context),
          ),
          const SizedBox(height: 12),
          _buildOptionTile(
            title: 'Privacy',
            subtitle: 'Manage your data preferences',
            icon: Icons.lock_outline,
            onTap: () => _showPrivacyDialog(context),
          ),
          const SizedBox(height: 12),
          _buildOptionTile(
            title: 'About app',
            subtitle: 'Version 1.0.0 • Premium demo',
            icon: Icons.info_outline,
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(31),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location Access',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _locationStatus,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Location is needed to show your current position and nearby buses on the map.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _requestLocationPermission,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: Theme.of(context).colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Request permission'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _locationStatus == 'Permanently denied' ? _openAppSettings : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Open app settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        activeThumbColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(31),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['English', 'Telugu', 'Hindi', 'Tamil'].map((language) {
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() => _language = language);
                  Navigator.pop(context);
                  _showMessage('Language switched to $language');
                },
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _language == language
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(language),
                  onTap: () {
                    setState(() => _language = language);
                    Navigator.pop(context);
                    _showMessage('Language switched to $language');
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Privacy'),
        content: const Text(
          'Your data is stored locally and securely. We do not share your personal information with third parties.',
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
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version 1.0.0'),
              SizedBox(height: 8),
              Text(
                'A premium app for live city buses, routes, and arrival insights in Visakhapatnam.',
              ),
              SizedBox(height: 16),
              Text(
                'Splash screen imagery courtesy of Wikimedia Commons contributors:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '• Visakhapatnam city from Kailasagiri by Pinakpani — CC BY-SA 4.0',
              ),
              Text(
                '• GVMC Bus Stop, Yendada, Beach Road by A.Murali — CC BY-SA 4.0',
              ),
              Text(
                '• Maddilapalem Bus Station by Imahesh3847 — CC BY-SA 4.0',
              ),
            ],
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
}
