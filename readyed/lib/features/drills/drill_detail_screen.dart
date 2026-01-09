import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../services/auth_service.dart';

class DrillDetailScreen extends StatefulWidget {
  final String drillType;

  const DrillDetailScreen({super.key, required this.drillType});

  @override
  State<DrillDetailScreen> createState() => _DrillDetailScreenState();
}

class _DrillDetailScreenState extends State<DrillDetailScreen> {
  bool isCompleted = false;
  bool? wasCorrect;
  String feedbackMessage = '';
  late Map<String, dynamic> _selectedScenario;
  late String _drillTitle;

  @override
  void initState() {
    super.initState();
    _loadNewScenario();
  }

  void _loadNewScenario() {
    setState(() {
      final drillData = _getDrillData(widget.drillType);
      final scenarios = drillData['scenarios'] as List<Map<String, dynamic>>;
      _drillTitle = drillData['title'];
      _selectedScenario = scenarios[Random().nextInt(scenarios.length)];
      isCompleted = false;
      wasCorrect = null;
      feedbackMessage = '';
    });
  }

  void _restartScenario() {
    setState(() {
      isCompleted = false;
      wasCorrect = null;
      feedbackMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survival Scenario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (isCompleted)
            IconButton(
              icon: const Icon(FontAwesomeIcons.rotate),
              onPressed: _loadNewScenario,
              tooltip: 'New Scenario',
            ),
        ],
      ),
      body: isCompleted 
          ? _buildCompletionScreen() 
          : _buildScenarioScreen(),
    );
  }

  Widget _buildScenarioScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scenario Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        shape: BoxShape.circle,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.eye,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'The Situation',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedScenario['scenario'],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    height: 1.4,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text(
            'What would you do?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Choices
          ...(_selectedScenario['choices'] as List<Map<String, dynamic>>).map((choice) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () => _handleChoice(choice),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.circle,
                          color: Colors.grey.shade400,
                          size: 16,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            choice['text'],
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, 
                             size: 16, 
                             color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final color = wasCorrect! ? Colors.green : Colors.red;
    final icon = wasCorrect! ? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.circleXmark;
    final title = wasCorrect! ? 'You Survived!' : 'Scenario Failed';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              icon,
              color: color,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (wasCorrect!) ...[
            const SizedBox(height: 8),
            Text(
              '+20 Points',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  feedbackMessage,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          if (!wasCorrect!)
            ElevatedButton.icon(
              onPressed: _restartScenario,
              icon: const FaIcon(FontAwesomeIcons.rotate),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _loadNewScenario,
              icon: const FaIcon(FontAwesomeIcons.dice),
              label: const Text('New Scenario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const FaIcon(FontAwesomeIcons.house),
              label: const Text('Back to Menu'),
            ),
        ],
      ),
    );
  }

  void _handleChoice(Map<String, dynamic> choice) {
    setState(() {
      isCompleted = true;
      wasCorrect = choice['isCorrect'];
      feedbackMessage = choice['feedback'];
    });

    if (wasCorrect!) {
      Provider.of<AuthService>(context, listen: false).updateScore(20);
    }
  }

  Map<String, dynamic> _getDrillData(String type) {
    final data = {
      'earthquake': {
        'title': 'Earthquake',
        'scenarios': [
          {
            'scenario': 'It\'s 2:00 AM. You are fast asleep in your bed on the second floor. Suddenly, the room starts shaking violently. Books fall off the shelf, and you hear glass breaking. What is your immediate reaction?',
            'choices': [
              {
                'text': 'Run outside immediately',
                'isCorrect': false,
                'feedback': 'Incorrect. Running during strong shaking is extremely dangerous. The ground motion can cause you to fall, and you risk being hit by falling debris, glass, or collapsing walls. Most injuries happen when people try to move.'
              },
              {
                'text': 'Stand in the doorway',
                'isCorrect': false,
                'feedback': 'Incorrect. In modern homes, doorways are no stronger than any other part of the house. You are also exposed to falling objects and swinging doors.'
              },
              {
                'text': 'Stay in bed, cover head with pillow',
                'isCorrect': true,
                'feedback': 'Correct! If you are in bed, stay there. Hold on and protect your head with a pillow. You are less likely to be injured by falling objects than if you try to move.'
              }
            ]
          },
          {
            'scenario': 'You are driving on a highway when you feel the steering wheel shaking violently. You realize it is an earthquake.',
            'choices': [
              {
                'text': 'Stop immediately, right where you are',
                'isCorrect': false,
                'feedback': 'Incorrect. Stopping suddenly in the middle of the road or under a bridge/overpass is dangerous.'
              },
              {
                'text': 'Pull over to the side, away from bridges/poles, and stay in the car',
                'isCorrect': true,
                'feedback': 'Correct! Pull over safely to a clear area. Stay inside the car until the shaking stops; the car provides protection from falling debris.'
              },
              {
                'text': 'Drive faster to get home',
                'isCorrect': false,
                'feedback': 'Incorrect. Driving during an earthquake is dangerous due to potential road damage and loss of vehicle control.'
              }
            ]
          }
        ]
      },
      'fire': {
        'title': 'Fire',
        'scenarios': [
          {
            'scenario': 'You are in a crowded movie theater when the fire alarm goes off and you smell smoke. The main exit is packed with panicking people.',
            'choices': [
              {
                'text': 'Push through the crowd to the main exit',
                'isCorrect': false,
                'feedback': 'Incorrect. You risk being crushed or trapped in the bottleneck. Panic causes delays and injuries.'
              },
              {
                'text': 'Look for a secondary exit or kitchen staff door',
                'isCorrect': true,
                'feedback': 'Correct! Commercial buildings always have multiple exits. Finding a less crowded alternative path is the safest choice.'
              },
              {
                'text': 'Hide under the seats',
                'isCorrect': false,
                'feedback': 'Incorrect. Smoke rises, but heat and toxic gases can still reach you. You need to evacuate, not hide.'
              }
            ]
          },
          {
            'scenario': 'You are cooking in the kitchen and a pan of oil catches fire. The flames are small but growing.',
            'choices': [
              {
                'text': 'Pour water on it',
                'isCorrect': false,
                'feedback': 'Incorrect! Water will make a grease fire explode violently.'
              },
              {
                'text': 'Cover it with a metal lid',
                'isCorrect': true,
                'feedback': 'Correct! Sliding a lid over the pan cuts off the oxygen and smothers the fire.'
              },
              {
                'text': 'Carry the pan outside',
                'isCorrect': false,
                'feedback': 'Incorrect. Moving a burning pan is extremely dangerous; you could spill burning oil on yourself or spread the fire.'
              }
            ]
          }
        ]
      },
      'flood': {
        'title': 'Flood',
        'scenarios': [
          {
            'scenario': 'You are driving home during a heavy storm. You come across a dip in the road that is completely flooded with moving water. You are in a hurry.',
            'choices': [
              {
                'text': 'Drive through it quickly',
                'isCorrect': false,
                'feedback': 'Incorrect. "Turn Around, Don\'t Drown." Just 12 inches of moving water can carry away a small car.'
              },
              {
                'text': 'Get out and walk through it',
                'isCorrect': false,
                'feedback': 'Incorrect. 6 inches of moving water can knock you off your feet. The water may also be contaminated or hide hazards.'
              },
              {
                'text': 'Turn around and find another route',
                'isCorrect': true,
                'feedback': 'Correct! Never attempt to cross a flooded road in a vehicle or on foot. The depth and speed of water are deceptive.'
              }
            ]
          },
          {
            'scenario': 'You are trapped in your car and water is rising rapidly around it. The water pressure is preventing you from opening the door.',
            'choices': [
              {
                'text': 'Wait for the water to fill the car to equalize pressure',
                'isCorrect': false,
                'feedback': 'Incorrect. This is a last resort and very dangerous as you might run out of air.'
              },
              {
                'text': 'Break the side window and climb out',
                'isCorrect': true,
                'feedback': 'Correct! Use a heavy object or a window breaker to shatter a side window (not the windshield) and escape immediately.'
              },
              {
                'text': 'Call 112 and wait',
                'isCorrect': false,
                'feedback': 'Incorrect. In a rapidly sinking vehicle, you must escape first, then call for help.'
              }
            ]
          }
        ]
      },
      'hurricane': {
        'title': 'Hurricane',
        'scenarios': [
          {
            'scenario': 'A major hurricane has just made landfall. The wind is howling outside, and suddenly your living room window shatters from debris.',
            'choices': [
              {
                'text': 'Run to the window to tape it up',
                'isCorrect': false,
                'feedback': 'Incorrect. Approaching a broken window during high winds exposes you to glass shards and flying debris.'
              },
              {
                'text': 'Go to a small interior room without windows',
                'isCorrect': true,
                'feedback': 'Correct! Put as many walls between you and the outside as possible. A closet, hallway, or bathroom is safest.'
              },
              {
                'text': 'Run outside to the car',
                'isCorrect': false,
                'feedback': 'Incorrect. Going outside during a hurricane is extremely dangerous due to flying debris and high winds.'
              }
            ]
          },
          {
            'scenario': 'The wind has suddenly stopped and the sun is coming out. You think the storm is over.',
            'choices': [
              {
                'text': 'Go outside to inspect damage',
                'isCorrect': false,
                'feedback': 'Incorrect. You might be in the "eye" of the storm. The winds will return violently from the opposite direction soon.'
              },
              {
                'text': 'Stay inside and wait for official all-clear',
                'isCorrect': true,
                'feedback': 'Correct! The calm eye is deceptive. Stay sheltered until authorities confirm the storm has passed.'
              },
              {
                'text': 'Open windows to let air in',
                'isCorrect': false,
                'feedback': 'Incorrect. Opening windows can pressurize the house and cause the roof to blow off when winds return.'
              }
            ]
          }
        ]
      },
    };

    return data[type] ?? {
      'title': 'Scenario',
      'scenarios': [
        {
          'scenario': 'Scenario not found.',
          'choices': []
        }
      ]
    };
  }
}