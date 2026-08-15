import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/buses/bus_detail_screen.dart';
import '../screens/routes/route_detail_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/edit_profile_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const settings = '/settings';
  static const routeDetails = '/route-details';
  static const busDetails = '/bus-details';
  static const editProfile = '/edit-profile';

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    settings: (_) => const SettingsScreen(),
    editProfile: (_) => const EditProfileScreen(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == busDetails) {
      final bus = settings.arguments as dynamic;
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            BusDetailScreen(bus: bus),
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
      );
    }

    if (settings.name == routeDetails) {
      final args = settings.arguments as Map<String, dynamic>?;
      final title = args?['name'] as String? ?? 'Route details';
      final details = args?['details'] as String? ?? '';
      final stops =
          int.tryParse((args?['stops'] as String?)?.split(' ').first ?? '0') ??
          0;
      final distance = args?['distance'] as String? ?? '';
      final duration = args?['duration'] as String? ?? '';
      final routeNumber = args?['routeNumber'] as String? ?? '';
      final startingPoint = args?['startingPoint'] as String? ?? '';
      final destination = args?['destination'] as String? ?? '';
      final firstBus = args?['firstBus'] as String? ?? '';
      final lastBus = args?['lastBus'] as String? ?? '';
      final frequency = args?['frequency'] as String? ?? '';
      final stopNames =
          (args?['stopNames'] as List<dynamic>?)?.cast<String>() ?? <String>[];
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            RouteDetailScreen(
              title: title,
              description: details,
              stops: stops,
              distance: distance,
              duration: duration,
              routeNumber: routeNumber,
              startingPoint: startingPoint,
              destination: destination,
              firstBus: firstBus,
              lastBus: lastBus,
              frequency: frequency,
              stopNames: stopNames,
            ),
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
      );
    }

    final WidgetBuilder pageBuilder =
        routes[settings.name] ?? (_) => const SplashScreen();

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) =>
          pageBuilder(context),
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }
}
