import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:go_router/go_router.dart';
import '../../widgets/disaster_category_card.dart';
import 'drill_detail_screen.dart';

class DrillsScreen extends StatelessWidget {
  const DrillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survival Scenarios'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.brain, // Changed icon to brain/decision making
                    color: Colors.green.shade700,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test Your Decision Making',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Face realistic emergency situations and make the right choices to survive.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.circleInfo,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'How It Works',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. Choose a scenario\n2. Read the situation\n3. Make a critical decision\n4. See if you survived and learn why',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Categories
            Text(
              'Choose a Scenario',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                DisasterCategoryCard(
                  title: 'Earthquake',
                  icon: FontAwesomeIcons.houseChimneyCrack,
                  color: Colors.brown.shade600,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DrillDetailScreen(drillType: 'earthquake'),
                      ),
                    );
                  },
                ),
                DisasterCategoryCard(
                  title: 'Fire',
                  icon: FontAwesomeIcons.fire,
                  color: Colors.red.shade600,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DrillDetailScreen(drillType: 'fire'),
                      ),
                    );
                  },
                ),
                DisasterCategoryCard(
                  title: 'Flood',
                  icon: FontAwesomeIcons.houseFloodWater,
                  color: Colors.blue.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DrillDetailScreen(drillType: 'flood'),
                      ),
                    );
                  },
                ),
                DisasterCategoryCard(
                  title: 'Hurricane',
                  icon: FontAwesomeIcons.hurricane,
                  color: Colors.indigo.shade600,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DrillDetailScreen(drillType: 'hurricane'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Benefits section
            Text(
              'Why Scenario Training?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            ...['Improve critical thinking under pressure',
                'Learn to identify safe vs dangerous options',
                'Understand the "why" behind safety rules',
                'Prepare mentally for real emergencies'].map((benefit) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.lightbulb,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        benefit,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}