import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'student_compass_screen.dart';

class NearbyFinderScreen extends StatefulWidget {
  const NearbyFinderScreen({Key? key}) : super(key: key);

  @override
  State<NearbyFinderScreen> createState() => _NearbyFinderScreenState();
}

class StudentInfo {
  final String name;
  final String id;
  double? distance; // Meters
  double? bearing; // Degrees
  double? lat;
  double? lng;
  double? accuracy;
  DateTime lastSeen;
  bool isFound;
  
  StudentInfo({
    required this.name, 
    required this.id, 
    this.distance,
    this.bearing,
    this.lat,
    this.lng,
    this.accuracy,
    required this.lastSeen,
    this.isFound = false,
  });
}

class _NearbyFinderScreenState extends State<NearbyFinderScreen> {
  final Strategy strategy = Strategy.P2P_STAR;
  final String serviceId = "com.readyed.app"; 
  UserModel? currentUser;
  bool isTeacher = false;
  bool isStudent = false;
  bool isAdvertising = false;
  bool isDiscovering = false;
  
  // Map of endpointId -> StudentInfo
  final Map<String, StudentInfo> _foundStudents = {};
  
  String? _connectedTeacherId; 
  StudentInfo? _teacherInfo; // To store teacher's location
  StreamSubscription<Position>? _locationStream;
  StreamSubscription<CompassEvent>? _compassStream;
  double? _currentHeading;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _initCompass();
  }

  void _initCompass() {
    _compassStream = FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          _currentHeading = event.heading;
        });
      }
    });
  }

  Future<void> _loadUser() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.getUserData();
    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  void dispose() {
    _stopLocationStream();
    _compassStream?.cancel();
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    super.dispose();
  }

  void _stopLocationStream() {
    _locationStream?.cancel();
    _locationStream = null;
  }

  Future<void> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.nearbyWifiDevices,
    ].request();

    if (statuses.values.any((status) => status.isDenied || status.isPermanentlyDenied)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissions are required to use this feature.')),
        );
      }
    }
  }

  // ----------------------------------------------------------------------
  // STUDENT LOGIC
  // ----------------------------------------------------------------------

  void _startAdvertising() async {
    await _checkPermissions();
    if (currentUser == null) return;

    try {
      bool a = await Nearby().startAdvertising(
        currentUser!.name,
        strategy,
        serviceId: serviceId,
        onConnectionInitiated: (String id, ConnectionInfo info) {
          Nearby().acceptConnection(
            id,
            onPayLoadRecieved: (endpointId, payload) {
              if (payload.type == PayloadType.BYTES) {
                String str = utf8.decode(payload.bytes!);
                try {
                  _processTeacherLocationData(endpointId, str);
                } catch (e) {
                  print("Error parsing teacher payload: $e");
                }
              }
            },
          );
        },
        onConnectionResult: (String id, Status status) {
          if (status == Status.CONNECTED) {
            setState(() {
              _connectedTeacherId = id;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Connected to Teacher. Sending location...')),
            );
            _startStudentLocationStream(id);
          } else {
            setState(() {
              _connectedTeacherId = null;
              _teacherInfo = null;
            });
            _stopLocationStream();
          }
        },
        onDisconnected: (String id) {
          setState(() {
            _connectedTeacherId = null;
            _teacherInfo = null;
          });
          _stopLocationStream();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Disconnected from Teacher')),
          );
        },
      );
      
      if (a && mounted) {
        setState(() {
          isAdvertising = true;
        });
      }
    } catch (e) {
      print('Error starting advertising: $e');
    }
  }

  void _disconnectFromTeacher() async {
    if (_connectedTeacherId != null) {
      await Nearby().disconnectFromEndpoint(_connectedTeacherId!);
      setState(() {
        _connectedTeacherId = null;
        _teacherInfo = null;
      });
      _stopLocationStream();
    }
  }

  Future<void> _processTeacherLocationData(String endpointId, String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr);
      if (data['lat'] == null || data['lng'] == null) return;
      
      final double lat = data['lat'];
      final double lng = data['lng'];
      
      Position myPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      double distance = Geolocator.distanceBetween(
        myPos.latitude,
        myPos.longitude,
        lat,
        lng,
      );

      double bearing = Geolocator.bearingBetween(
        myPos.latitude,
        myPos.longitude,
        lat,
        lng,
      );
      
      setState(() {
        _teacherInfo = StudentInfo(
          name: "Teacher", 
          id: endpointId,
          distance: distance,
          bearing: bearing,
          lat: lat,
          lng: lng,
          lastSeen: DateTime.now(),
        );
      });
    } catch (e) {
      print("Error processing teacher location: $e");
    }
  }

  void _startStudentLocationStream(String teacherId) {
    _sendLocationUpdate(teacherId);

    _locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, 
      ),
    ).listen((Position position) {
      _sendLocationPayload(teacherId, position);
    });
  }

  Future<void> _sendLocationUpdate(String teacherId) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _sendLocationPayload(teacherId, position);
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _sendLocationPayload(String endpointId, Position position) {
    Map<String, dynamic> locationData = {
      'lat': position.latitude,
      'lng': position.longitude,
      'acc': position.accuracy,
    };
    
    String jsonString = jsonEncode(locationData);
    Nearby().sendBytesPayload(endpointId, Uint8List.fromList(utf8.encode(jsonString)));
  }

  void _stopAdvertising() async {
    await Nearby().stopAdvertising();
    _stopLocationStream();
    if (mounted) {
      setState(() {
        isAdvertising = false;
        _connectedTeacherId = null;
        _teacherInfo = null;
      });
    }
  }

  // ----------------------------------------------------------------------
  // TEACHER LOGIC
  // ----------------------------------------------------------------------

  void _startDiscovery() async {
    await _checkPermissions();
    if (currentUser == null) return;

    try {
      bool a = await Nearby().startDiscovery(
        currentUser!.name,
        strategy,
        serviceId: serviceId,
        onEndpointFound: (id, userName, serviceId) {
          Nearby().requestConnection(
            currentUser!.name,
            id,
            onConnectionInitiated: (id, info) {
              Nearby().acceptConnection(
                id,
                onPayLoadRecieved: (endpointId, payload) {
                  if (payload.type == PayloadType.BYTES) {
                    String str = utf8.decode(payload.bytes!);
                    _processLocationData(endpointId, str);
                  }
                },
              );
            },
            onConnectionResult: (id, status) {
              if (status == Status.CONNECTED) {
                 setState(() {
                   if (!_foundStudents.containsKey(id)) {
                     _foundStudents[id] = StudentInfo(name: userName, id: id, lastSeen: DateTime.now());
                   }
                 });
                 _startTeacherLocationStream(id);
              }
            },
            onDisconnected: (id) {
              setState(() {
                _foundStudents.remove(id);
              });
            },
          );
        },
        onEndpointLost: (id) {
          setState(() {
            _foundStudents.remove(id);
          });
        },
      );

      if (a && mounted) {
        setState(() {
          isDiscovering = true;
          _foundStudents.clear();
        });
      }
    } catch (e) {
      print('Error starting discovery: $e');
    }
  }

  void _startTeacherLocationStream(String studentId) {
    if (_locationStream != null) return;

    _locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      for (String id in _foundStudents.keys) {
        _sendLocationPayload(id, position);
      }
    });
  }

  Future<void> _processLocationData(String endpointId, String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr);
      if (data['lat'] == null || data['lng'] == null) return;

      final double studentLat = data['lat'];
      final double studentLng = data['lng'];
      final double accuracy = (data['acc'] as num).toDouble();
      
      Position teacherPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      double distanceInMeters = Geolocator.distanceBetween(
        teacherPos.latitude,
        teacherPos.longitude,
        studentLat,
        studentLng,
      );

      double bearing = Geolocator.bearingBetween(
        teacherPos.latitude,
        teacherPos.longitude,
        studentLat,
        studentLng,
      );
      
      setState(() {
        if (_foundStudents.containsKey(endpointId)) {
          final student = _foundStudents[endpointId]!;
          bool isFound = student.isFound;
          if (distanceInMeters < 10) {
            isFound = true;
          } else if (distanceInMeters > 20) {
            isFound = false;
          }

          _foundStudents[endpointId] = StudentInfo(
            name: student.name,
            id: student.id,
            distance: isFound ? 0.0 : distanceInMeters,
            bearing: bearing,
            lat: studentLat,
            lng: studentLng,
            accuracy: accuracy,
            lastSeen: DateTime.now(),
            isFound: isFound,
          );
        }
      });
      
    } catch (e) {
      print('Error processing location data: $e');
    }
  }

  void _stopDiscovery() async {
    await Nearby().stopDiscovery();
    _stopLocationStream();
    if (mounted) {
      setState(() {
        isDiscovering = false;
        _foundStudents.clear();
      });
    }
  }

  // ----------------------------------------------------------------------
  // UI
  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom Finder'),
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isTeacher && !isStudent) ...[
                    _buildRoleSelection(),
                  ] else if (isTeacher) ...[
                    _buildTeacherView(),
                  ] else ...[
                    _buildStudentView(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Select your role',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => setState(() => isTeacher = true),
          icon: const Icon(Icons.school, size: 32),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('I am a Teacher', style: TextStyle(fontSize: 18)),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D8F),
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => setState(() => isStudent = true),
          icon: const Icon(Icons.person, size: 32),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('I am a Student', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherView() {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            child: Stack(
              children: [
                Center(
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: RadarPainter(),
                  ),
                ),
                const Center(
                  child: Icon(Icons.navigation, color: Colors.white, size: 30),
                ),
                ..._foundStudents.values.map((student) {
                  if (student.isFound) {
                    return const Center(
                      child: Tooltip(
                        message: 'Student Found!',
                        triggerMode: TooltipTriggerMode.tap,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.check, size: 16, color: Colors.white),
                        ),
                      ),
                    );
                  }
                  if (student.distance == null || student.bearing == null) return const SizedBox.shrink();
                  const double maxRange = 100.0;
                  const double radius = 140.0;
                  double relativeBearing = (student.bearing! - (_currentHeading ?? 0)) * (math.pi / 180);
                  double distFactor = (student.distance! / maxRange).clamp(0.0, 1.0);
                  double r = distFactor * radius;
                  double dx = r * math.sin(relativeBearing);
                  double dy = -r * math.cos(relativeBearing);
                  return Center(
                    child: Transform.translate(
                      offset: Offset(dx, dy),
                      child: Tooltip(
                        message: '${student.name} (${student.distance!.toStringAsFixed(1)}m)',
                        triggerMode: TooltipTriggerMode.tap,
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.greenAccent,
                          child: Icon(Icons.person, size: 12, color: Colors.black),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                Positioned(
                  bottom: 10, left: 0, right: 0,
                  child: Text(
                    isDiscovering ? "Scanning... (${_foundStudents.length} Connected)" : "Radar Off",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!isDiscovering)
            ElevatedButton(
              onPressed: _startDiscovery,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Start Radar'),
            )
          else
            ElevatedButton(
              onPressed: _stopDiscovery,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Stop Radar'),
            ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Connected Students:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: _foundStudents.isEmpty
                ? Center(child: Text('No connections yet', style: TextStyle(color: Colors.grey[600])))
                : ListView.builder(
                    itemCount: _foundStudents.length,
                    itemBuilder: (context, index) {
                      final id = _foundStudents.keys.elementAt(index);
                      final student = _foundStudents[id]!;
                      String subtitleText = 'Connected';
                      Color distanceColor = Colors.grey;
                      IconData signalIcon = Icons.signal_wifi_off;
                      if (student.isFound) {
                         subtitleText = 'Found! (Nearby)';
                         distanceColor = Colors.blue;
                         signalIcon = Icons.check_circle;
                      } else if (student.distance != null) {
                         if (student.distance! < 10) {
                           signalIcon = Icons.signal_wifi_4_bar;
                           distanceColor = Colors.green;
                         } else if (student.distance! < 50) {
                           signalIcon = Icons.network_wifi_3_bar;
                           distanceColor = Colors.lightGreen;
                         } else {
                           signalIcon = Icons.network_wifi_1_bar;
                           distanceColor = Colors.orange;
                         }
                         subtitleText = '${student.distance!.toStringAsFixed(1)}m away';
                      }
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFF2E7D8F), child: Icon(Icons.person, color: Colors.white)),
                          title: Text(student.name),
                          subtitle: Text(subtitleText),
                          trailing: Icon(signalIcon, color: distanceColor),
                          onTap: () {
                            if (student.lat != null && student.lng != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => StudentCompassScreen(studentName: student.name, studentLat: student.lat!, studentLng: student.lng!)));
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
          TextButton(onPressed: () { _stopDiscovery(); setState(() => isTeacher = false); }, child: const Text('Switch Role')),
        ],
      ),
    );
  }

  Widget _buildStudentView() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            child: Stack(
              children: [
                Center(child: CustomPaint(size: const Size(300, 300), painter: RadarPainter())),
                const Center(child: Icon(Icons.navigation, color: Colors.white, size: 30)),
                if (_teacherInfo != null && _teacherInfo!.distance != null && _teacherInfo!.bearing != null)
                  Builder(
                    builder: (context) {
                      const double maxRange = 100.0;
                      const double radius = 140.0;
                      double relativeBearing = (_teacherInfo!.bearing! - (_currentHeading ?? 0)) * (math.pi / 180);
                      double distFactor = (_teacherInfo!.distance! / maxRange).clamp(0.0, 1.0);
                      double r = distFactor * radius;
                      double dx = r * math.sin(relativeBearing);
                      double dy = -r * math.cos(relativeBearing);
                      return Center(
                        child: Transform.translate(
                          offset: Offset(dx, dy),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(radius: 12, backgroundColor: Colors.orangeAccent, child: Icon(Icons.school, size: 16, color: Colors.black)),
                              Text("${_teacherInfo!.distance!.toStringAsFixed(0)}m", style: const TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                Positioned(
                  bottom: 10, left: 0, right: 0,
                  child: Text(
                    _connectedTeacherId != null ? "Connected to Teacher" : (isAdvertising ? "Broadcasting... Waiting for Teacher" : "Offline"),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (_connectedTeacherId != null) ...[
            ElevatedButton.icon(
              onPressed: _disconnectFromTeacher,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              icon: const Icon(Icons.link_off),
              label: const Text('Disconnect from Teacher'),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isAdvertising ? _stopAdvertising : _startAdvertising,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdvertising ? Colors.red : const Color(0xFF2E7D8F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isAdvertising ? 'Stop Broadcasting' : 'Connect to Teacher', style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: () { _stopAdvertising(); setState(() => isStudent = false); }, child: const Text('Switch Role')),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.greenAccent.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width / 2 - 10;
    canvas.drawCircle(center, maxRadius * 0.33, paint);
    canvas.drawCircle(center, maxRadius * 0.66, paint);
    canvas.drawCircle(center, maxRadius, paint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), paint);
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}