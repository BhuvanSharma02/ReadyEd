import 'package:geomag/geomag.dart';

void main() {
  final geomag = GeoMag();
  final result = geomag.calculate(0, 0, 0, DateTime.now());
  print('Result type: ${result.runtimeType}');
  // I'll try to access 'dec' or 'declination' inside a try-catch block or just inspect the object if I can print it.
  // Dart objects don't dump properties easily without reflection which might be disabled.
  // But I can try to see if it compiles with 'dec'.
}
