import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:go_router/go_router.dart';
import '../../widgets/disaster_category_card.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Content'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.graduationCap,
                    color: Colors.blue.shade700,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learn About Natural Disasters',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Discover the science behind natural disasters and learn how to stay safe.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Featured Content
            Text(
              'Featured Topics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Disaster Categories Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                DisasterCategoryCard(
                  title: 'Earthquakes',
                  icon: FontAwesomeIcons.houseChimneyCrack,
                  color: Colors.brown.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Earthquake content coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                DisasterCategoryCard(
                  title: 'Floods',
                  icon: FontAwesomeIcons.houseFloodWater,
                  color: Colors.blue.shade700,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Flood content coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                DisasterCategoryCard(
                  title: 'Wildfires',
                  icon: FontAwesomeIcons.fire,
                  color: Colors.red.shade700,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Wildfire content coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                DisasterCategoryCard(
                  title: 'Hurricanes',
                  icon: FontAwesomeIcons.hurricane,
                  color: Colors.indigo.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hurricane content coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                DisasterCategoryCard(
                  title: 'Tornadoes',
                  icon: FontAwesomeIcons.tornado,
                  color: Colors.grey.shade700,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tornado content coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                DisasterCategoryCard(
                  title: 'Winter Storms',
                  icon: FontAwesomeIcons.snowflake,
                  color: Colors.lightBlue.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Winter storm content coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Learning Objectives
            Text(
              'What You\'ll Learn',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            ...['How natural disasters form',
                'Warning signs to watch for',
                'Historical examples and case studies',
                'Scientific explanations made simple',
                'Prevention and mitigation strategies'].map((objective) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.solidCircleCheck,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        objective,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }
}