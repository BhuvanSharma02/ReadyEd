import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readyed/models/user_model.dart';
import 'package:readyed/services/auth_service.dart';
import 'package:confetti/confetti.dart';
import 'package:readyed/models/achievements.dart';
import 'package:readyed/widgets/achievement_notification.dart';
import 'package:readyed/models/achievement_model.dart' as achievement_model;


class QuizScreen extends StatefulWidget {
  final String disasterType;

  const QuizScreen({super.key, required this.disasterType});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _questionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswerLocked = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Dummy data for quizzes
  final Map<String, List<Map<String, Object>>> _quizzes = {
    'earthquake': [
      {
        'question': 'What is an earthquake?',
        'answers': [
          {'text': 'A big hiccup of the Earth', 'correct': true},
          {'text': 'A strong wind', 'correct': false},
          {'text': 'A heavy rain', 'correct': false},
          {'text': 'A large wave', 'correct': false},
        ],
      },
      {
        'question': 'What are the pieces of the Earth\'s surface called?',
        'answers': [
          {'text': 'Tectonic plates', 'correct': true},
          {'text': 'Continental shelves', 'correct': false},
          {'text': 'Oceanic crusts', 'correct': false},
          {'text': 'Mantles', 'correct': false},
        ],
      },
    ],
    'flood': [
      {
        'question': 'What is a flood?',
        'answers': [
          {'text': 'When water covers land that is usually dry', 'correct': true},
          {'text': 'When the ground shakes', 'correct': false},
          {'text': 'A very hot day', 'correct': false},
          {'text': 'A spinning column of air', 'correct': false},
        ],
      },
      {
        'question': 'How much fast-moving water can knock you down?',
        'answers': [
          {'text': '6 inches', 'correct': true},
          {'text': '1 foot', 'correct': false},
          {'text': '2 feet', 'correct': false},
          {'text': '1 inch', 'correct': false},
        ],
      },
    ],
    'cyclone': [
      {
        'question': 'What is a cyclone?',
        'answers': [
          {'text': 'A powerful spinning storm with strong winds', 'correct': true},
          {'text': 'A sudden shaking of the ground', 'correct': false},
          {'text': 'A giant ocean wave', 'correct': false},
          {'text': 'A period of no rain', 'correct': false},
        ],
      },
      {
        'question': 'Where do cyclones form?',
        'answers': [
          {'text': 'Over warm ocean waters', 'correct': true},
          {'text': 'Over dry land', 'correct': false},
          {'text': 'In the mountains', 'correct': false},
          {'text': 'In cold polar regions', 'correct': false},
        ],
      },
    ],
    'drought': [
      {
        'question': 'What happens during a drought?',
        'answers': [
          {'text': 'There is not enough rain for a long time', 'correct': true},
          {'text': 'It rains too much', 'correct': false},
          {'text': 'The wind blows very hard', 'correct': false},
          {'text': 'The ground shakes', 'correct': false},
        ],
      },
      {
        'question': 'What is important to do during a drought?',
        'answers': [
          {'text': 'Conserve water', 'correct': true},
          {'text': 'Plant more flowers', 'correct': false},
          {'text': 'Wash your car every day', 'correct': false},
          {'text': 'Leave the tap running', 'correct': false},
        ],
      },
    ],
    'landslide': [
      {
        'question': 'What causes a landslide?',
        'answers': [
          {'text': 'Heavy rain or earthquakes making ground unstable', 'correct': true},
          {'text': 'Strong winds blowing rocks uphill', 'correct': false},
          {'text': 'Too much sunlight', 'correct': false},
          {'text': 'Birds landing on trees', 'correct': false},
        ],
      },
      {
        'question': 'Where do landslides usually happen?',
        'answers': [
          {'text': 'On slopes or hillsides', 'correct': true},
          {'text': 'On flat plains', 'correct': false},
          {'text': 'In the middle of the ocean', 'correct': false},
          {'text': 'In the desert', 'correct': false},
        ],
      },
    ],
    'heatwave': [
      {
        'question': 'What is a heatwave?',
        'answers': [
          {'text': 'A long period of very hot weather', 'correct': true},
          {'text': 'A day with nice warm sun', 'correct': false},
          {'text': 'A sudden burst of cold air', 'correct': false},
          {'text': 'A warm ocean current', 'correct': false},
        ],
      },
      {
        'question': 'What should you drink plenty of during a heatwave?',
        'answers': [
          {'text': 'Water', 'correct': true},
          {'text': 'Hot coffee', 'correct': false},
          {'text': 'Salty soup', 'correct': false},
          {'text': 'Nothing', 'correct': false},
        ],
      },
    ],
    'thunderstorm': [
      {
        'question': 'What always comes with thunder?',
        'answers': [
          {'text': 'Lightning', 'correct': true},
          {'text': 'Snow', 'correct': false},
          {'text': 'Hail', 'correct': false},
          {'text': 'Rainbows', 'correct': false},
        ],
      },
      {
        'question': 'What causes the sound of thunder?',
        'answers': [
          {'text': 'Lightning heating the air rapidly', 'correct': true},
          {'text': 'Clouds bumping into each other', 'correct': false},
          {'text': 'Angels bowling', 'correct': false},
          {'text': 'The wind whistling', 'correct': false},
        ],
      },
    ],
    'forest_fire': [
      {
        'question': 'What makes forest fires spread faster?',
        'answers': [
          {'text': 'Dry weather and strong winds', 'correct': true},
          {'text': 'Rain and snow', 'correct': false},
          {'text': 'Green leaves', 'correct': false},
          {'text': 'Night time', 'correct': false},
        ],
      },
      {
        'question': 'How are most wildfires started?',
        'answers': [
          {'text': 'By humans', 'correct': true},
          {'text': 'By lightning', 'correct': false},
          {'text': 'By volcanoes', 'correct': false},
          {'text': 'By the sun', 'correct': false},
        ],
      },
    ],
    'tsunami': [
      {
        'question': 'What is a tsunami?',
        'answers': [
          {'text': 'A series of giant ocean waves', 'correct': true},
          {'text': 'A big storm at sea', 'correct': false},
          {'text': 'A high tide', 'correct': false},
          {'text': 'A waterfall in the ocean', 'correct': false},
        ],
      },
      {
        'question': 'What usually causes a tsunami?',
        'answers': [
          {'text': 'Underwater earthquakes', 'correct': true},
          {'text': 'Strong winds', 'correct': false},
          {'text': 'Ships moving too fast', 'correct': false},
          {'text': 'Whales jumping', 'correct': false},
        ],
      },
    ],
    'avalanche': [
      {
        'question': 'What is an avalanche?',
        'answers': [
          {'text': 'A rapid flow of snow down a slope', 'correct': true},
          {'text': 'A heavy snowfall', 'correct': false},
          {'text': 'Ice melting on a roof', 'correct': false},
          {'text': 'A snowstorm', 'correct': false},
        ],
      },
      {
        'question': 'What can trigger an avalanche?',
        'answers': [
          {'text': 'New heavy snow or loud noises', 'correct': true},
          {'text': 'Sunlight', 'correct': false},
          {'text': 'Cold temperatures', 'correct': false},
          {'text': 'Moonlight', 'correct': false},
        ],
      },
    ],
    'air_pollution': [
      {
        'question': 'What is air pollution?',
        'answers': [
          {'text': 'Harmful substances in the air', 'correct': true},
          {'text': 'Fog in the morning', 'correct': false},
          {'text': 'Clouds in the sky', 'correct': false},
          {'text': 'Wind blowing dust', 'correct': false},
        ],
      },
      {
        'question': 'What is a major cause of air pollution?',
        'answers': [
          {'text': 'Vehicle exhaust and factories', 'correct': true},
          {'text': 'Trees breathing', 'correct': false},
          {'text': 'Rain falling', 'correct': false},
          {'text': 'Rivers flowing', 'correct': false},
        ],
      },
    ],
    'dust_storm': [
      {
        'question': 'What happens in a dust storm?',
        'answers': [
          {'text': 'Strong winds blow dust and reduce visibility', 'correct': true},
          {'text': 'It rains mud', 'correct': false},
          {'text': 'The sky turns blue', 'correct': false},
          {'text': 'Trees grow faster', 'correct': false},
        ],
      },
      {
        'question': 'What should you cover during a dust storm?',
        'answers': [
          {'text': 'Nose and mouth', 'correct': true},
          {'text': 'Ears', 'correct': false},
          {'text': 'Hands', 'correct': false},
          {'text': 'Feet', 'correct': false},
        ],
      },
    ],
    'fog': [
      {
        'question': 'What is fog?',
        'answers': [
          {'text': 'A cloud that touches the ground', 'correct': true},
          {'text': 'Smoke from a fire', 'correct': false},
          {'text': 'Steam from a kettle', 'correct': false},
          {'text': 'Dust in the air', 'correct': false},
        ],
      },
      {
        'question': 'Why is fog dangerous?',
        'answers': [
          {'text': 'It makes it hard to see (low visibility)', 'correct': true},
          {'text': 'It is toxic', 'correct': false},
          {'text': 'It is very hot', 'correct': false},
          {'text': 'It causes floods', 'correct': false},
        ],
      },
    ],
    'hailstorm': [
      {
        'question': 'What falls from the sky during a hailstorm?',
        'answers': [
          {'text': 'Balls of ice', 'correct': true},
          {'text': 'Rocks', 'correct': false},
          {'text': 'Frogs', 'correct': false},
          {'text': 'Hot water', 'correct': false},
        ],
      },
      {
        'question': 'What can hail damage?',
        'answers': [
          {'text': 'Cars, windows, and crops', 'correct': true},
          {'text': 'Roads and bridges', 'correct': false},
          {'text': 'Underground pipes', 'correct': false},
          {'text': 'Fish in the ocean', 'correct': false},
        ],
      },
    ],
    'flash_flood': [
      {
        'question': 'How fast does a flash flood happen?',
        'answers': [
          {'text': 'Very quickly, often in minutes', 'correct': true},
          {'text': 'Slowly over weeks', 'correct': false},
          {'text': 'It takes a whole day', 'correct': false},
          {'text': 'It never happens quickly', 'correct': false},
        ],
      },
      {
        'question': 'What should you do if you see a flooded road?',
        'answers': [
          {'text': 'Turn Around, Don\'t Drown', 'correct': true},
          {'text': 'Drive through it fast', 'correct': false},
          {'text': 'Walk through it', 'correct': false},
          {'text': 'Swim in it', 'correct': false},
        ],
      },
    ],
    'locust_attack': [
      {
        'question': 'What do locust swarms eat?',
        'answers': [
          {'text': 'Crops and vegetation', 'correct': true},
          {'text': 'Other insects', 'correct': false},
          {'text': 'Dirt', 'correct': false},
          {'text': 'Water', 'correct': false},
        ],
      },
      {
        'question': 'Why are locust attacks a problem?',
        'answers': [
          {'text': 'They destroy food supplies', 'correct': true},
          {'text': 'They bite people', 'correct': false},
          {'text': 'They carry diseases', 'correct': false},
          {'text': 'They make too much noise', 'correct': false},
        ],
      },
    ],
    'coastal_erosion': [
      {
        'question': 'What causes coastal erosion?',
        'answers': [
          {'text': 'Waves and currents wearing away land', 'correct': true},
          {'text': 'Fish digging holes', 'correct': false},
          {'text': 'Boats parking on the beach', 'correct': false},
          {'text': 'Sunlight drying the sand', 'correct': false},
        ],
      },
      {
        'question': 'What helps protect coastlines from erosion?',
        'answers': [
          {'text': 'Mangroves and sea walls', 'correct': true},
          {'text': 'Building hotels', 'correct': false},
          {'text': 'Removing sand', 'correct': false},
          {'text': 'Swimming near the shore', 'correct': false},
        ],
      },
    ],
    'monsoon_flooding': [
      {
        'question': 'When does monsoon flooding usually happen?',
        'answers': [
          {'text': 'During the rainy season', 'correct': true},
          {'text': 'In the middle of winter', 'correct': false},
          {'text': 'During a drought', 'correct': false},
          {'text': 'Whenever it is sunny', 'correct': false},
        ],
      },
      {
        'question': 'What causes rivers to overflow during monsoons?',
        'answers': [
          {'text': 'Continuous heavy rainfall', 'correct': true},
          {'text': 'Melting glaciers only', 'correct': false},
          {'text': 'Strong winds', 'correct': false},
          {'text': 'High tides', 'correct': false},
        ],
      },
    ],
  };

