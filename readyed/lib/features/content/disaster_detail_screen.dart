import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:readyed/features/quiz/quiz_screen.dart';

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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuizScreen(disasterType: disasterType),
                    ),
                  );
                },
                icon: const FaIcon(FontAwesomeIcons.brain),
                label: const Text('Take Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
        'subtitle': 'When water goes where it\'s shouldn\'t',
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
      'cyclone': {
        'title': 'Cyclones',
        'subtitle': 'Powerful spinning storms',
        'icon': FontAwesomeIcons.hurricane,
        'color': const Color(0xFF1565C0),
        'description': 'A cyclone is a large air mass that rotates around a strong center of low atmospheric pressure. It brings heavy rains and strong winds that can cause damage to houses, trees, and power lines.',
        'formation': 'Cyclones form over warm ocean waters. The warm, moist air rises and creates an area of low pressure. Cooler air rushes in to fill the gap, creating a spinning storm system.',
        'warning': 'Weather forecasts will predict cyclones days in advance. Look for dark clouds, increasing wind speed, and heavy ocean swells near coastal areas.',
        'facts': [
          'Cyclones spin counter-clockwise in the Northern Hemisphere',
          'The center of a cyclone is called the "eye" and is usually calm',
          'Cyclones can be hundreds of kilometers wide',
          'They are called hurricanes in the Atlantic and typhoons in the Pacific'
        ],
      },
      'drought': {
        'title': 'Droughts',
        'subtitle': 'When the rain stays away',
        'icon': FontAwesomeIcons.sun,
        'color': const Color(0xFFFF8F00),
        'description': 'A drought is a long period where there is not enough rain. It dries up rivers, lakes, and soil, making it hard for plants to grow and for people and animals to find water.',
        'formation': 'Droughts happen when normal rain patterns change, often due to shifts in wind or ocean currents. High temperatures can also make water evaporate faster from the ground.',
        'warning': 'Water levels in rivers and lakes drop, soil becomes cracked and dry, crops start to wither, and there are restrictions on water usage.',
        'facts': [
          'A drought can last for months or even years',
          'Deserts are regions that are in a permanent state of drought',
          'Droughts can lead to wildfires due to dry vegetation',
          'Conserving water is the best way to prepare for a drought'
        ],
      },
      'landslide': {
        'title': 'Landslides',
        'subtitle': 'When the ground slides down',
        'icon': FontAwesomeIcons.mountain,
        'color': const Color(0xFF795548),
        'description': 'A landslide is the movement of rock, earth, or debris down a slope. It can happen slowly or very quickly, destroying everything in its path like a flowing river of mud.',
        'formation': 'Landslides are often caused by heavy rain, earthquakes, or volcanoes that make the ground unstable. Cutting down trees on hillsides can also make landslides more likely.',
        'warning': 'New cracks in the ground or buildings, fences or trees tilting, and rumbling sounds coming from the earth are signs a landslide might happen.',
        'facts': [
          'Landslides can move at speeds of up to 200 miles per hour',
          'Gravity is the primary force behind landslides',
          'Planting trees on slopes helps hold the soil together',
          'Landslides can block rivers and create temporary lakes'
        ],
      },
      'heatwave': {
        'title': 'Heat Waves',
        'subtitle': 'Dangerously hot days',
        'icon': FontAwesomeIcons.temperatureHigh,
        'color': const Color(0xFFE65100),
        'description': 'A heat wave is a prolonged period of excessively hot weather, which may be accompanied by high humidity. It can be dangerous for health, causing heat stroke and dehydration.',
        'formation': 'Heat waves form when high atmospheric pressure moves into an area and pushes air downward. This prevents hot air from rising and traps it near the ground like a lid on a pot.',
        'warning': 'Weather forecasts predict high temperatures. Physical signs include excessive sweating, dizziness, and feeling very tired.',
        'facts': [
          'Heat waves are one of the deadliest weather-related hazards',
          'Cities are often hotter than surrounding rural areas (Urban Heat Island effect)',
          'Drinking plenty of water is crucial during a heat wave',
          'Pets also need extra water and shade during hot weather'
        ],
      },
      'thunderstorm': {
        'title': 'Thunderstorms',
        'subtitle': 'Lightning and loud crashes',
        'icon': FontAwesomeIcons.cloudBolt,
        'color': const Color(0xFF424242),
        'description': 'A thunderstorm is a rain shower during which you hear thunder. Since thunder comes from lightning, all thunderstorms have lightning.',
        'formation': 'Thunderstorms form when warm, moist air rises rapidly into colder air. The moisture condenses into rain and ice, creating an electrical charge that results in lightning.',
        'warning': 'Dark, towering clouds, sudden strong winds, flashes of lightning, and the sound of thunder are clear warnings.',
        'facts': [
          'Lightning is hotter than the surface of the sun!',
          'You can estimate how far away a storm is by counting seconds between lightning and thunder (5 seconds = 1 mile)',
          'Thunderstorms can produce tornadoes and hail',
          'Rubber tires on cars help protect you from lightning strikes'
        ],
      },
      'forest_fire': {
        'title': 'Forest Fires',
        'subtitle': 'Uncontrolled nature fires',
        'icon': FontAwesomeIcons.fire,
        'color': const Color(0xFFD32F2F),
        'description': 'A forest fire, or wildfire, is an unplanned fire that burns in a natural area such as a forest, grassland, or prairie. It spreads quickly and can be hard to put out.',
        'formation': 'Fires need three things: fuel (wood/grass), oxygen (air), and heat (lightning/sun/human activity). Dry weather and strong winds make fires spread faster.',
        'warning': 'Smell of smoke, hazy sky, and red glow at night. Fire danger ratings are often broadcasted in dry seasons.',
        'facts': [
          'Some plants actually need fire to release their seeds',
          'Wildfires can create their own weather systems',
          '90% of wildfires are started by humans',
          'Smoke from wildfires can travel thousands of miles'
        ],
      },
      'tsunami': {
        'title': 'Tsunamis',
        'subtitle': 'Giant ocean waves',
        'icon': FontAwesomeIcons.water,
        'color': const Color(0xFF0288D1),
        'description': 'A tsunami is a series of huge ocean waves caused by a sudden displacement of water. It is not just a single wave but a "wave train" that can flood coastal areas.',
        'formation': 'Most tsunamis are caused by underwater earthquakes. Volcanic eruptions, landslides into the ocean, or meteorite impacts can also create them.',
        'warning': 'A strong earthquake near the coast, a loud roaring sound from the ocean, or the water suddenly receding from the beach are urgent warning signs.',
        'facts': [
          'Tsunami waves can travel as fast as a jet plane (500 mph)',
          'The first wave is not always the biggest',
          '"Tsunami" is a Japanese word meaning "harbor wave"',
          'Deep ocean tsunamis might be only a few feet high'
        ],
      },
      'avalanche': {
        'title': 'Avalanches',
        'subtitle': 'Snow sliding down',
        'icon': FontAwesomeIcons.snowflake,
        'color': const Color(0xFF81C784),
        'description': 'An avalanche is a rapid flow of snow down a sloping surface. It can be triggered by natural forces or human activity and can bury everything in its path.',
        'formation': 'Avalanches happen when a layer of snow collapses and slides. This can be due to new heavy snow, wind moving snow around, or rapid temperature changes.',
        'warning': 'Cracks in the snow surface, a "whump" sound, and recent heavy snowfall are warning signs. Avalanche forecasts are essential for skiers.',
        'facts': [
          'Avalanches can reach speeds of 80 miles per hour',
          'Most avalanches happen on slopes between 30 and 45 degrees',
          'Noise doesn\'t usually trigger avalanches, but the weight of a person can',
          'An avalanche airbag can help keep you on top of the snow'
        ],
      },
      'air_pollution': {
        'title': 'Air Pollution',
        'subtitle': 'Dirty air we breathe',
        'icon': FontAwesomeIcons.smog,
        'color': const Color(0xFF757575),
        'description': 'Air pollution is the presence of harmful substances in the atmosphere. It can cause health problems like asthma and damage the environment.',
        'formation': 'Pollution comes from vehicle exhaust, factories, burning of crops (stubble burning), and dust. Weather conditions like little wind can trap pollution near the ground.',
        'warning': 'Hazy sky, poor visibility, and difficulty breathing. Air Quality Index (AQI) reports warn about pollution levels.',
        'facts': [
          'Air pollution kills millions of people every year',
          'Trees are natural air filters',
          'Indoor air can sometimes be more polluted than outdoor air',
          'Reducing car use helps improve air quality'
        ],
      },
      'dust_storm': {
        'title': 'Dust Storms',
        'subtitle': 'Walls of wind and dust',
        'icon': FontAwesomeIcons.wind,
        'color': const Color(0xFFA1887F),
        'description': 'A dust storm creates a wall of dust and debris blown by strong winds. It reduces visibility to near zero and can cause breathing problems.',
        'formation': 'Dust storms happen in dry areas where loose soil and sand are picked up by strong winds, often ahead of a thunderstorm.',
        'warning': 'A rapidly approaching dark wall of cloud near the ground and increasing wind speeds.',
        'facts': [
          'Dust storms on Mars can cover the entire planet',
          'They can travel thousands of miles across oceans',
          'Dust storms are also called "haboobs"',
          'Covering your nose and mouth is crucial during a dust storm'
        ],
      },
      'fog': {
        'title': 'Dense Fog',
        'subtitle': 'Clouds on the ground',
        'icon': FontAwesomeIcons.cloud,
        'color': const Color(0xFF90A4AE),
        'description': 'Fog is basically a cloud that touches the ground. Dense fog makes it very hard to see, which is dangerous for driving and travel.',
        'formation': 'Fog forms when water vapor in the air condenses into tiny liquid water droplets. This usually happens when the air cools down or when moisture is added to the air.',
        'warning': 'Reduced visibility is the main sign. Weather forecasts will issue fog warnings for drivers.',
        'facts': [
          'Fog is common in valleys and near water bodies',
          'The foggiest place in the world is the Grand Banks off Newfoundland',
          'Fog can actually provide water for plants in dry areas',
          'Using low-beam headlights is safer when driving in fog'
        ],
      },
      'hailstorm': {
        'title': 'Hailstorms',
        'subtitle': 'Balls of ice from the sky',
        'icon': FontAwesomeIcons.cloudShowersHeavy,
        'color': const Color(0xFF546E7A),
        'description': 'A hailstorm is a thunderstorm that drops balls of ice called hail. Hail can damage cars, break windows, and destroy crops.',
        'formation': 'Hail forms in strong thunderstorm clouds where updrafts carry water droplets high up where they freeze. They grow larger until they become too heavy and fall.',
        'warning': 'Greenish sky, large clouds, and loud thumping noises on roofs are signs of approaching hail.',
        'facts': [
          'The largest hailstone recorded was 8 inches across!',
          'Hailstones are made of layers of ice, like an onion',
          'Hail usually falls for only a few minutes',
          'Crop damage from hail costs billions of dollars each year'
        ],
      },
      'flash_flood': {
        'title': 'Flash Floods',
        'subtitle': 'Sudden, rushing water',
        'icon': FontAwesomeIcons.houseFloodWaterCircleArrowRight,
        'color': const Color(0xFF1976D2),
        'description': 'A flash flood is a rapid flooding of low-lying areas. It happens very quickly, often within minutes of heavy rain, giving people little time to escape.',
        'formation': 'Caused by intense rainfall, dam breaks, or sudden release of water. Concrete in cities prevents water absorption, leading to flash floods.',
        'warning': 'Sudden rise in water levels, muddy water, and roaring sound from upstream.',
        'facts': [
          'Flash floods can roll boulders and tear out trees',
          'Never drive through flooded roads - "Turn Around, Don\'t Drown"',
          'They are the #1 weather-related killer in the US',
          'Flash floods can happen even if it\'s not raining where you are'
        ],
      },
      'locust_attack': {
        'title': 'Locust Attacks',
        'subtitle': 'Swarms of hungry insects',
        'icon': FontAwesomeIcons.bug,
        'color': const Color(0xFF689F38),
        'description': 'A locust attack involves massive swarms of insects that eat crops and vegetation, threatening food supply and livelihoods.',
        'formation': 'Locusts change from solitary to social behavior when their population increases due to good breeding conditions (like rain in deserts). They then form swarms.',
        'warning': 'News reports from agricultural departments and sightings of large groups of insects.',
        'facts': [
          'A desert locust swarm can be 460 square miles in size',
          'A small swarm eats the same amount of food in one day as 35,000 people',
          'They can fly up to 90 miles a day',
          'Locusts are mentioned in ancient history as plagues'
        ],
      },
      'coastal_erosion': {
        'title': 'Coastal Erosion',
        'subtitle': 'The sea taking the land',
        'icon': FontAwesomeIcons.water,
        'color': const Color(0xFF0097A7),
        'description': 'Coastal erosion is the wearing away of land and removal of beach or dune sediments by wave action, tidal currents, wave currents, drainage or high winds.',
        'formation': 'Caused by the energy of waves and currents. Rising sea levels and frequent storms accelerate this process.',
        'warning': 'Visible loss of beach, collapsing cliffs, and structures near the sea becoming unstable.',
        'facts': [
          'Climate change is making coastal erosion worse',
          'Mangroves help protect coastlines from erosion',
          'Many ancient cities have been lost to the sea',
          'Building sea walls is one way to fight erosion'
        ],
      },
      'monsoon_flooding': {
        'title': 'Monsoon Flooding',
        'subtitle': 'Seasonal heavy rains',
        'icon': FontAwesomeIcons.cloudRain,
        'color': const Color(0xFF00796B),
        'description': 'Monsoon flooding occurs during the rainy season when rivers overflow due to continuous heavy rainfall.',
        'formation': 'The monsoon is a seasonal shift in wind direction that brings moisture-laden air from the ocean, resulting in long periods of rain.',
        'warning': 'Weather forecasts predicting the monsoon onset and heavy rainfall alerts.',
        'facts': [
          'Monsoons are essential for agriculture in many countries',
          'They can bring relief from summer heat',
          'Proper drainage systems reduce monsoon flooding',
          'Some areas receive meters of rain during the monsoon'
        ],
      },
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