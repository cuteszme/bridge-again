import 'package:bridge/frontend/lesson/lesson_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../quiz/learning_path_page.dart';
import '../../main.dart';
import '../tracing/tracing_practice_page.dart';
import '../achievements/achievements.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeColor['primary']!.withOpacity(0.1),
              themeColor['background']!,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 32),
                          _buildProgressSection(context, appState),
                          const SizedBox(height: 32),
                          _buildFeatureGrid(context),
                        ],
                      ).animate().fadeIn(
                            duration: const Duration(milliseconds: 800),
                          ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: themeColor['primary']!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'ᜆᜓᜎᜌ᜔',
            style: TextStyle(
              fontSize: 40,
              color: themeColor['primary'],
              fontWeight: FontWeight.bold,
            ),
          ),
        ).animate().scale(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
            ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BRIDGE',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                'Baybayin Learning',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: themeColor['text']!.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor['primary']!,
            themeColor['accent1']!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeColor['primary']!.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat(
                context,
                'Level',
                '${appState.currentLevel}',
                themeColor['accent2']!,
              ),
              _buildProgressStat(
                context,
                'Score',
                '${appState.score}',
                themeColor['text']!,
              ),
            ],
          ),
        ],
      ),
    ).animate().slideX(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
        );
  }

  Widget _buildProgressStat(
    BuildContext context,
    String label,
    String value,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      {
        'title': 'Learn Baybayin',
        'icon': Icons.auto_stories,
        'color': themeColor['accent1'],
        'page': const LessonPage(lessonTitle: 'Baybayin Writing System'),
      },
      {
        'title': 'Practice Tracing',
        'icon': Icons.edit,
        'color': themeColor['accent2'],
        'page': const TracingPracticePage(),
      },
      {
        'title': 'Take Quizzes',
        'icon': Icons.quiz,
        'color': themeColor['accent3'],
        'page': LearningPathPage(),
      },
      {
        'title': 'Achievements',
        'icon': Icons.insights,
        'color': themeColor['secondary'],
        'page': const AchievementsPage(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _buildFeatureCard(
          context,
          features[index]['title'] as String,
          features[index]['icon'] as IconData,
          features[index]['color'] as Color,
          features[index]['page'] as Widget?,
        ).animate().scale(
              duration: Duration(milliseconds: 600 + (index * 100)),
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget? page,
  ) {
    return InkWell(
      onTap: page != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              )
          : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: themeColor['text'],
                    fontSize: 16,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}