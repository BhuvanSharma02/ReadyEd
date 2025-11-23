import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/eonet_event_model.dart';

class EonetService {
  static const String _baseUrl = 'https://eonet.gsfc.nasa.gov/api/v3/events';

  Future<List<EonetEvent>> fetchEvents({
    int days = 30, // Look for events in the last 30 days
    String status = 'open', // Only fetch open/ongoing events
  }) async {
    final url = Uri.parse('$_baseUrl?status=$status&days=$days');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> eventList = data['events'];
        return eventList.map((json) => EonetEvent.fromJson(json)).toList();
      } else {
        print('Failed to load events: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    }
    catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }
}
