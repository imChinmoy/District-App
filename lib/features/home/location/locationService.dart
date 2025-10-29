import 'package:district/features/home/location/location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart' hide LocationData;

class LocationService {
  final Location _location = Location();

  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        return null;
      }

      final locationData = await _location.getLocation();
      
      if (locationData.latitude != null && locationData.longitude != null) {
        final address = await _getAddressFromCoordinates(
          locationData.latitude!,
          locationData.longitude!,
        );

        return address;
      }
      return null;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<LocationData> _getAddressFromCoordinates(
  double lat,
  double lng,
) async {
  try {
    List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(lat, lng);
    
    if (placemarks.isNotEmpty) {
      geo.Placemark place = placemarks[0];

      String locationName = '';
      
      if (place.name != null && place.name!.isNotEmpty) {
        locationName = place.name!;
      } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        locationName = place.subLocality!;
      } else if (place.locality != null && place.locality!.isNotEmpty) {
        locationName = place.locality!;
      } else if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
        locationName = place.administrativeArea!;
      } else {
        locationName = 'Unknown Location';
      }
      
      List<String> addressParts = [];
      
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        addressParts.add(place.subLocality!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        addressParts.add(place.locality!);
      }
      if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
        addressParts.add(place.administrativeArea!);
      }
      if (place.country != null && place.country!.isNotEmpty) {
        addressParts.add(place.country!);
      }
      
      String subLocation = addressParts.isNotEmpty 
          ? addressParts.join(', ')
          : 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';

      return LocationData(
        latitude: lat,
        longitude: lng,
        locationName: locationName,
        subLocation: subLocation,
      );
    }
  } catch (e) {
    print('Error in reverse geocoding: $e');
  }

  return LocationData(
    latitude: lat,
    longitude: lng,
    locationName: 'Location',
    subLocation: 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}',
  );
}

  Stream<LocationData> getLocationStream() async* {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      yield LocationData(
        latitude: 0.0,
        longitude: 0.0,
        locationName: 'Permission Denied',
        subLocation: 'Please enable location permission',
        error: 'Permission denied',
      );
      return;
    }

    await for (final locationData in _location.onLocationChanged) {
      if (locationData.latitude != null && locationData.longitude != null) {
        final address = await _getAddressFromCoordinates(
          locationData.latitude!,
          locationData.longitude!,
        );
        yield address;
      }
    }
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final currentLocationProvider = StateNotifierProvider<LocationNotifier, LocationData>(
  (ref) => LocationNotifier(ref.read(locationServiceProvider)),
);