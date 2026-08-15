import 'package:flutter/material.dart';

import '../core/constants.dart';

class PageIndicator extends StatelessWidget {
  final bool isActive;

  const PageIndicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      width: isActive ? 24 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : colorScheme.onSurfaceVariant.withAlpha(61),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
