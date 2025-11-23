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

class _QuizScreenState extends State<QuizScreen> {
  late ConfettiController _confettiController;
  int _questionIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
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

  void _answerQuestion(bool isCorrect) {
    if (isCorrect) {
      _score++;
    }

    if (_questionIndex == (_quizzes[widget.disasterType]?.length ?? 0) - 1) {
      _onQuizComplete();
    }

    setState(() {
      _questionIndex++;
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
      overlayEntry.remove();
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

    _confettiController.play();
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizData = _quizzes[widget.disasterType] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.disasterType.capitalize()} Quiz'),
      ),
      body: _questionIndex < quizData.length
          ? _buildQuiz(quizData)
          : _buildResult(),
    );
  }

  Widget _buildQuiz(List<Map<String, Object>> quizData) {
    var question = quizData[_questionIndex];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${_questionIndex + 1}/${quizData.length}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            question['question'] as String,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          ...(question['answers'] as List<Map<String, Object>>).map((answer) {
            return ElevatedButton(
              onPressed: () => _answerQuestion(answer['correct'] as bool),
              child: Text(answer['text'] as String),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final quizData = _quizzes[widget.disasterType] ?? [];
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Quiz Completed!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You scored $_score out of ${quizData.length}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You earned ${_score * 10} points!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _resetQuiz,
                        child: const Text('Retake Quiz'),
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
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 30,
          emissionFrequency: 0.05,
          gravity: 0.2,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple
          ],
          createParticlePath: (size) {
            final path = Path();
            path.addOval(Rect.fromCircle(center: Offset.zero, radius: size.width / 2));
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