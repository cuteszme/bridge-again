import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class BrushSettings extends StatefulWidget {
  final Function(Paint) onBrushChanged;

  const BrushSettings({super.key, required this.onBrushChanged});

  @override
  _BrushSettingsState createState() => _BrushSettingsState();
}

class _BrushSettingsState extends State<BrushSettings> {
  double _brushSize = 20.0;
  double _brushOpacity = 1.0;
  Color _brushColor = Colors.deepPurple;
  BlurStyle _brushTexture = BlurStyle.normal;

  // Update the brush and notify parent
  void _updateBrush() {
    final Paint newBrush = Paint()
      ..color = _brushColor.withOpacity(_brushOpacity)
      ..strokeWidth = _brushSize
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(_brushTexture, 5)
      ..style = PaintingStyle.stroke;

    widget.onBrushChanged(newBrush);
  }

  // Show color picker dialog
void _showColorPicker() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(  // or MaterialPicker
            pickerColor: _brushColor,
            onColorChanged: (Color color) {
              setState(() {
                _brushColor = color;
              });
              _updateBrush();
            },
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Done'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Brush Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          
          // Brush Size Slider
          Text('Size', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _brushSize,
            min: 1.0,
            max: 50.0,
            divisions: 49,
            label: _brushSize.round().toString(),
            onChanged: (double value) {
              setState(() {
                _brushSize = value;
              });
              _updateBrush();
            },
          ),

          // Brush Opacity Slider
          Text('Opacity', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _brushOpacity,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            label: '${(_brushOpacity * 100).round()}%',
            onChanged: (double value) {
              setState(() {
                _brushOpacity = value;
              });
              _updateBrush();
            },
          ),

          // Brush Color Picker
          Text('Color', style: Theme.of(context).textTheme.titleMedium),
          GestureDetector(
            onTap: _showColorPicker,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _brushColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
          ),

          // Brush Texture Dropdown
          Text('Texture', style: Theme.of(context).textTheme.titleMedium),
          DropdownButton<BlurStyle>(
            value: _brushTexture,
            onChanged: (BlurStyle? newValue) {
              if (newValue != null) {
                setState(() {
                  _brushTexture = newValue;
                });
                _updateBrush();
              }
            },
            items: BlurStyle.values.map<DropdownMenuItem<BlurStyle>>((BlurStyle value) {
              return DropdownMenuItem<BlurStyle>(
                value: value,
                child: Text(value.toString().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}