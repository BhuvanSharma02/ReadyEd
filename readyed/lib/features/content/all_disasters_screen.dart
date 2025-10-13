import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/indian_states_disasters.dart';
import '../../widgets/disaster_category_card.dart';
import 'disaster_detail_screen.dart';

class AllDisastersScreen extends StatelessWidget {
  const AllDisastersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Natural Disasters'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learn About All Disasters',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comprehensive information about natural disasters in India',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: IndianStatesData.disasterTypes.length,
              itemBuilder: (context, index) {
                final disaster = IndianStatesData.disasterTypes.values.elementAt(index);
                return DisasterCategoryCard(
                  title: disaster.name,
                  icon: _getIconData(disaster.iconName),
                  color: Color(int.parse(disaster.color)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisasterDetailScreen(disasterType: disaster.id),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'hurricane': return FontAwesomeIcons.hurricane;
      case 'house-flood-water': return FontAwesomeIcons.houseFloodWater;
      case 'sun': return FontAwesomeIcons.sun;
      case 'house-chimney-crack': return FontAwesomeIcons.houseChimneyCrack;
      case 'mountain': return FontAwesomeIcons.mountain;
      case 'temperature-high': return FontAwesomeIcons.temperatureHigh;
      case 'cloud-bolt': return FontAwesomeIcons.cloudBolt;
      case 'fire': return FontAwesomeIcons.fire;
      case 'water': return FontAwesomeIcons.water;
      case 'snowflake': return FontAwesomeIcons.snowflake;
      case 'smog': return FontAwesomeIcons.smog;
      case 'wind': return FontAwesomeIcons.wind;
      case 'cloud': return FontAwesomeIcons.cloud;
      case 'cloud-hail': return FontAwesomeIcons.cloudShowersHeavy;
      case 'bug': return FontAwesomeIcons.bug;
      case 'cloud-rain': return FontAwesomeIcons.cloudRain;
      default: return FontAwesomeIcons.triangleExclamation;
    }
  }
}