import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'quiz_page.dart';

class LearningPathPage extends StatelessWidget {
  final List<String> learningPaths = [
    'Baybayin Characters',
    '2 Syllables Words',
    '3 Syllables Words',
    '4 Syllables Words',
    '5 Syllables Words',
    'Sentences',
  ];

  LearningPathPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Path'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple[50]!, Colors.deepPurple[100]!],
          ),
        ),
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            return ListView.builder(
              itemCount: learningPaths.length,
              itemBuilder: (context, index) {
                bool isUnlocked = index < appState.currentLevel;
                bool isCompleted = appState.isQuizCompleted(index);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      learningPaths[index],
                      style: TextStyle(
                        color: isUnlocked ? Colors.deepPurple[700] : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Icon(
                      isCompleted ? Icons.check_circle :
                      isUnlocked ? Icons.lock_open : Icons.lock,
                      color: isCompleted ? Colors.green :
                             isUnlocked ? Colors.deepPurple : Colors.grey,
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.deepPurple),
                    onTap: isUnlocked
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizPage(lessonIndex: index),
                              ),
                            );
                          }
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}