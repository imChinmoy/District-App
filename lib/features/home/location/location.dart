import 'package:district/features/home/location/locationService.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String locationName;
  final String subLocation;
  final bool isLoading;
  final String? error;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.subLocation,
    this.isLoading = false,
    this.error,
  });

  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? locationName,
    String? subLocation,
    bool? isLoading,
    String? error,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      subLocation: subLocation ?? this.subLocation,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationData> {
  final LocationService _locationService;

  LocationNotifier(this._locationService)
      : super(LocationData(
          latitude: 0.0,
          longitude: 0.0,
          locationName: 'Fetching location...',
          subLocation: 'Please wait',
          isLoading: true,
        )) {
    _initLocation();
  }

  Future<void> _initLocation() async {
    state = state.copyWith(isLoading: true);
    
    final location = await _locationService.getCurrentLocation();
    
    if (location != null) {
      state = location.copyWith(isLoading: false);
    } else {
      state = state.copyWith(
        locationName: 'Location Unavailable',
        subLocation: 'Please enable location services',
        isLoading: false,
        error: 'Failed to get location',
      );
    }
  }

  Future<void> refreshLocation() async {
    await _initLocation();
  }
}
