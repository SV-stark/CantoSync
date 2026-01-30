import 'dart:io';
import 'dart:ui';
import 'package:fluent_ui/fluent_ui.dart';

class AmbientBackground extends StatelessWidget {
  final String? coverPath;

  const AmbientBackground({super.key, this.coverPath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base Layer: Dark background to fallback
        Container(color: Colors.black),

        // Image Layer
        if (coverPath != null)
          Positioned.fill(
            child: Image.file(
              File(coverPath!),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: Colors.black),
            ),
          ),

        // Blur Layer
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: Colors.black.withValues(
                alpha: 0.5,
              ), // Dark overlay for readability
            ),
          ),
        ),

        // Gradient Vingette (optional, to darken edges)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
