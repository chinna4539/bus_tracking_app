import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/alert_info.dart';
import '../../providers/bus_data_provider.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<BusDataProvider>().alerts;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stay informed with alerts for delays, changes, and service updates.',
                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: ListView.separated(
                  itemCount: alerts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: Row(
                              children: [
                                Icon(
                                  _iconFor(alert.type),
                                  color: _colorFor(alert.type),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(alert.title)),
                              ],
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(alert.message),
                                  const SizedBox(height: 12),
                                  Text(
                                    alert.timestamp,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 18,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _colorFor(alert.type).withAlpha(31),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _iconFor(alert.type),
                                color: _colorFor(alert.type),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alert.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                   Text(
                                     alert.message,
                                     style: TextStyle(
                                       color: Theme.of(context).colorScheme.onSurfaceVariant,
                                       height: 1.5,
                                     ),
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFor(AlertType type) {
    switch (type) {
      case AlertType.delay:
        return AppColors.primary;
      case AlertType.diverted:
        return Colors.deepPurple;
      case AlertType.arrivingSoon:
        return Colors.teal;
      case AlertType.cancelled:
        return Colors.redAccent;
      case AlertType.traffic:
        return Colors.orange;
    }
  }

  IconData _iconFor(AlertType type) {
    switch (type) {
      case AlertType.delay:
        return Icons.schedule;
      case AlertType.diverted:
        return Icons.autorenew;
      case AlertType.arrivingSoon:
        return Icons.notifications_active_outlined;
      case AlertType.cancelled:
        return Icons.cancel_outlined;
      case AlertType.traffic:
        return Icons.traffic;
    }
  }
}
