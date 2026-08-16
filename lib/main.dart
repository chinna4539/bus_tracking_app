import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'firebase_options.dart';
import 'providers/app_state_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/bus_data_provider.dart';
import 'providers/firestore_provider.dart';
import 'providers/onboarding_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ensure there is always an authenticated user for Firestore reads.
  // Guests will use anonymous auth; real users will sign in later.
  final auth = firebase_auth.FirebaseAuth.instance;
  if (auth.currentUser == null) {
    try {
      await auth.signInAnonymously();
    } on firebase_auth.FirebaseAuthException catch (_) {
      // If anonymous sign-in fails, the app still starts;
      // Firestore reads will show an auth-required state.
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => FirestoreProvider()),
        ChangeNotifierProxyProvider<FirestoreProvider, BusDataProvider>(
          create: (_) => BusDataProvider(),
          update: (_, firestore, busData) {
            final busDataNotifier = busData!;
            busDataNotifier.setFirestoreProvider(firestore);
            return busDataNotifier;
          },
        ),
      ],
      child: const BusTrackingApp(),
    ),
  );
}

class BusTrackingApp extends StatelessWidget {
  const BusTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<AppStateProvider>().loadPersistedState(),
      builder: (context, snapshot) {
        final themeMode = context.watch<AppStateProvider>().themeMode;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bus Tracking',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
