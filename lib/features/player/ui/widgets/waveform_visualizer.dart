import 'dart:math' as math;
import 'package:fluent_ui/fluent_ui.dart';

class WaveformVisualizer extends StatefulWidget {
  const WaveformVisualizer({
    super.key,
    required this.isPlaying,
    this.color = Colors.white,
    this.height = 60,
    this.barCount = 30,
  });
  final bool isPlaying;
  final Color color;
  final double height;
  final int barCount;

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(double.infinity, widget.height),
            painter: _WaveformPainter(
              animationValue: _controller.value,
              isPlaying: widget.isPlaying,
              color: widget.color,
              barCount: widget.barCount,
            ),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.animationValue,
    required this.isPlaying,
    required this.color,
    required this.barCount,
  });

  final double animationValue;
  final bool isPlaying;
  final Color color;
  final int barCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final spacing = size.width / barCount;
    final barWidth = spacing * 0.6;
    final centerIndex = barCount / 2;

    for (int i = 0; i < barCount; i++) {
      // Bell curve distribution
      final distanceFromCenter = (i - centerIndex).abs();
      final normalizedDistance = distanceFromCenter / centerIndex;
      final baseHeightFactor = 1.0 - (normalizedDistance * 0.6);

      double animatedFactor;
      if (isPlaying) {
        // Create a rippling wave effect using sine
        // Offset each bar's phase based on its index
        final phase = i * (math.pi / 4);
        animatedFactor =
            0.3 +
            (0.7 *
                (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi + phase)));
      } else {
        animatedFactor = 0.2;
      }

      final barHeight = size.height * baseHeightFactor * animatedFactor;
      final x = i * spacing + (spacing - barWidth) / 2;
      final y = (size.height - barHeight) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        isPlaying != oldDelegate.isPlaying ||
        color != oldDelegate.color ||
        barCount != oldDelegate.barCount;
  }
}
