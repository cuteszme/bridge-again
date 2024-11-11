import 'baybayin_quiz_questions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../tracing/baybayin_tracing.dart';

class ThemeColors {
  static const primary = Color(0xFF6200EE);
  static const secondary = Color(0xFF03DAC6);
  static const background = Color(0xFFF3F4F8);
  static const surface = Colors.white;
  static const error = Color(0xFFB00020);
  static const success = Color(0xFF4CAF50);
}

class QuizPage extends StatefulWidget {
  final int lessonIndex;

  const QuizPage({super.key, required this.lessonIndex});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  final GlobalKey<BaybayinTracingState> _tracingKey = GlobalKey<BaybayinTracingState>(); // Add this line
  final Set<int> _answeredQuestions = {};
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _totalScoredQuestions = 0;
  bool _isTracingCompleted = false; // Add this line
  late List<Map<String, dynamic>> questions;
  String? _selectedAnswer;
  List<dynamic> _userAnswer = [];
  List<dynamic> _availableOptions = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    questions = BaybayinQuizQuestions.allLevels[widget.lessonIndex];
    _resetQuestion();
    _calculateTotalScoredQuestions();

  }
  
  void _calculateTotalScoredQuestions() {
    _totalScoredQuestions = questions.where((q) => q['type'] != 'tracing').length;
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

void _resetQuestion() {
  setState(() {
    if (questions[_currentQuestionIndex]['type'] == 'drag_drop') {
      _userAnswer = List.filled(questions[_currentQuestionIndex]['correctAnswer'].length, null);
      _availableOptions = List.from(questions[_currentQuestionIndex]['options']);
    } else if (questions[_currentQuestionIndex]['type'] == 'multiple_choice') {
      _selectedAnswer = null;
    }
  });
  _animationController.reset();
  _animationController.forward();
}

void _checkAnswer() {
  // Skip the answered questions check for tracing exercises
  if (questions[_currentQuestionIndex]['type'] != 'tracing' && _answeredQuestions.contains(_currentQuestionIndex)) {
    // Question already answered, show a message and return
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have already answered this question.')),
    );
    return;
  }

  if (questions[_currentQuestionIndex]['type'] == 'tracing') {
    _showTracingCompletionDialog(); // Call the dialog for tracing completion
  } else if (questions[_currentQuestionIndex]['type'] == 'drag_drop') {
    bool isCorrect = listEquals(_userAnswer.where((e) => e != null).toList(), 
                                questions[_currentQuestionIndex]['correctAnswer']);
    _showAnswerDialog(isCorrect);
  } else if (questions[_currentQuestionIndex]['type'] == 'multiple_choice') {
    bool isCorrect = _selectedAnswer == questions[_currentQuestionIndex]['correctAnswer'];
    _showAnswerDialog(isCorrect);
  }

  // Mark the question as answered if it's not tracing
  if (questions[_currentQuestionIndex]['type'] != 'tracing') {
    _answeredQuestions.add(_currentQuestionIndex);
  }
}
void _showTracingCompletionDialog() {
  setState(() {
    _isTracingCompleted = false;
     // Mark tracing as completed
  });

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Tracing Completed'),
        content: const Text('Great job on completing the tracing exercise! Remember, tracing activities do not contribute to your overall score.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Next'),
            onPressed: () {
              Navigator.of(context).pop();
              _moveToNextQuestion();
            },
          ),
        ],
      );
    },
  );
}

void _showAnswerDialog(bool isCorrect) {
  if (isCorrect) {
    setState(() {
      _score++;
    });
  }

  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      // ignore: deprecated_member_use
      return WillPopScope(
        onWillPop: () async => false, // Disable back button
        child: AlertDialog(
          title: Text(isCorrect ? 'Correct!' : 'Incorrect'),
          content: Text(isCorrect ? 'Good job!' : 'Try again next time.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Next'),
              onPressed: () {
                Navigator.of(context).pop();
                _moveToNextQuestion();
              },
            ),
          ],
        ),
      );
    },
  );
}

void _moveToNextQuestion() {
  do {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isTracingCompleted = false; // Reset tracing in progress state
      });
    } else {
      _finishQuiz();
      return;
    }
  } while (_answeredQuestions.contains(_currentQuestionIndex));

  _resetQuestion();
}

void _finishQuiz() {
  final int percentageScore = (_score / _totalScoredQuestions * 100).round();
  
  // Record the quiz score for achievements
  Provider.of<AppState>(context, listen: false).recordQuizScore(context, percentageScore);
  
  // Mark this quiz as completed
  Provider.of<AppState>(context, listen: false).markQuizAsCompleted(context, widget.lessonIndex);
  
  // Only complete the level if the current level is the one being completed
  if (widget.lessonIndex + 1 == Provider.of<AppState>(context, listen: false).currentLevel) {
    Provider.of<AppState>(context, listen: false).completeLevel(context, percentageScore);
  }

  // Complete quiz for tracking
  Provider.of<AppState>(context, listen: false).completeTracingQuiz(context);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Quiz Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your score: $percentageScore%'),
            const SizedBox(height: 10),
            if (percentageScore >= 90)
              const Text(
                '🏆 Excellent! You\'ve achieved a high score!',
                style: TextStyle(color: Colors.green),
              ),
            const SizedBox(height: 10),
            const Text('Note: Your score has been recorded for achievements.'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      );
    },
  );
}

