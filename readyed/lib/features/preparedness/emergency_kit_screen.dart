import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyKitScreen extends StatefulWidget {
  const EmergencyKitScreen({super.key});

  @override
  State<EmergencyKitScreen> createState() => _EmergencyKitScreenState();
}

class _EmergencyKitScreenState extends State<EmergencyKitScreen> {
  final Map<String, bool> _kitItems = {
    'Water (one gallon per person per day)': false,
    'Food (non-perishable 3-day supply)': false,
    'Battery-powered or hand crank radio': false,
    'Flashlight': false,
    'First aid kit': false,
    'Extra batteries': false,
    'Whistle (to signal for help)': false,
    'Dust mask (to help filter contaminated air)': false,
    'Cell phone with chargers and a backup battery': false,
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKitItems();
  }

  Future<void> _loadKitItems() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var key in _kitItems.keys) {
        _kitItems[key] = prefs.getBool('kit_item_$key') ?? false;
      }
      _isLoading = false;
    });
  }

  Future<void> _toggleItem(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kitItems[key] = value;
    });
    await prefs.setBool('kit_item_$key', value);
  }

  double _calculateProgress() {
    if (_kitItems.isEmpty) return 0.0;
    int checkedCount = _kitItems.values.where((val) => val).length;
    return checkedCount / _kitItems.length;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Kit Checklist'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Preparedness Level',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Keep these items in an easy-to-carry bag.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _kitItems.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      String key = _kitItems.keys.elementAt(index);
                      bool isChecked = _kitItems[key]!;
                      return CheckboxListTile(
                        title: Text(
                          key,
                          style: TextStyle(
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                            color: isChecked ? Colors.grey : null,
                          ),
                        ),
                        value: isChecked,
                        onChanged: (bool? value) {
                          if (value != null) {
                            _toggleItem(key, value);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
