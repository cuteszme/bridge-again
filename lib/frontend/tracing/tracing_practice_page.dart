
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../main.dart';
import 'package:provider/provider.dart';

class TracingPracticePage extends StatefulWidget {
  const TracingPracticePage({super.key});

  @override
  _TracingPracticePageState createState() => _TracingPracticePageState();
}

class _TracingPracticePageState extends State<TracingPracticePage> {
  int _currentCharacterIndex = 0;
  final GlobalKey<_BaybayinTracingState> _tracingKey = GlobalKey<_BaybayinTracingState>();

  final List<Map<String, String>> characters = [
    {'character': 'ᜀ', 'romanized': 'a'},
    {'character': 'ᜁ', 'romanized': 'i/e'},
    {'character': 'ᜂ', 'romanized': 'u/o'},
    {'character': 'ᜃ', 'romanized': 'ka'},
    {'character': 'ᜄ', 'romanized': 'ga'},
    {'character': 'ᜅ', 'romanized': 'nga'},
    {'character': 'ᜆ', 'romanized': 'ta'},
    {'character': 'ᜇ', 'romanized': 'da'},
    {'character': 'ᜈ', 'romanized': 'na'},
    {'character': 'ᜉ', 'romanized': 'pa'},
    {'character': 'ᜊ', 'romanized': 'ba'},
    {'character': 'ᜋ', 'romanized': 'ma'},
    {'character': 'ᜌ', 'romanized': 'ya'},
    {'character': 'ᜎ', 'romanized': 'la'},
    {'character': 'ᜏ', 'romanized': 'wa'},
    {'character': 'ᜐ', 'romanized': 'sa'},
    {'character': 'ᜑ', 'romanized': 'ha'},
  ];

  void _moveToNextCharacter() {
    if (_currentCharacterIndex < characters.length - 1) {
      setState(() {
        _currentCharacterIndex++;
      });
      _tracingKey.currentState?.clearTraces(); // Clear traces when moving to next character
    } else {
      _showCompletionDialog();
    }
  }

  void _moveToPreviousCharacter() {
    if (_currentCharacterIndex > 0) {
      setState(() {
        _currentCharacterIndex--;
      });
      _tracingKey.currentState?.clearTraces(); // Clear traces when moving to previous character
    }
  }

  void _showCompletionDialog() {
    Provider.of<AppState>(context, listen: false).completeTracingPractice(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Practice Completed!'),
          content: const Text('Great job! You\'ve completed the tracing practice.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back or to next activity
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracing Practice'),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Character ${_currentCharacterIndex + 1} of ${characters.length}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Romanized: ${characters[_currentCharacterIndex]['romanized']}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Try to trace this character:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: BaybayinTracing(
                  key: _tracingKey, // Add the key here
                  character: characters[_currentCharacterIndex]['character']!,
                  onCompleted: () {
                    // Wait a moment before enabling the next button
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {});
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _currentCharacterIndex > 0 ? _moveToPreviousCharacter : null,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _moveToNextCharacter,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BaybayinTracing extends StatefulWidget {
  final String character;
  final VoidCallback onCompleted;

  const BaybayinTracing({
    super.key,
    required this.character,
    required this.onCompleted,
  });

  @override
  _BaybayinTracingState createState() => _BaybayinTracingState();
}

class _BaybayinTracingState extends State<BaybayinTracing> with SingleTickerProviderStateMixin {
  final List<List<TracingPoint>> _allPoints = []; // List to hold multiple tracing paths
  List<TracingPoint> _currentPoints = []; // Current tracing points
  late AnimationController _animationController;
  bool _isTracing = false;
  final Paint _paint = Paint()
    ..color = Colors.deepPurple
    ..strokeWidth = 20.0
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
    ..style = PaintingStyle.stroke;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isTracing = true;
      _currentPoints = [TracingPoint(
        position: details.localPosition,
        timestamp: DateTime.now(),
      )];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isTracing) return;

    setState(() {
      _currentPoints.add(TracingPoint(
        position: details.localPosition,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isTracing = false;
      if (_currentPoints.isNotEmpty) {
        _allPoints.add(List.from(_currentPoints)); // Add current points to the main list
        _currentPoints.clear(); // Clear current points for the next gesture
      }
    });
  }

  void _clearTraces() {
    setState(() {
      _allPoints.clear(); // Clear all traces
    });
    _showClearNotification();
  }

  void clearTraces(){
    setState(() {
      _allPoints.clear();
    });
  }

  void _showClearNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tracing area cleared.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              width: 300,
              height: 275,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  // Character outline with dynamic sizing
                  Center(
                    child: FittedBox(
                      fit: BoxFit.contain, // Ensures the character fits within the container
                      child: Text(
                        widget.character,
                        style: TextStyle(
                          fontSize: 200, // You can adjust this base size if needed
                          color: Colors.deepPurple.withOpacity(0.3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Tracing canvas
                  CustomPaint(
                    painter: TracingPainter(
                      allPoints: _allPoints,
                      currentPoints: _currentPoints,
                      customPaint: _paint,
                    ),
                    child: Container(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _clearTraces,
                child: const Text('Clear Tracing'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TracingPoint {
  final Offset position;
  final DateTime timestamp;

  TracingPoint({
    required this.position,
    required this.timestamp,
  });
}

class TracingPainter extends CustomPainter {
  final List<List<TracingPoint>> allPoints;
  final List<TracingPoint> currentPoints;
  final Paint customPaint;

  TracingPainter({
    required this.allPoints,
    required this.currentPoints,
    required this.customPaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var points in allPoints) {
      if (points.isEmpty) continue;

      final path = Path();
      path.moveTo(points.first.position.dx, points.first.position.dy);

      if (points.length < 2) {
        canvas.drawPoints(
          ui.PointMode.points,
          [points.first.position],
          customPaint,
        );
        continue;
      }

      for (int i = 1; i < points.length - 1; i++) {
        final p0 = points[i].position;
        final p1 = points[i + 1].position;

        final mid = Offset(
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );

        path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      }

      canvas.drawPath(path, customPaint);

      // Add glow effect
      final glowPaint = Paint()
        ..color = Colors.deepPurple.withOpacity(0.3)
        ..strokeWidth = customPaint.strokeWidth * 2
        ..strokeCap = customPaint.strokeCap
        ..style = customPaint.style
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawPath(path, glowPaint);
    }

    // Draw the current tracing points
    if (currentPoints.isNotEmpty) {
      final path = Path();
      path.moveTo(currentPoints.first.position.dx, currentPoints.first.position.dy);

      if (currentPoints.length < 2) {
        canvas.drawPoints(
          ui.PointMode.points,
          [currentPoints.first.position],
          customPaint,
        );
      } else {
        for (int i = 1; i < currentPoints.length - 1; i++) {
          final p0 = currentPoints[i].position;
          final p1 = currentPoints[i + 1].position;

          final mid = Offset(
            (p0.dx + p1.dx) / 2,
            (p0.dy + p1.dy) / 2,
          );

          path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
        }

        canvas.drawPath(path, customPaint);

        // Add glow effect
        final glowPaint = Paint()
          ..color = Colors.deepPurple.withOpacity(0.3)
          ..strokeWidth = customPaint.strokeWidth * 2
          ..strokeCap = customPaint.strokeCap
          ..style = customPaint.style
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

        canvas.drawPath(path, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(TracingPainter oldDelegate) => true;
}