  void _answerQuestion(bool isCorrect, int answerIndex) {
    if (_isAnswerLocked) return;

    setState(() {
      _selectedAnswerIndex = answerIndex;
      _isAnswerLocked = true;
    });

    if (isCorrect) {
      _score++;
    }

    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;

      final quizLength = _quizzes[widget.disasterType]?.length ?? 0;
      if (_questionIndex < quizLength - 1) {
        setState(() {
          _questionIndex++;
          _selectedAnswerIndex = null;
          _isAnswerLocked = false;
          _animationController.reset();
          _animationController.forward();
        });
      } else {
        // Quiz has ended
        await _onQuizComplete();
        if (mounted) {
          setState(() {
            _questionIndex++; // This will trigger _buildResult()
            _selectedAnswerIndex = null;
            _isAnswerLocked = false;
          });
        }
      }
    });
  }

  void _showAchievementNotification(achievement_model.Achievement achievement) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: AchievementNotification(achievement: achievement),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        overlayEntry.remove();
      }
    });
  }

  Future<void> _onQuizComplete() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Update score
    await authService.updateScore(_score * 10);

    // Award achievement
    UserModel? user = await authService.getUserData();
    if (user != null) {
      String achievementId = '${widget.disasterType}_quiz_master';
      if (!user.achievements.contains(achievementId)) {
        user.achievements.add(achievementId);
        await authService.updateUserData(user);

        final achievement = allAchievements.firstWhere((ach) => ach.id == achievementId);
        _showAchievementNotification(achievement);
      }
    }

    if (!mounted) return;
    _confettiController.play();
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _isAnswerLocked = false;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizData = _quizzes[widget.disasterType] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.disasterType.capitalize()} Quiz'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _questionIndex < quizData.length
            ? _buildQuiz(quizData)
            : _buildResult(),
      ),
    );
  }

  Widget _buildQuiz(List<Map<String, Object>> quizData) {
    var question = quizData[_questionIndex];
    double progress = (_questionIndex + 1) / quizData.length;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Question ${_questionIndex + 1}/${quizData.length}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                question['question'] as String,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount:
                  (question['answers'] as List<Map<String, Object>>).length,
              itemBuilder: (context, index) {
                var answer =
                    (question['answers'] as List<Map<String, Object>>)[index];
                bool isCorrect = answer['correct'] as bool;
                bool isSelected = index == _selectedAnswerIndex;

                Color cardColor = colorScheme.surface;
                Color borderColor = colorScheme.outline;
                Widget? trailingIcon;

                if (_isAnswerLocked) {
                  if (isSelected) {
                    cardColor = isCorrect
                        ? Colors.green.withAlpha(26)
                        : Colors.red.withAlpha(26);
                    borderColor = isCorrect ? Colors.green : Colors.red;
                    trailingIcon = isCorrect
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red);
                  } else if (isCorrect) {
                    cardColor = Colors.green.withAlpha(26);
                    borderColor = Colors.green;
                    trailingIcon =
                        const Icon(Icons.check_circle_outline, color: Colors.green);
                  }
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderColor, width: 2),
                  ),
                  color: cardColor,
                  child: InkWell(
                    onTap:
                        _isAnswerLocked ? null : () => _answerQuestion(isCorrect, index),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              answer['text'] as String,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (trailingIcon != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: trailingIcon,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final quizData = _quizzes[widget.disasterType] ?? [];
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _animationController.value,
                child: child,
              );
            },
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Quiz Completed!',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'You scored',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '$_score out of ${quizData.length}',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You earned ${_score * 10} points!',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.green),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _resetQuiz,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retake Quiz'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 50,
          emissionFrequency: 0.03,
          gravity: 0.3,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple
          ],
          createParticlePath: (size) {
            final path = Path();
            path.addOval(
                Rect.fromCircle(center: Offset.zero, radius: size.width / 4));
            return path;
          },
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}