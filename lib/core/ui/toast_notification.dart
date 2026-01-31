import 'package:fluent_ui/fluent_ui.dart';

class ToastNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Duration duration;

  const ToastNotification({
    super.key,
    required this.message,
    required this.icon,
    this.backgroundColor,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ToastNotification> createState() => _ToastNotificationState();
}

class _ToastNotificationState extends State<ToastNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color:
                widget.backgroundColor ?? FluentTheme.of(context).accentColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ToastService {
  static void show(
    BuildContext context, {
    required String message,
    required IconData icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        left: 0,
        right: 0,
        child: Center(
          child: ToastNotification(
            message: message,
            icon: icon,
            backgroundColor: backgroundColor,
            duration: duration,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration + const Duration(milliseconds: 300), () {
      overlayEntry.remove();
    });
  }

  static void showSuccess(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: FluentIcons.check_mark,
      backgroundColor: const Color(0xFF107C10), // Success green
    );
  }

  static void showError(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: FluentIcons.error,
      backgroundColor: const Color(0xFFE81123), // Error red
    );
  }

  static void showInfo(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: FluentIcons.info,
      backgroundColor: FluentTheme.of(context).accentColor,
    );
  }
}
