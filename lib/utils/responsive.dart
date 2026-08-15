import 'package:flutter/material.dart';

extension ResponsiveExtensions on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  bool get isSmallScreen => screenSize.width < 600;
  bool get isMediumScreen => screenSize.width >= 600 && screenSize.width < 1024;
  bool get isLargeScreen => screenSize.width >= 1024;
}
