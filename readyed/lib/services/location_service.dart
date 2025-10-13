import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/indian_states_disasters.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  IndianState? _currentState;
  Position? _currentPosition;

  IndianState? get currentState => _currentState;
  Position? get currentPosition => _currentPosition;

  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Permission.location.request();
      return permission == PermissionStatus.granted;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      _currentPosition = position;
      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  Future<IndianState?> detectCurrentState() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) return null;

      // First, try to find the nearest state using coordinates
      IndianState? nearestState = IndianStatesData.findNearestState(
        position.latitude,
        position.longitude,
      );

      // Verify with geocoding if available
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          String? detectedState = place.administrativeArea;
          
          if (detectedState != null) {
            IndianState? geocodedState = IndianStatesData.getStateByName(detectedState);
            if (geocodedState != null) {
              _currentState = geocodedState;
              return geocodedState;
            }
          }
        }
      } catch (e) {
        print('Geocoding failed, using nearest state: $e');
      }

      _currentState = nearestState;
      return nearestState;
    } catch (e) {
      print('Error detecting current state: $e');
      return null;
    }
  }

  Future<String> getLocationDescription() async {
    try {
      Position? position = _currentPosition ?? await getCurrentPosition();
      if (position == null) return 'Location not available';

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String> locationParts = [];
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          locationParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          locationParts.add(place.administrativeArea!);
        }
        
        return locationParts.join(', ');
      }
      
      return 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      print('Error getting location description: $e');
      return 'Location not available';
    }
  }

  void setManualState(IndianState state) {
    _currentState = state;
  }

  List<DisasterType> getCurrentStateDisasters() {
    if (_currentState == null) return [];
    return IndianStatesData.getDisastersForState(_currentState!.name);
  }

  bool isInIndia(double latitude, double longitude) {
    // India's approximate bounding box
    const double northBound = 37.6;
    const double southBound = 6.4;
    const double westBound = 68.1;
    const double eastBound = 97.4;

    return latitude >= southBound &&
           latitude <= northBound &&
           longitude >= westBound &&
           longitude <= eastBound;
  }

  Future<bool> isCurrentLocationInIndia() async {
    Position? position = _currentPosition ?? await getCurrentPosition();
    if (position == null) return false;
    
    return isInIndia(position.latitude, position.longitude);
  }

  // Get distance to a specific state center
  double? getDistanceToState(IndianState state) {
    if (_currentPosition == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      state.coordinates[0],
      state.coordinates[1],
    ) / 1000; // Convert to kilometers
  }

  // Get nearby states within a certain radius (in km)
  List<IndianState> getNearbyStates({double radiusKm = 200}) {
    if (_currentPosition == null) return [];

    List<IndianState> nearbyStates = [];

    for (IndianState state in IndianStatesData.states) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        state.coordinates[0],
        state.coordinates[1],
      ) / 1000; // Convert to kilometers

      if (distance <= radiusKm) {
        nearbyStates.add(state);
      }
    }

    // Sort by distance
    nearbyStates.sort((a, b) {
      double distanceA = getDistanceToState(a) ?? double.infinity;
      double distanceB = getDistanceToState(b) ?? double.infinity;
      return distanceA.compareTo(distanceB);
    });

    return nearbyStates;
  }

  void clearLocationData() {
    _currentState = null;
    _currentPosition = null;
  }
}