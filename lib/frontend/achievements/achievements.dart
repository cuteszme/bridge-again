import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final List<Achievement> achievements = [
      Achievement(
        title: "First Steps",
        description: "Complete all required lessons.",
        criteria: "Complete all lessons",
        icon: FontAwesomeIcons.personWalking,
        progress: appState.getAchievementProgress("First Steps"),
      ),
      Achievement(
        title: "Master Tracer",
        description: "Successfully trace 70% or more of tracing exercises and complete the Practice Tracing page",
        criteria: "Trace at least 70% and complete Practice Tracing page",
        icon: FontAwesomeIcons.pencil,
        progress: appState.getAchievementProgress("Master Tracer"),
      ),
      Achievement(
        title: "Quiz Whiz",
        description: "Score 90% or higher in three separate quizzes.",
        criteria: "Achieve 90% in three quizzes",
        icon: FontAwesomeIcons.trophy,
        progress: appState.getAchievementProgress("Quiz Whiz"),
      ),
      Achievement(
        title: "Cultural Enthusiast",
        description: "Complete all quizzes available in the app.",
        criteria: "Finish all quizzes",
        icon: FontAwesomeIcons.earthAsia,
        progress: appState.getAchievementProgress("Cultural Enthusiast"),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView.builder(
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          return AchievementCard(achievement: achievements[index]);
        },
      ),
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final String criteria;
  final IconData icon;
  final double progress;

  Achievement({
    required this.title,
    required this.description,
    required this.criteria,
    required this.icon,
    required this.progress,
  });
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(achievement.icon, size: 40),
            title: Text(
              achievement.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(achievement.description),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearProgressIndicator(
              value: achievement.progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                achievement.progress == 100 ? Colors.green : Colors.indigo,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "${achievement.progress.toStringAsFixed(0)}% Completed",
              style: TextStyle(
                color: achievement.progress == 100 ? Colors.green : Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Criteria: ${achievement.criteria}",
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}