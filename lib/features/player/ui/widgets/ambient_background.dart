import 'dart:io';
import 'dart:ui';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';

/// Blurred, heavily darkened cover art used as the player screen backdrop.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    this.coverPath,
    this.themeMode = PlayerThemeMode.standard,
  });
  final String? coverPath;

  /// Drives the backdrop treatment. Previously this setting was persisted but
  /// never read, so the "Adaptive (Cover Art)" and "True Black" options did
  /// nothing at all.
  final PlayerThemeMode themeMode;

  /// Covers are decoded to a small size before blurring. Decoding a
  /// 2000x2000 cover and blurring it at sigma 30 every frame kept the GPU
  /// permanently busy; a 48px source looks identical once blurred to a mush.
  static const int _decodeWidth = 48;

  @override
  Widget build(BuildContext context) {
    if (themeMode == PlayerThemeMode.trueBlack) {
      return const ColoredBox(color: Colors.black);
    }

    final Color scrim;
    if (themeMode == PlayerThemeMode.adaptive) {
      // Adaptive: let the cover colour through more, with a lighter scrim.
      scrim = const Color(0x33000000); // black @ 0.2
    } else {
      scrim = const Color(0x80000000); // black @ 0.5
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base Layer: Dark background to fallback
        const ColoredBox(color: Colors.black),

        // Image Layer
        if (coverPath != null)
          Positioned.fill(
            child: Image.file(
              File(coverPath!),
              fit: BoxFit.cover,
              // Resize during decode rather than filtering a full-size bitmap
              // every frame.
              cacheWidth: _decodeWidth,
              filterQuality: FilterQuality.low,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Colors.black),
            ),
          ),

        // Blur Layer
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            // RepaintBoundary keeps the blur's intermediate surface from
            // being recomposited on every parent repaint.
            child: RepaintBoundary(
              child: ColoredBox(
                color: scrim, // Dark overlay for readability
              ),
            ),
          ),
        ),

        // Gradient Vingette (optional, to darken edges)
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.transparent,
                  Color(0x99000000), // black @ 0.6
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