Widget _buildQuizContent() {
  return FadeTransition(
    opacity: _fadeAnimation,
    child: Container( // Wrap with a Container or SizedBox
      constraints: const BoxConstraints(maxHeight: 600), // Set a maximum height
      child: Column(
        children: [
          _buildQuestionCard(),
          const SizedBox(height: 20),
          if (questions[_currentQuestionIndex]['type'] == 'tracing')
            _buildTracingExercise()
          else if (questions[_currentQuestionIndex]['type'] == 'drag_drop')
            _buildDragDropExercise()
          else if (questions[_currentQuestionIndex]['type'] == 'multiple_choice')
            _buildMultipleChoiceExercise(),
        ],
      ),
    ),
  );
}

  Widget _buildQuestionCard() {
    return Card(
      elevation: 30,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          questions[_currentQuestionIndex]['question'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ).animate().slideY(
      duration: 500.ms,
      begin: -0.2,
      curve: Curves.easeOutQuad,
    );
  }

Widget _buildTracingExercise() {
  return Column(
    children: [
      SizedBox(
        height: 300, // Set a fixed height for the tracing area
        child: BaybayinTracing(
          key: _tracingKey,
          character: questions[_currentQuestionIndex]['character'],
          onCompleted: () {
            Future.delayed(const Duration(milliseconds: 500), () {
              _checkAnswer(); 
            });
          },
        ),
      ),
      const SizedBox(height: 10),
      const Text(
        'Note: Tracing exercises do not contribute to your overall score.',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.deepPurple),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _buildDragDropExercise() {
  return Column(
    children: [
      // Draggable options arranged in a horizontal row
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _availableOptions.map((option) {
            return Draggable(
              data: option,
              feedback: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              childWhenDragging: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  option,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade400),
                ),
              ),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.5, end: 0);
          }).toList(),
        ),
      ),
      const SizedBox(height: 20), // Spacing between draggable options and drop targets
      // Drop targets arranged in a Wrap to avoid overflow
      Wrap(
        spacing: 8.0, // Space between drop targets
        runSpacing: 8.0, // Space between rows
        children: _userAnswer.asMap().entries.map((entry) {
          return DragTarget(
            onWillAcceptWithDetails: (data) => true,
            onAcceptWithDetails: (details) {
              setState(() {
                _userAnswer[entry.key] = details.data;
              });
            },
            builder: (context, candidates, rejected) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 50,
                width: 75, // You can adjust or remove this width if you want
                margin: const EdgeInsets.symmetric(horizontal: 8), // Horizontal spacing between drop targets
                decoration: BoxDecoration(
                  color: candidates.isNotEmpty ? Colors.deepPurple.shade100 : Colors.white,
                  border: Border.all(
                    color: candidates.isNotEmpty ? Colors.deepPurple : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _userAnswer[entry.key] ?? 'Drop here',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _userAnswer[entry.key] != null ? Colors.deepPurple : Colors.grey.shade400,
                    ),
                  ),
                ),
              );
            },
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.5, end: 0);
        }).toList(),
      ),
    ],
  );
}

  Widget _buildMultipleChoiceExercise() {
    return Column(
      children: questions[_currentQuestionIndex]['options'].map<Widget>((option) {
        bool isSelected = _selectedAnswer == option;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? Colors.deepPurple.shade200 : Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  setState(() {
                    _selectedAnswer = option;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.deepPurple,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).scale(delay: 100.ms);
      }).toList(),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Quiz - Level ${widget.lessonIndex + 1}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 48),  // For balance
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                    style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
                  ),
                  if (questions[_currentQuestionIndex]['type'] != 'tracing')
                    Text(
                      'Score: $_score / $_totalScoredQuestions',
                      style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
                    ),
                ],
              ),
            ),
            // Use a fixed height for the quiz content area
            SizedBox(
              height: MediaQuery.of(context).size.height - 200, // Adjust as needed
              child: Column(
                children: [
                  Expanded(
                    child: _buildQuizContent(), // Use the _buildQuizContent method here
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: _isTracingCompleted 
                    ? Colors.grey 
                    : Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: _isTracingCompleted 
                  ? null 
                  : () {
                      setState(() {
                        _isTracingCompleted = true; // Start tracing
                      });
                      _tracingKey.currentState?.clearTraces(); // Call clearTraces() here
                      _checkAnswer(); // Call check answer
                    },
                child: Text(questions[_currentQuestionIndex]['type'] == 'tracing' 
                  ? 'Complete Tracing' 
                  : 'Check Answer'),
              ),
            ),
          ],
        ),
      ),
          ]
          )
          )
          )
          );
  }

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
}