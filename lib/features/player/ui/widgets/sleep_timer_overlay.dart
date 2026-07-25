import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:gap/gap.dart';
import 'package:canto_sync/core/utils/format_duration.dart';

class SleepTimerOverlay extends StatelessWidget {
  const SleepTimerOverlay({super.key, this.remainingTime, this.opacity = 0.25});
  final Duration? remainingTime;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (remainingTime == null) return const SizedBox.shrink();

    return material.IgnorePointer(
      child: Container(
        color: Colors.black.withValues(alpha: opacity),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FluentIcons.timer,
                size: 48,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const Gap(16),
              Text(
                'Sleep Timer Active',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Text(
                'Playback will stop in ${_formatDuration(remainingTime!)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
              ),
              const Gap(16),
              Text(
                '(Click Timer button to cancel)',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
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

  String _formatDuration(Duration d) => formatDuration(d);
}
