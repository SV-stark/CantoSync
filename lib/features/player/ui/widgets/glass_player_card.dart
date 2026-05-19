import 'dart:ui';
import 'package:fluent_ui/fluent_ui.dart';

class GlassPlayerCard extends StatelessWidget {
  const GlassPlayerCard({super.key, required this.child});
  final Widget child;
@override
Widget build(BuildContext context) {
  final theme = FluentTheme.of(context);
  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: theme.resources.cardBackgroundFillColorDefault,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}
}
