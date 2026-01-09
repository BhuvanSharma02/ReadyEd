
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'dart:convert';
import '../models/disaster_alert.dart';

class AlertsService {
  // Mapping of state names to full RSS URLs from rss.txt
  static const Map<String, String> stateRssMap = {
    'Andhra Pradesh': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_andhra.xml',
    'Arunachal Pradesh': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_arunachal.xml',
    'Assam': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_assam.xml',
    'Bihar': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_bihar.xml',
    'Chandigarh': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_chandigarh.xml',
    'Chhattisgarh': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_chhattisgarh.xml',
    'Dadra and Nagar Haveli and Daman and Diu': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_dadra.xml',
    'Delhi': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_delhi.xml',
    'Goa': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_goa.xml',
    'Gujarat': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_gujarat.xml',
    'Haryana': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_haryana.xml',
    'Himachal Pradesh': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_himachal.xml',
    'Jammu and Kashmir': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_jammu.xml',
    'Jharkhand': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_jharkhand.xml',
    'Karnataka': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_karnataka.xml',
    'Kerala': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_kerala.xml',
    'Ladakh': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_ladakh.xml',
    'Lakshadweep': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_lakshadweep.xml',
    'Madhya Pradesh': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_madhya.xml',
    'Maharashtra': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_maharashtra.xml',
    'Manipur': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_manipur.xml',
    'Meghalaya': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_meghalaya.xml',
    'Mizoram': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_mizoram.xml',
    'Nagaland': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_nagaland.xml',
    'Odisha': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_odisha.xml',
    'Puducherry': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_puducherry.xml',
    'Punjab': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_punjab.xml',
    'Rajasthan': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_rajasthan.xml',
    'Sikkim': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_sikkim.xml',
    'Tamil Nadu': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_tamil.xml',
    'Telangana': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_telangana.xml',
    'Uttarakhand': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_uttarakhand.xml',
    'Uttar Pradesh': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_uttar.xml',
    'West Bengal': 'https://sachet.ndma.gov.in/cap_public_website/rss/rss_west.xml',
  };

  Future<List<DisasterAlert>> fetchAlerts(String stateName) async {
    final urlString = stateRssMap[stateName];
    if (urlString == null) return [];

    final url = Uri.parse(urlString);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Fix for gibberish text: Decode bytes as UTF-8
        final decodedBody = utf8.decode(response.bodyBytes);
        var feed = RssFeed.parse(decodedBody);
        return feed.items?.map((item) => DisasterAlert.fromRss(item)).toList() ?? [];
      } else {
        throw Exception('Failed to load alerts');
      }
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }
}
