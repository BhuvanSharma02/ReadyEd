import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  double? _heading;
  double _bearing = 0;
  double? _distance;
  Position? _currentPosition;

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

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, 
      ),
    ).listen((Position position) {
      if (mounted) {
        _updateCalculations(position);
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

  @override
  Widget build(BuildContext context) {
    // 1. Calculate raw target rotation (Bearing relative to North - Phone Heading)
    double targetRotation = 0;
    if (_heading != null) {
      targetRotation = _bearing - _heading!;
    }
    
    // Normalize to 0-360
    targetRotation = (targetRotation + 360) % 360;

    // 2. Logic to hide arrow if too close or GPS too weak
    bool isTooClose = _distance != null && _distance! < 5.0; // Less than 5 meters
    bool isGpsWeak = _currentPosition != null && _currentPosition!.accuracy > 20.0;
    bool showArrow = !isTooClose; 

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
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isTooClose ? Colors.greenAccent : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isTooClose ? 'YOU ARE HERE' : 'DISTANCE',
              style: TextStyle(
                color: isTooClose ? Colors.greenAccent : Colors.grey,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 40),

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
                    border: Border.all(color: Colors.white12, width: 2),
                    gradient: RadialGradient(
                      colors: [Colors.blue.shade900.withOpacity(0.1), Colors.transparent],
                    ),
                  ),
                  child: Transform.rotate(
                    angle: -(_heading ?? 0) * (math.pi / 180),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('N', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24)),
                        Text('S', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 24)),
                      ],
                    ),
                  ),
                ),
                
                // Direction Arrow (Animated)
                if (showArrow)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: targetRotation),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * (math.pi / 180),
                        child: const Icon(
                          FontAwesomeIcons.locationArrow,
                          size: 100,
                          color: Color(0xFF2E7D8F),
                        ),
                      );
                    },
                  )
                else if (isTooClose)
                  const Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.greenAccent,
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
            
            const SizedBox(height: 40), 
            
            // Warnings / Status
            if (isGpsWeak)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    const SizedBox(width: 12),
                    Text(
                      'Weak GPS (${_currentPosition?.accuracy.toStringAsFixed(0)}m accuracy)\nDirection may be incorrect.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.orangeAccent),
                    ),
                  ],
                ),
              ),
              
              if (!isGpsWeak && !isTooClose)
               const Padding(
                 padding: EdgeInsets.all(16.0),
                 child: Text(
                   "Keep phone flat and follow the arrow",
                   style: TextStyle(color: Colors.white38),
                 ),
               ),
          ],
        ),
      ),
    );
  }
}