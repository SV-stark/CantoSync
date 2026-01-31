import 'dart:math' as math;
import 'package:fluent_ui/fluent_ui.dart';

class WaveformVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double height;
  final int barCount;

  const WaveformVisualizer({
    super.key,
    required this.isPlaying,
    this.color = Colors.white,
    this.height = 60,
    this.barCount = 30,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 400 + _random.nextInt(400),
        ),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    if (widget.isPlaying) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 30), () {
        if (mounted && widget.isPlaying) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimation() {
    for (var controller in _controllers) {
      controller.stop();
      controller.value = 0.2;
    }
  }

  @override
  void didUpdateWidget(WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(widget.barCount, (index) {
          // Create a bell curve distribution for bar heights
          final centerIndex = widget.barCount / 2;
          final distanceFromCenter = (index - centerIndex).abs();
          final normalizedDistance = distanceFromCenter / centerIndex;
          final baseHeight = 1.0 - (normalizedDistance * 0.5);

          return Expanded(
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                final animatedHeight = widget.isPlaying
                    ? baseHeight * _animations[index].value
                    : baseHeight * 0.3;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: widget.height * animatedHeight,
                  decoration: BoxDecoration(
                    color: widget.color.withAlpha(
                      widget.isPlaying ? 200 : 100,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
