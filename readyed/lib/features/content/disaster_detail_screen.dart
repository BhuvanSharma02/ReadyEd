import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:go_router/go_router.dart';

class DisasterDetailScreen extends StatelessWidget {
  final String disasterType;

  const DisasterDetailScreen({super.key, required this.disasterType});

  @override
  Widget build(BuildContext context) {
    final disasterData = _getDisasterData(disasterType);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(disasterData['title']),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.userShield),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Drill practice coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Practice Drill',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    disasterData['color'],
                    disasterData['color'].withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      disasterData['icon'],
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          disasterData['title'],
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          disasterData['subtitle'],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // What is it section
            _buildSection(
              context,
              'What is a ${disasterData['title']}?',
              disasterData['description'],
              FontAwesomeIcons.question,
              Colors.blue,
            ),

            // How it forms
            _buildSection(
              context,
              'How do ${disasterData['title']}s Form?',
              disasterData['formation'],
              FontAwesomeIcons.gears,
              Colors.orange,
            ),

            // Warning signs
            _buildSection(
              context,
              'Warning Signs',
              disasterData['warning'],
              FontAwesomeIcons.triangleExclamation,
              Colors.red,
            ),

            // Fun facts
            _buildFactsSection(context, disasterData['facts']),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Drill practice coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const FaIcon(FontAwesomeIcons.userShield),
                    label: const Text('Practice Drill'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Safety guidelines coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const FaIcon(FontAwesomeIcons.listCheck),
                    label: const Text('Safety Guidelines'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, 
                      IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FaIcon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                softWrap: true,
                // overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFactsSection(BuildContext context, List<String> facts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const FaIcon(FontAwesomeIcons.lightbulb, 
                               color: Colors.purple, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Did You Know?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...facts.map((fact) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FaIcon(FontAwesomeIcons.star, 
                           color: Colors.purple, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fact,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Map<String, dynamic> _getDisasterData(String type) {
    final data = {
      'earthquake': {
        'title': 'Earthquakes',
        'subtitle': 'When the Earth shakes',
        'icon': FontAwesomeIcons.houseChimneyCrack,
        'color': Colors.brown.shade600,
        'description': 'An earthquake happens when pieces of the Earth\'s crust suddenly move and shake the ground. It\'s like the Earth is having a big hiccup! The movement can be small and barely felt, or big enough to knock down buildings.',
        'formation': 'The Earth\'s surface is made of huge pieces called tectonic plates that slowly move around. When these plates get stuck and then suddenly break free, they create earthquake waves that travel through the ground.',
        'warning': 'Animals may act strangely, small cracks might appear in walls, and sometimes there are smaller earthquakes called foreshocks before a big one. However, earthquakes often happen without warning.',
        'facts': [
          'Earthquakes happen about 50,000 times per year worldwide!',
          'The strongest earthquake ever recorded was magnitude 9.5 in Chile in 1960',
          'Most earthquakes happen along the edges of tectonic plates',
          'Scientists use special machines called seismographs to measure earthquakes'
        ],
      },
      'flood': {
        'title': 'Floods',
        'subtitle': 'When water goes where it shouldn\'t',
        'icon': FontAwesomeIcons.houseFloodWater,
        'color': Colors.blue.shade700,
        'description': 'A flood happens when water covers land that is usually dry. It\'s like a bathtub overflowing, but much bigger! Floods can happen near rivers, lakes, oceans, or even in cities when it rains too much.',
        'formation': 'Floods can form from heavy rain, melting snow, broken dams, or when rivers and lakes overflow their banks. Sometimes hurricanes bring so much rain that the ground can\'t soak it all up.',
        'warning': 'Dark clouds and heavy rain, rising water levels in rivers and streams, emergency flood warnings on TV or radio, and water starting to cover roads or low areas.',
        'facts': [
          'Floods are the most common natural disaster in the United States',
          'Just 6 inches of fast-moving water can knock you down',
          'One inch of rain over one square mile equals about 17.4 million gallons of water!',
          'Flash floods can happen in just a few minutes'
        ],
      },
      // Add more disaster types as needed...
    };

    return data[type] ?? {
      'title': 'Natural Disaster',
      'subtitle': 'Learn about nature\'s power',
      'icon': FontAwesomeIcons.triangleExclamation,
      'color': Colors.grey,
      'description': 'This natural disaster is a powerful force of nature that can affect communities.',
      'formation': 'Natural disasters form through various natural processes and conditions.',
      'warning': 'Warning signs vary depending on the type of disaster.',
      'facts': ['Natural disasters are part of Earth\'s natural processes'],
    };
  }
}