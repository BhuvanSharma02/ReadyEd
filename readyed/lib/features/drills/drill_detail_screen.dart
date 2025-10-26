import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class DrillDetailScreen extends StatefulWidget {
  final String drillType;

  const DrillDetailScreen({super.key, required this.drillType});

  @override
  State<DrillDetailScreen> createState() => _DrillDetailScreenState();
}

class _DrillDetailScreenState extends State<DrillDetailScreen> {
  int currentStep = 0;
  int score = 0;
  bool isCompleted = false;
  List<bool> stepCompletions = [];

  @override
  void initState() {
    super.initState();
    final drillData = _getDrillData(widget.drillType);
    stepCompletions = List.filled(drillData['steps'].length, false);
  }

  @override
  Widget build(BuildContext context) {
    final drillData = _getDrillData(widget.drillType);
    final steps = drillData['steps'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(
        title: Text('${drillData['title']} Drill'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isCompleted)
            IconButton(
              icon: const Icon(FontAwesomeIcons.rotate),
              onPressed: _restartDrill,
              tooltip: 'Restart Drill',
            ),
        ],
      ),
      body: isCompleted ? _buildCompletionScreen(drillData) : _buildDrillScreen(steps),
      bottomNavigationBar: !isCompleted ? _buildNavigationBar(steps) : null,
    );
  }

  Widget _buildDrillScreen(List<Map<String, dynamic>> steps) {
    final currentStepData = steps[currentStep];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          _buildProgressIndicator(steps.length),
          const SizedBox(height: 24),

          // Step content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: currentStepData['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: currentStepData['color'].withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: currentStepData['color'],
                        shape: BoxShape.circle,
                      ),
                      child: FaIcon(
                        currentStepData['icon'],
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step ${currentStep + 1}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: currentStepData['color'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currentStepData['title'],
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: currentStepData['color'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  currentStepData['description'],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (currentStepData['scenario'] != null) ...[
                  const SizedBox(height: 20),
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
                            Icon(FontAwesomeIcons.lightbulb, color: Colors.blue.shade700, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Scenario',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentStepData['scenario'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Interactive choices (if any)
          if (currentStepData['choices'] != null) ...[
            const SizedBox(height: 24),
            Text(
              'What should you do?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...(currentStepData['choices'] as List<Map<String, dynamic>>).asMap().entries.map((entry) {
              final index = entry.key;
              final choice = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: InkWell(
                    onTap: () => _handleChoice(choice, index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: choice['isCorrect'] ? Colors.green.shade100 : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, etc.
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: choice['isCorrect'] ? Colors.green.shade700 : Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              choice['text'],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],

          // Tips section
          if (currentStepData['tips'] != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.lightbulb, color: Colors.amber.shade700, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Pro Tips',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...(currentStepData['tips'] as List<String>).map((tip) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: Colors.amber.shade700)),
                          Expanded(
                            child: Text(
                              tip,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int totalSteps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${currentStep + 1} of $totalSteps',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (currentStep + 1) / totalSteps,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildNavigationBar(List<Map<String, dynamic>> steps) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: currentStep > 0 ? _previousStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('Previous'),
          ),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(currentStep == steps.length - 1 ? 'Complete' : 'Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(Map<String, dynamic> drillData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.trophy,
              color: Colors.green.shade700,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Drill Completed!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Great job! You\'ve successfully completed the ${drillData['title']} drill.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Score display
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Your Score',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$score / ${stepCompletions.length}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                Text(
                  _getScoreMessage(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _restartDrill,
                  icon: const FaIcon(FontAwesomeIcons.rotate),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const FaIcon(FontAwesomeIcons.house),
                  label: const Text('Back Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleChoice(Map<String, dynamic> choice, int index) {
    if (choice['isCorrect']) {
      score++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Correct! ${choice['feedback']}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not quite. ${choice['feedback']}'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
    }
    stepCompletions[currentStep] = true;
    
    // Auto advance after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _nextStep();
    });
  }

  void _nextStep() {
    final drillData = _getDrillData(widget.drillType);
    final steps = drillData['steps'] as List<Map<String, dynamic>>;
    
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      setState(() {
        isCompleted = true;
      });
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void _restartDrill() {
    setState(() {
      currentStep = 0;
      score = 0;
      isCompleted = false;
      final drillData = _getDrillData(widget.drillType);
      stepCompletions = List.filled(drillData['steps'].length, false);
    });
  }

  String _getScoreMessage() {
    final percentage = (score / stepCompletions.length * 100).round();
    if (percentage >= 80) return 'Excellent work!';
    if (percentage >= 60) return 'Good job!';
    return 'Keep practicing!';
  }

  Map<String, dynamic> _getDrillData(String type) {
    final data = {
      'earthquake': {
        'title': 'Earthquake',
        'steps': [
          {
            'title': 'Drop, Cover, and Hold On',
            'description': 'The most important earthquake safety rule is DROP, COVER, and HOLD ON immediately when you feel shaking.',
            'scenario': 'You\'re in your classroom when the ground starts shaking. What do you do first?',
            'icon': FontAwesomeIcons.handHolding,
            'color': Colors.red,
            'choices': [
              {
                'text': 'Run outside immediately',
                'isCorrect': false,
                'feedback': 'Running during shaking can cause you to fall and get hurt.'
              },
              {
                'text': 'Drop to hands and knees, take cover under a desk',
                'isCorrect': true,
                'feedback': 'Perfect! This protects you from falling objects.'
              },
              {
                'text': 'Stand in a doorway',
                'isCorrect': false,
                'feedback': 'Doorways are not safer than other parts of the building.'
              }
            ],
            'tips': [
              'Get under a desk or table if available',
              'If no table, cover your head and neck with your arms',
              'Don\'t run during shaking - you might fall'
            ]
          },
          {
            'title': 'Stay Safe During Shaking',
            'description': 'While the ground is shaking, stay where you are and protect yourself until the shaking stops.',
            'icon': FontAwesomeIcons.shield,
            'color': Colors.orange,
            'tips': [
              'Hold on to your shelter and protect your head',
              'Stay away from windows and heavy objects',
              'Don\'t try to move to another room'
            ]
          },
          {
            'title': 'After the Shaking Stops',
            'description': 'Once the earthquake stops, carefully check for injuries and hazards before moving.',
            'icon': FontAwesomeIcons.eyeSlash,
            'color': Colors.blue,
            'scenario': 'The shaking has stopped. What should you check for first?',
            'choices': [
              {
                'text': 'Check if you or others are injured',
                'isCorrect': true,
                'feedback': 'Correct! Safety of people comes first.'
              },
              {
                'text': 'Check your phone for messages',
                'isCorrect': false,
                'feedback': 'People\'s safety is more important than messages.'
              }
            ],
            'tips': [
              'Look for injuries and provide first aid if needed',
              'Check for hazards like gas leaks or electrical damage',
              'Be prepared for aftershocks'
            ]
          }
        ]
      },
      // Add more drill types as needed...
    };

    return data[type] ?? {
      'title': 'Emergency',
      'steps': [
        {
          'title': 'Stay Calm',
          'description': 'The first step in any emergency is to stay calm and think clearly.',
          'icon': FontAwesomeIcons.heart,
          'color': Colors.blue,
        }
      ]
    };
  }
}