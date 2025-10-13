import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/feature_card.dart';
import '../../widgets/disaster_category_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with animated welcome text
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.shieldHeart,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'ReadyEd',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Stay Safe, Stay Prepared!',
                          textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white70,
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Learn about natural disasters and practice emergency procedures in a fun, interactive way.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Quick Access Features
              Text(
                'Quick Access',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FeatureCard(
                      title: 'Learn',
                      subtitle: 'Educational Content',
                      icon: FontAwesomeIcons.graduationCap,
                      color: Colors.blue,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Educational content coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      title: 'Practice',
                      subtitle: 'Virtual Drills',
                      icon: FontAwesomeIcons.userShield,
                      color: Colors.green,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Virtual drills available in Drills tab!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      title: 'Guidelines',
                      subtitle: 'Safety Tips',
                      icon: FontAwesomeIcons.listCheck,
                      color: Colors.orange,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Safety guidelines available in Disasters tab!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Disaster Categories
              Text(
                'Natural Disasters',
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
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  DisasterCategoryCard(
                    title: 'Earthquakes',
                    icon: FontAwesomeIcons.houseChimneyCrack,
                    color: Colors.brown,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Earthquake information available in Disasters tab!'),
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
                          content: Text('Flood information available in Disasters tab!'),
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
                          content: Text('Wildfire information available in Disasters tab!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  DisasterCategoryCard(
                    title: 'Hurricanes',
                    icon: FontAwesomeIcons.hurricane,
                    color: Colors.indigo,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hurricane information available in Disasters tab!'),
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
                          content: Text('Tornado information available in Disasters tab!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  DisasterCategoryCard(
                    title: 'Winter Storms',
                    icon: FontAwesomeIcons.snowflake,
                    color: Colors.lightBlue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Winter storm information available in Disasters tab!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Emergency Contact Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.phone,
                      color: Colors.red.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Contact',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          Text(
                            'In case of real emergency, call 911',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}