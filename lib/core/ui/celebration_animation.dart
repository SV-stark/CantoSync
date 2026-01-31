import 'dart:math' as math;
import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';

class CelebrationAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const CelebrationAnimation({super.key, this.onComplete});

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _particles = List.generate(
      50,
      (index) => Particle(
        color: _getRandomColor(),
        startX: 0.5,
        startY: 0.5,
        endX: math.Random().nextDouble(),
        endY: math.Random().nextDouble(),
        size: 8 + math.Random().nextDouble() * 12,
        delay: math.Random().nextDouble() * 0.3,
      ),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Color _getRandomColor() {
    final colors = [
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.blue,
      Colors.green,
      const Color(0xFFFFD700),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return material.Material(
      type: material.MaterialType.transparency,
      child: Stack(
        children: [
          // Semi-transparent background
          Container(color: Colors.black.withValues(alpha: 0.6)),
          // Particles
          ..._particles.map(
            (particle) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final animationValue =
                    ((_controller.value - particle.delay) /
                            (1 - particle.delay))
                        .clamp(0.0, 1.0);

                if (animationValue <= 0) return const SizedBox.shrink();

                final x =
                    particle.startX +
                    (particle.endX - particle.startX) *
                        Curves.easeOut.transform(animationValue);
                final y =
                    particle.startY +
                    (particle.endY - particle.startY) *
                        Curves.easeOut.transform(animationValue);
                final opacity = 1.0 - animationValue;

                return Positioned(
                  left:
                      x * MediaQuery.of(context).size.width - particle.size / 2,
                  top:
                      y * MediaQuery.of(context).size.height -
                      particle.size / 2,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: particle.size,
                      height: particle.size,
                      decoration: BoxDecoration(
                        color: particle.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Center content
          Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FluentIcons.trophy,
                          size: 80,
                          color: Colors.yellow,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Book Completed!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Congratulations on finishing this book',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        FilledButton(
                          onPressed: () {
                            _controller.stop();
                            if (widget.onComplete != null) {
                              widget.onComplete!();
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text('Awesome!'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  final Color color;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final double delay;

  Particle({
    required this.color,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.delay,
  });
}
