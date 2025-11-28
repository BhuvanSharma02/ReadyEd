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