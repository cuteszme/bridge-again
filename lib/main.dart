import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'frontend/homepage/home_page.dart';
import 'frontend/achievements/achievement_notification.dart';

class AppState extends ChangeNotifier {
  int _currentLevel = 1;
  int _score = 0;
  final Map<String, bool> _achievements = {
    'First Steps': false,
    'Master Tracer': false,
    'Quiz Whiz': false,
    'Cultural Enthusiast': false,
    'Community Contributor': false,
  };
  int _completedLessons = 0;
  int _completedTracingPractices = 0;
  int _completedTracingQuizzes = 0;
  final List<int> _quizScores = [];
  final Set<int> _completedQuizzes = {};
  final int _totalQuizzes = 6;

  static const int maxLevel = 6;

  final Map<String, String> achievementDescriptions = {
    'First Steps': 'Completed your first lesson!',
    'Master Tracer': 'Completed tracing practice and 3 tracing quizzes',
    'Quiz Whiz': 'Achieved 90% or higher in 3 quizzes',
    'Cultural Enthusiast': 'Completed all available quizzes',
    'Community Contributor': 'Shared your progress with others',
  };

  // Getters
  int get currentLevel => _currentLevel;
  int get score => _score;
  Map<String, bool> get achievements => _achievements;
  bool isQuizCompleted(int quizIndex) => _completedQuizzes.contains(quizIndex);

  // Load state from SharedPreferences
  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLevel = prefs.getInt('currentLevel') ?? 1;
    _score = prefs.getInt('score') ?? 0;
    _completedLessons = prefs.getInt('completedLessons') ?? 0;
    _completedTracingPractices = prefs.getInt('completedTracingPractices') ?? 0;
    _completedTracingQuizzes = prefs.getInt('completedTracingQuizzes') ?? 0;

    // Load achievements
    for (String key in _achievements.keys) {
      _achievements[key] = prefs.getBool(key) ?? false;
    }

    // Load quiz scores and completed quizzes
    _quizScores.addAll(prefs.getStringList('quizScores')?.map(int.parse) ?? []);
    _completedQuizzes.addAll(prefs.getStringList('completedQuizzes')?.map(int.parse).toSet() ?? {});

    notifyListeners();
  }

  // Save state to SharedPreferences
  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentLevel', _currentLevel);
    await prefs.setInt('score', _score);
    await prefs.setInt('completedLessons', _completedLessons);
    await prefs.setInt('completedTracingPractices', _completedTracingPractices);
    await prefs.setInt('completedTracingQuizzes', _completedTracingQuizzes);

    // Save achievements
    for (String key in _achievements.keys) {
      await prefs.setBool(key, _achievements[key]!);
    }

    // Save quiz scores and completed quizzes
    await prefs.setStringList('quizScores', _quizScores.map((e) => e.toString()).toList());
    await prefs.setStringList('completedQuizzes', _completedQuizzes.map((e) => e.toString()).toList());
  }

  void _showAchievementNotification(BuildContext context, String achievementTitle) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      content: AchievementNotification(
        title: achievementTitle,
        description: achievementDescriptions[achievementTitle] ?? '',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    Future.delayed(const Duration(milliseconds: 1000), () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
  }

  void checkAchievements(BuildContext context) {
    // First Steps
    if (_completedLessons >= 1 && !_achievements['First Steps']!) {
      _achievements['First Steps'] = true;
      _showAchievementNotification(context, 'First Steps');
    }

    // Master Tracer
    if (_completedTracingPractices >= 1 && 
        _completedTracingQuizzes >= 3 && 
        !_achievements['Master Tracer']!) {
      _achievements['Master Tracer'] = true;
      _showAchievementNotification(context, 'Master Tracer');
    }

    // Quiz Whiz
    int highScoreQuizzes = _quizScores.where((score ) => score >= 90).length;
    if (highScoreQuizzes >= 3 && !_achievements['Quiz Whiz']!) {
      _achievements['Quiz Whiz'] = true;
      _showAchievementNotification(context, 'Quiz Whiz');
    }

    // Cultural Enthusiast
    if (_completedQuizzes.length >= _totalQuizzes && 
        !_achievements['Cultural Enthusiast']!) {
      _achievements['Cultural Enthusiast'] = true;
      _showAchievementNotification(context, 'Cultural Enthusiast');
    }

    notifyListeners();
  }

  void completeLevel(BuildContext context, int score) {
    if (score >= 75 && _currentLevel < maxLevel) {
      _currentLevel++;
      _score += score;
      checkAchievements(context);
      saveState();
      notifyListeners();
    }
  }

  void completeLesson(BuildContext context) {
    _completedLessons++;
    checkAchievements(context);
    saveState();
    notifyListeners();
  }

  void completeTracingPractice(BuildContext context) {
    _completedTracingPractices++;
    checkAchievements(context);
    saveState();
    notifyListeners();
  }

  void completeTracingQuiz(BuildContext context) {
    _completedTracingQuizzes++;
    checkAchievements(context);
    saveState();
    notifyListeners();
  }

  void recordQuizScore(BuildContext context, int score) {
    _quizScores.add(score);
    checkAchievements(context);
    saveState();
    notifyListeners();
  }

  void markQuizAsCompleted(BuildContext context, int quizIndex) {
    _completedQuizzes.add(quizIndex);
    checkAchievements(context);
    saveState();
    notifyListeners();
  }

  void shareProgress(BuildContext context) {
    if (!_achievements['Community Contributor']!) {
      _achievements['Community Contributor'] = true;
      _showAchievementNotification(context, 'Community Contributor');
      saveState();
      notifyListeners();
    }
  }

  double getAchievementProgress(String achievementTitle) {
    switch (achievementTitle) {
      case 'First Steps':
        return _completedLessons >= 1 ? 100 : (_completedLessons * 100);
      case 'Master Tracer':
        double practiceProgress = _completedTracingPractices >= 1 ? 50 : 0;
        double quizProgress = (_completedTracingQuizzes / 3) * 50;
        return practiceProgress + quizProgress.clamp(0, 50);
      case 'Quiz Whiz':
        int highScoreQuizzes = _quizScores.where((score) => score >= 90).length;
        return (highScoreQuizzes / 3 * 100).clamp(0.0, 100.0);
      case 'Cultural Enthusiast':
        return (_completedQuizzes.length / _totalQuizzes * 100).clamp(0.0, 100.0);
      case 'Community Contributor':
        return _achievements['Community Contributor'] == true ? 100 : 0;
      default:
        return 0;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.loadState();
  runApp(
    ChangeNotifierProvider(
      create: (context) => appState,
      child: const BaybayinLearningApp(),
    ),
  );
}

final themeColor = {
  'primary': const Color(0xFF6246EA),
  'secondary': const Color(0xFFE45858),
  'background': const Color(0xFFFFFFFE),
  'surface': const Color(0xFFFFFFFF),
  'text': const Color(0xFF2B2C34),
  'accent1': const Color(0xFF3DA9FC),
  'accent2': const Color(0xFFFFBE0B),
  'accent3': const Color(0xFF2CB67D),
};

class BaybayinLearningApp extends StatelessWidget {
  const BaybayinLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baybayin Learning',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: themeColor['primary']!,
          onPrimary: Colors.white,
          secondary: themeColor['secondary']!,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: themeColor['surface']!,
          onSurface: themeColor['text']!,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: themeColor['text'],
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: themeColor['text'],
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle (
            color: themeColor['text'],
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: themeColor['text'],
            fontSize: 16,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}