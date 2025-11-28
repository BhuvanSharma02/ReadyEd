import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geomag/geomag.dart'; // Correct import for geomag

class StudentCompassScreen extends StatefulWidget {
  final String studentName;
  final double studentLat;
  final double studentLng;

  const StudentCompassScreen({
    Key? key,
    required this.studentName,
    required this.studentLat,
    required this.studentLng,
  }) : super(key: key);

  @override
  State<StudentCompassScreen> createState() => _StudentCompassScreenState();
}

class _StudentCompassScreenState extends State<StudentCompassScreen> {
  double? _heading; // Magnetic Heading
  double? _bearing; // True North Bearing to student
  double? _distance;
  Position? _currentPosition;
  double _declination = 0.0; // Magnetic Declination

  @override
  void initState() {
    super.initState();
    _initCompass();
    _startLocationUpdates();
  }

  void _initCompass() {
    FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          _heading = event.heading;
        });
      }
    });
  }

  void _startLocationUpdates() async {
    // Try to get last known position immediately for quick start
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        _updateCalculations(lastKnown);
        _updateMagneticDeclination(lastKnown);
      }
    } catch (e) {
      print('Error getting last known position: $e');
    }

    // Start the stream
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, // Update every 2 meters
      ),
    ).listen((Position position) {
      if (mounted) {
        _updateCalculations(position);
        _updateMagneticDeclination(position); // Update declination
      }
    });
  }

  void _updateCalculations(Position currentPos) {
    double bearing = Geolocator.bearingBetween(
      currentPos.latitude,
      currentPos.longitude,
      widget.studentLat,
      widget.studentLng,
    );

    double distance = Geolocator.distanceBetween(
      currentPos.latitude,
      currentPos.longitude,
      widget.studentLat,
      widget.studentLng,
    );

    setState(() {
      _currentPosition = currentPos;
      _bearing = bearing;
      _distance = distance;
    });
  }

  void _updateMagneticDeclination(Position position) {
    final geomag = GeoMag();
    final result = geomag.calculate(
      position.latitude,
      position.longitude,
      position.altitude * 3.28084, // Convert meters to feet
      DateTime.now(),
    );
    setState(() {
      _declination = result.dec;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the rotation needed for the arrow
    // True Heading = Magnetic Heading + Declination
    // Rotation = Bearing (True North) - True Heading
    
    double rotation = 0;
    if (_heading != null && _bearing != null) {
      double trueHeading = (_heading! + _declination) % 360; // Adjust for declination
      rotation = _bearing! - trueHeading;
      
      // Normalize to 0-360
      if (rotation < 0) rotation += 360;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text('Finding ${widget.studentName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Distance Indicator
            Text(
              _distance != null 
                  ? '${_distance!.toStringAsFixed(1)} m' 
                  : 'Calculating...',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'DISTANCE',
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 60),

            // Compass / Direction Arrow
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer Ring (Static Compass Rose)
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                    gradient: RadialGradient(
                      colors: [Colors.blue.shade900.withOpacity(0.2), Colors.transparent],
                    ),
                  ),
                  child: Transform.rotate(
                    angle: -((_heading ?? 0) + _declination) * (math.pi / 180), // Rotate rose by true heading
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('N', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24)),
                        Text('S', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 24)),
                      ],
                    ),
                  ),
                ),
                
                // Direction Arrow
                if (_heading != null && _bearing != null)
                  Transform.rotate(
                    angle: rotation * (math.pi / 180),
                    child: const Icon(
                      Icons.navigation, // Points UP by default, like a standard navigation arrow
                      size: 100,
                      color: Color(0xFF2E7D8F),
                    ),
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Debug Info (Optional, helpful for verification)
            if (_heading != null && _bearing != null)
              Text(
                'Heading (Mag): ${_heading!.toStringAsFixed(0)}° | Declination: ${_declination.toStringAsFixed(1)}° | Bearing (True): ${_bearing!.toStringAsFixed(0)}°',
                style: const TextStyle(color: Colors.white24, fontSize: 12),
              ),
            
            const SizedBox(height: 20),
            
            // Status Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentPosition != null && _currentPosition!.accuracy < 20 
                        ? Icons.gps_fixed 
                        : Icons.gps_not_fixed,
                    color: _currentPosition != null && _currentPosition!.accuracy < 20 
                        ? Colors.green 
                        : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _currentPosition != null && _currentPosition!.accuracy < 20
                        ? 'GPS Signal: Good'
                        : 'GPS Signal: Weak (${_currentPosition?.accuracy.toStringAsFixed(0)}m)',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
