import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readyed/models/disaster_alert.dart';
import 'package:readyed/services/alerts_service.dart';
import 'package:readyed/services/location_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertsService _alertsService = AlertsService();
  String _selectedState = 'Delhi'; // Default fallback
  List<DisasterAlert> _alerts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    final currentState = locationService.currentState;
    
    if (currentState != null && AlertsService.stateRssMap.containsKey(currentState.name)) {
      _selectedState = currentState.name;
    }
    
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() {
      _isLoading = true;
    });

    final alerts = await _alertsService.fetchAlerts(_selectedState);

    if (mounted) {
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    }
  }

  void _onStateChanged(String? newState) {
    if (newState != null) {
      setState(() {
        _selectedState = newState;
      });
      _fetchAlerts();
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime? date;
      try {
        date = HttpDate.parse(dateStr);
      } catch (_) {
        date = DateTime.tryParse(dateStr);
      }

      if (date != null) {
        return DateFormat('dd-MM-yyyy h:mm a').format(date.toLocal());
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAlerts,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.mapLocationDot, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedState,
                      isExpanded: true,
                      onChanged: _onStateChanged,
                      items: AlertsService.stateRssMap.keys.map<DropdownMenuItem<String>>((String state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Text(
                            state,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList()..sort((a, b) => a.value!.compareTo(b.value!)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _alerts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
                            const SizedBox(height: 16),
                            const Text(
                              'No recent alerts found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            Text(
                              'for $_selectedState',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _alerts.length,
                        itemBuilder: (context, index) {
                          final alert = _alerts[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ExpansionTile(
                              leading: _getAlertIcon(alert.title),
                              title: Text(
                                alert.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                _formatDate(alert.pubDate),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alert.title, // Use full title here
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _getAlertIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('flood')) {
      return const FaIcon(FontAwesomeIcons.houseFloodWater, color: Colors.blue);
    } else if (lowerTitle.contains('rain') || lowerTitle.contains('thunderstorm')) {
      return const FaIcon(FontAwesomeIcons.cloudShowersHeavy, color: Colors.indigo);
    } else if (lowerTitle.contains('heat') || lowerTitle.contains('wave')) {
      return const FaIcon(FontAwesomeIcons.temperatureHigh, color: Colors.orange);
    } else if (lowerTitle.contains('cyclone') || lowerTitle.contains('wind')) {
      return const FaIcon(FontAwesomeIcons.hurricane, color: Colors.teal);
    } else {
      return const FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.red);
    }
  }
}
