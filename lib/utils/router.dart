import 'package:district/features/home/dining/rest.dart';
import 'package:district/features/home/event/event.dart';
import 'package:district/features/home/event/eventdetail.dart';
import 'package:district/features/home/movies/movie.dart';
import 'package:district/features/home/movies/moviedetail.dart';
import 'package:district/models/dining/dining_model.dart';
import 'package:district/models/event/event_model.dart';
import 'package:district/models/movie/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/splashscreen.dart';
import '../features/home/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/profile.dart';
import '../features/home/dining/dining.dart';
import '../features/home/dining/tablebooking.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Splashscreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
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
                      backgroundColor: Colors.black,
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
      GoRoute(
        path: '/guest',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
      path: 'events',
      builder: (context, state) => const EventsScreen(),
      routes: [
        GoRoute(
          path: 'detail',
          builder: (context, state) {
            final event = state.extra as EventModel?;
            if (event == null) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Text(
                    'No event data provided.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            return EventDetailPage(event: event);
          },
        ),
      ],
    ),
    GoRoute(
      path: 'movies',
      builder: (context, state) => const MoviesScreen(),
      routes: [
        GoRoute(
          path: 'detail',
          builder: (context, state) {
            final movie = state.extra as MovieModel?;
            if (movie == null) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Text(
                    'No movie data provided.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            return MovieDetailPage(movie: movie);
          },
        ),
      ],
    ),
    ],
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final location = state.matchedLocation;

      const alwaysAllowed = ['/splash', '/login', '/guest'];
      if (alwaysAllowed.contains(location)) {
        return null;
      }

      final allowWithoutLogin = [
        '/home',
        '/home/dining',
        '/home/dining/detail',
        '/home/events',
        '/home/events/detail',
        '/home/movies',
        '/home/movies/detail',
      ];

      final isAllowedWithoutLogin = allowWithoutLogin.any((route) => location.startsWith(route)) || 
                                     location.contains('/detail');
      
      if (isAllowedWithoutLogin) {
        return null;
      }

      if (user == null) {
        return '/login';
      }
     
      if (user!= null && location == '/login') {
        return '/home';
      }
      return null;
    },
  );
});
