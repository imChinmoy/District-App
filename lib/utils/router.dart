import 'package:district/features/home/dining/rest.dart';
import 'package:district/models/dining/dining_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/splashscreen.dart';
import '../features/home/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/profile.dart';
import '../features/home/dining/dining.dart';
// import '../providers/auth_provider.dart';
import '../features//home/dining/tablebooking.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  // final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Splashscreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const Profile(),
            routes: [
              GoRoute(
                path: 'tableBookings',
                builder: (context, state) => const TableBookings(),
              ),
            ],
          ),

          GoRoute(
            path: 'dining',
            builder: (context, state) => const DiningScreen(),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final restaurant = state.extra as DiningModel?;
                  if (restaurant == null) {
                    return const Scaffold(
                      body: Center(
                        child: Text(
                          'No restaurant data provided.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                  return RestaurantDetailPage(restaurant: restaurant);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggingIn = state.matchedLocation == '/login';
      final splash = state.matchedLocation == '/splash';

      if (splash) return null;
      if (user == null && !loggingIn) return '/login';
      if (user != null && loggingIn) return '/home';
      return null;
    },
  );
});
