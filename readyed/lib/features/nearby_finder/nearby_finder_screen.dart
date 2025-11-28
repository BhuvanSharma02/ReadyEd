import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
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
  double? distance;
  double? lat;
  double? lng;
  double? accuracy;
  
  StudentInfo({
    required this.name, 
    required this.id, 
    this.distance,
    this.lat,
    this.lng,
    this.accuracy,
  });
}

class _NearbyFinderScreenState extends State<NearbyFinderScreen> {
  final Strategy strategy = Strategy.P2P_STAR;
  final String serviceId = "com.readyed.app"; // Unique Service ID
  UserModel? currentUser;
  bool isTeacher = false;
  bool isStudent = false;
  bool isAdvertising = false;
  bool isDiscovering = false;
  
  // Map of endpointId -> StudentInfo
  final Map<String, StudentInfo> _foundStudents = {};
  
  // New variables for location updates
  String? _connectedTeacherId; 
  Timer? _locationTimer; 

  @override
  void initState() {
    super.initState();
    _loadUser();
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
    _locationTimer?.cancel();
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    // Check and request permissions needed for Nearby Connections
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

  void _startAdvertising() async {
    await _checkPermissions();
    if (currentUser == null) return;

    try {
      bool a = await Nearby().startAdvertising(
        currentUser!.name,
        strategy,
        serviceId: serviceId,
        onConnectionInitiated: (String id, ConnectionInfo info) {
          // Auto-accept connection to share location
          Nearby().acceptConnection(
            id,
            onPayLoadRecieved: (endpointId, payload) {
              // Student shouldn't receive payloads in this basic implementation
            },
          );
        },
        onConnectionResult: (String id, Status status) {
          if (status == Status.CONNECTED) {
            // Connected to teacher! Start sending location updates.
            setState(() {
              _connectedTeacherId = id;
            });
            _startSendingLocation(id);
          } else {
            setState(() {
              _connectedTeacherId = null;
            });
            _locationTimer?.cancel();
          }
        },
        onDisconnected: (String id) {
          print('Disconnected: $id');
          setState(() {
            _connectedTeacherId = null;
          });
          _locationTimer?.cancel();
        },
      );
      
      if (a && mounted) {
        setState(() {
          isAdvertising = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are now visible to teachers.')),
        );
      }
    } catch (e) {
      print('Error starting advertising: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _startSendingLocation(String endpointId) {
    _locationTimer?.cancel();
    _sendLocation(endpointId); // Send immediately
    
    // Then send every 2 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_connectedTeacherId == endpointId) {
        _sendLocation(endpointId);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendLocation(String endpointId) async {
    try {
      Position? position;
      try {
        // Try getting high accuracy location with a timeout
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (e) {
        print('GPS timeout or error: $e');
        // Fallback to last known position
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        Map<String, dynamic> locationData = {
          'lat': position.latitude,
          'lng': position.longitude,
          'acc': position.accuracy,
        };
        
        String jsonString = jsonEncode(locationData);
        Nearby().sendBytesPayload(endpointId, Uint8List.fromList(utf8.encode(jsonString)));
      }
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  void _stopAdvertising() async {
    _locationTimer?.cancel();
    await Nearby().stopAdvertising();
    if (mounted) {
      setState(() {
        isAdvertising = false;
        _connectedTeacherId = null;
      });
    }
  }

  void _startDiscovery() async {
    await _checkPermissions();
    if (currentUser == null) return;

    try {
      bool a = await Nearby().startDiscovery(
        currentUser!.name,
        strategy,
        serviceId: serviceId,
        onEndpointFound: (id, userName, serviceId) {
          // Found a student!
          setState(() {
            _foundStudents[id] = StudentInfo(name: userName, id: id);
          });
          
          // Auto-request connection to get location
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
              print('Connection status: $status');
            },
            onDisconnected: (id) {
              setState(() {
                _foundStudents.remove(id);
              });
            },
          );
        },
        onEndpointLost: (id) {
          // Lost a student
          setState(() {
            _foundStudents.remove(id);
          });
        },
      );

      if (a && mounted) {
        setState(() {
          isDiscovering = true;
          _foundStudents.clear(); // Clear previous list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Searching for students...')),
        );
      }
    } catch (e) {
      print('Error starting discovery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  Future<void> _processLocationData(String endpointId, String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr);
      final double studentLat = data['lat'];
      final double studentLng = data['lng'];
      final double accuracy = (data['acc'] as num).toDouble();
      
      // Get teacher's location
      Position teacherPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      double distanceInMeters = Geolocator.distanceBetween(
        teacherPos.latitude,
        teacherPos.longitude,
        studentLat,
        studentLng,
      );
      
      setState(() {
        if (_foundStudents.containsKey(endpointId)) {
          final student = _foundStudents[endpointId]!;
          _foundStudents[endpointId] = StudentInfo(
            name: student.name,
            id: student.id,
            distance: distanceInMeters,
            lat: studentLat,
            lng: studentLng,
            accuracy: accuracy,
          );
        }
      });
      
    } catch (e) {
      print('Error processing location data: $e');
    }
  }

  void _stopDiscovery() async {
    await Nearby().stopDiscovery();
    if (mounted) {
      setState(() {
        isDiscovering = false;
        _foundStudents.clear();
      });
    }
  }

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
          onPressed: () {
            setState(() {
              isTeacher = true;
            });
          },
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
          onPressed: () {
            setState(() {
              isStudent = true;
            });
          },
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
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.radar, size: 48, color: Colors.blue),
                  const SizedBox(height: 8),
                  const Text(
                    'Student Finder',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(isDiscovering ? 'Scanning for students nearby...' : 'Start scanning to find students'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!isDiscovering)
            ElevatedButton(
              onPressed: _startDiscovery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Start Scanning'),
            )
          else
            ElevatedButton(
              onPressed: _stopDiscovery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Stop Scanning'),
            ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Nearby Students:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _foundStudents.isEmpty
                ? Center(
                    child: Text(
                      isDiscovering ? 'Searching...' : 'No students found yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _foundStudents.length,
                    itemBuilder: (context, index) {
                      final id = _foundStudents.keys.elementAt(index);
                      final student = _foundStudents[id]!;
                      
                      // Determine display text and signal icon based on distance/accuracy
                      String subtitleText = 'Connecting for location...';
                      Color distanceColor = Colors.grey;
                      IconData signalIcon = Icons.signal_wifi_0_bar;
                      
                      if (student.distance != null) {
                         // Icon based on distance (Hot/Cold)
                         if (student.distance! < 5) {
                           signalIcon = Icons.signal_wifi_4_bar;
                           distanceColor = Colors.green;
                         } else if (student.distance! < 10) {
                           signalIcon = Icons.network_wifi_3_bar;
                           distanceColor = Colors.lightGreen;
                         } else if (student.distance! < 20) {
                           signalIcon = Icons.network_wifi_2_bar;
                           distanceColor = Colors.orange;
                         } else {
                           signalIcon = Icons.network_wifi_1_bar;
                           distanceColor = Colors.red;
                         }

                         // Text warning if accuracy is bad
                         if (student.accuracy != null && student.accuracy! > 20) {
                           subtitleText = 'Low GPS Signal (Approx. ${student.distance!.toStringAsFixed(0)}m)';
                           // Keep the distance color (e.g. Red/Orange) to show it's "Far" or "Uncertain"
                         } else {
                           subtitleText = '${student.distance!.toStringAsFixed(1)} meters away';
                         }
                      }
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF2E7D8F),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(student.name),
                          subtitle: Text(subtitleText),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(signalIcon, color: distanceColor),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () {
                            if (student.lat != null && student.lng != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentCompassScreen(
                                    studentName: student.name,
                                    studentLat: student.lat!,
                                    studentLng: student.lng!,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Waiting for student location...')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
          TextButton(
            onPressed: () {
              _stopDiscovery();
              setState(() {
                isTeacher = false;
              });
            },
            child: const Text('Switch Role'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentView() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            color: isAdvertising ? Colors.green.shade50 : Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    isAdvertising ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                    size: 64,
                    color: isAdvertising ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAdvertising ? 'Visible to Teachers' : 'Not Visible',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (_connectedTeacherId != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Connected to Teacher',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Text('Sending location updates...', style: TextStyle(color: Colors.grey)),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Name: ${currentUser?.name ?? "Unknown"}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isAdvertising ? _stopAdvertising : _startAdvertising,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdvertising ? Colors.red : const Color(0xFF2E7D8F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isAdvertising ? 'Stop Broadcasting' : 'Make Me Visible',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _stopAdvertising();
              setState(() {
                isStudent = false;
              });
            },
            child: const Text('Switch Role'),
          ),
        ],
      ),
    );
  }
}