import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';

class SleepTimerOverlay extends StatelessWidget {
  final Duration? remainingTime;
  final double opacity;

  const SleepTimerOverlay({
    super.key,
    this.remainingTime,
    this.opacity = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    if (remainingTime == null) return const SizedBox.shrink();

    return material.IgnorePointer(
      child: Container(
        color: Colors.black.withAlpha((opacity * 255).toInt()),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FluentIcons.timer,
                size: 48,
                color: Colors.white.withAlpha(179),
              ),
              const SizedBox(height: 16),
              Text(
                'Sleep Timer Active',
                style: TextStyle(
                  color: Colors.white.withAlpha(179),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Playback will stop in ${_formatDuration(remainingTime!)}',
                style: TextStyle(
                  color: Colors.white.withAlpha(128),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '(Click Timer button to cancel)',
                style: TextStyle(
                  color: Colors.white.withAlpha(77),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
}
