import 'package:fluent_ui/fluent_ui.dart';
import 'package:gap/gap.dart';
import 'package:canto_sync/core/utils/format_duration.dart';

/// Full-screen scrim shown while a sleep timer is counting down.
///
/// Fades in and out rather than popping: the previous implementation returned
/// `SizedBox.shrink()` the instant `remainingTime` went null, so the scrim
/// vanished with no transition.
class SleepTimerOverlay extends StatefulWidget {
  const SleepTimerOverlay({super.key, this.remainingTime, this.opacity = 0.25});
  final Duration? remainingTime;
  final double opacity;

  @override
  State<SleepTimerOverlay> createState() => _SleepTimerOverlayState();
}

class _SleepTimerOverlayState extends State<SleepTimerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.remainingTime != null) {
      _isVisible = true;
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SleepTimerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.remainingTime == null) {
      if (_isVisible) {
        // Fade out, then stop rendering entirely.
        _isVisible = false;
        _controller.reverse();
      }
    } else if (!_isVisible) {
      setState(() => _isVisible = true);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible && _controller.isDismissed) return const SizedBox.shrink();

    final remaining = widget.remainingTime;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _controller.value,
            child: child,
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: widget.opacity),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  FluentIcons.timer,
                  size: 48,
                  color: Color(0xB3FFFFFF), // white @ 0.7
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
                  remaining != null
                      ? 'Playback will stop in ${_formatDuration(remaining)}'
                      : 'Sleep timer finished',
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
      ),
    );
  }

  String _formatDuration(Duration d) => formatDuration(d);
}
