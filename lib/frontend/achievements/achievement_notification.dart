import 'package:flutter/material.dart';

class AchievementNotification extends StatelessWidget {
  final String title;
  final String description;

  const AchievementNotification({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple[100],
      child: ListTile(
        leading: const Icon(
          Icons.emoji_events,
          color: Colors.amber,
          size: 32,
        ),
        title: Text(
          'Achievement Unlocked: $title',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.deepPurple[700],
          ),
        ),
      ),
    );
  }
}