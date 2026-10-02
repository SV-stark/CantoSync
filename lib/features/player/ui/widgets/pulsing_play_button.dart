import 'package:fluent_ui/fluent_ui.dart';

class PulsingPlayButton extends StatefulWidget {
  const PulsingPlayButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
    this.size = 80,
  });
  final bool isPlaying;
  final VoidCallback onPressed;
  final double size;

  @override
  State<PulsingPlayButton> createState() => _PulsingPlayButtonState();
}

class _PulsingPlayButtonState extends State<PulsingPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingPlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.15, // Fixed size to accommodate max pulse
      height: widget.size * 1.15,
      child: Center(
        // Animate a transform only. Previously the BoxShadow's blurRadius and
        // spreadRadius were recomputed on every frame, forcing a full repaint
        // of a 30px-blur shadow 60x a second.
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: RepaintBoundary(child: _buildButton(context)),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          if (widget.isPlaying)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          widget.isPlaying ? FluentIcons.pause : FluentIcons.play,
          color: Colors.black,
          size: widget.size * 0.4,
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}
