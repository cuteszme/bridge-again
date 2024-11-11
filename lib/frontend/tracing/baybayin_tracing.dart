import 'package:bridge/frontend/tracing/brush_setting.dart';
import 'package:flutter/material.dart';

class BaybayinTracing extends StatefulWidget {
  final String character;
  final VoidCallback onCompleted;
  final VoidCallback? onClear;

  const BaybayinTracing({
    super.key,
    required this.character,
    required this.onCompleted,
    this.onClear,
  });

  @override
  BaybayinTracingState createState() => BaybayinTracingState();
}

class BaybayinTracingState extends State<BaybayinTracing> with SingleTickerProviderStateMixin {
  final List<TracingPoint> _points = [];
  final List<List<TracingPoint>> _completedTraces = []; // Store completed traces
  late AnimationController _animationController;
  bool _isTracing = false;
  Paint _paint = Paint()
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
      _points.add(TracingPoint(
        position: details.localPosition,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isTracing) return;

    setState(() {
      _points.add(TracingPoint(
        position: details.localPosition,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isTracing = false;
      // Save the current points to completed traces
      if (_points.isNotEmpty) {
        _completedTraces.add(List.from(_points)); // Add a copy of current points
        _points.clear(); // Clear current points for new tracing
      }
    });
  }

  void _clearTraces() {
    setState(() {
      _completedTraces.clear(); // Clear completed traces
    });
    _showClearNotification();
  }

  void clearTraces(){
    setState(() {
      _completedTraces.clear();
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

  void _updateBrush(Paint newBrush) {
    setState(() {
      _paint = newBrush;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fixed height for the tracing area
        Container(
          width: 300,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Stack(
              children: [
                // Character outline with dynamic sizing
                Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      widget.character,
                      style: TextStyle(
                        fontSize: 200,
                        color: Colors.deepPurple.withOpacity(0.3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Tracing canvas
                CustomPaint(
                  painter: TracingPainter(
                    points: _points,
                    completedTraces: _completedTraces, // Pass completed traces
                    customPaint: _paint,
                  ),
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clear button
                ElevatedButton(
                  onPressed: _clearTraces,
                  child: const Text('Clear Tracing'),
                ),
                const SizedBox(height: 20),
                // Button to open Brush Settings
                ElevatedButton(
                  onPressed: _showBrushSettingsDialog,
                  child: const Text('Brush Settings'),
                ),
              ],
            ),
          ),
 ),
      ],
    );
  }

  // Method to show brush settings dialog
  void _showBrushSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Brush Settings'),
          content: BrushSettings(onBrushChanged: _updateBrush),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
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
  final List<TracingPoint> points;
  final List<List<TracingPoint>> completedTraces;
  final Paint customPaint;

  TracingPainter({
    required this.points,
    required this.completedTraces,
    required this.customPaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty && completedTraces.isEmpty) return;

    final path = Path();

    // Draw completed traces
    for (final completedTrace in completedTraces) {
      if (completedTrace.isNotEmpty) {
        path.moveTo(completedTrace.first.position.dx, completedTrace.first.position.dy);

        for (int i = 1; i < completedTrace.length - 1; i++) {
          final p0 = completedTrace[i].position;
          final p1 = completedTrace[i + 1].position;

          final mid = Offset(
            (p0.dx + p1.dx) / 2,
            (p0.dy + p1.dy) / 2,
          );

          path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
        }
      }
    }

    // Draw current tracing
    if (points.isNotEmpty) {
      path.moveTo(points.first.position.dx, points.first.position.dy);

      for (int i = 1; i < points.length - 1; i++) {
        final p0 = points[i].position;
        final p1 = points[i + 1].position;

        final mid = Offset(
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );

        path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      }
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

  @override
  bool shouldRepaint(TracingPainter oldDelegate) => true;
}