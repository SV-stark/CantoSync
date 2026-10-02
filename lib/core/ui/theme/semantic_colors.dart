import 'package:fluent_ui/fluent_ui.dart';

/// Semantic colours that the fluent_ui theme does not provide tokens for.
///
/// AGENTS.md forbids hard-coding hex values in feature widgets, so anything
/// that needs a colour outside the standard accent/background set resolves it
/// from this extension instead. Light and dark variants are defined so the
/// same widget code reads correctly in both modes.
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.destructive,
    required this.success,
    required this.warning,
    required this.overlayScrim,
    required this.onOverlay,
    required this.progressTrack,
    required this.highlight,
    required this.sessions,
  });

  /// Danger / delete actions.
  final Color destructive;

  /// "Finished" state.
  final Color success;

  /// "Continue" state and other non-blocking notices.
  final Color warning;

  /// Scrim painted behind text or badges sitting on top of cover art.
  final Color overlayScrim;

  /// Text or icons drawn on top of [overlayScrim].
  final Color onOverlay;

  /// Unfilled portion of a circular progress indicator.
  final Color progressTrack;

  /// Gold/amber accent for achievement style indicators (trophies, streaks).
  final Color highlight;

  /// Secondary categorical accent, used to distinguish stat cards from the
  /// accent colour so the summary row does not read as four identical tiles.
  final Color sessions;

  static const light = SemanticColors(
    destructive: Color(0xFFC42B1C),
    success: Color(0xFF0F7B0F),
    warning: Color(0xFF9D5D00),
    overlayScrim: Color(0xB3000000),
    onOverlay: Color(0xFFFFFFFF),
    progressTrack: Color(0x4DFFFFFF),
    highlight: Color(0xFF986F0B),
    sessions: Color(0xFF8764B8),
  );

  static const dark = SemanticColors(
    destructive: Color(0xFFFF99A4),
    success: Color(0xFF6CCB5F),
    warning: Color(0xFFFCE100),
    overlayScrim: Color(0xB3000000),
    onOverlay: Color(0xFFFFFFFF),
    progressTrack: Color(0x4DFFFFFF),
    highlight: Color(0xFFFCE100),
    sessions: Color(0xFFB39DDB),
  );

  /// Ramp used by the contribution heatmap: index 0 is "no activity", and each
  /// subsequent entry is one step of increasing listening time.
  static const _heatmapLight = <Color>[
    Color(0x1A000000),
    Color(0x4D8764B8),
    Color(0x998764B8),
    Color(0xCC8764B8),
    Color(0xFF8764B8),
  ];

  static const _heatmapDark = <Color>[
    Color(0x1AFFFFFF),
    Color(0x4DB39DDB),
    Color(0x99B39DDB),
    Color(0xCCB39DDB),
    Color(0xFFB39DDB),
  ];

  /// Colour for a heatmap cell at [level] (clamped to the available ramp).
  Color heatmapLevel(int level, bool isDark) {
    final ramp = isDark ? _heatmapDark : _heatmapLight;
    return ramp[level.clamp(0, ramp.length - 1)];
  }

  @override
  SemanticColors copyWith({
    Color? destructive,
    Color? success,
    Color? warning,
    Color? overlayScrim,
    Color? onOverlay,
    Color? progressTrack,
    Color? highlight,
    Color? sessions,
  }) {
    return SemanticColors(
      destructive: destructive ?? this.destructive,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      overlayScrim: overlayScrim ?? this.overlayScrim,
      onOverlay: onOverlay ?? this.onOverlay,
      progressTrack: progressTrack ?? this.progressTrack,
      highlight: highlight ?? this.highlight,
      sessions: sessions ?? this.sessions,
    );
  }

  @override
  SemanticColors lerp(covariant SemanticColors? other, double t) {
    if (other == null) return this;
    return SemanticColors(
      destructive: Color.lerp(destructive, other.destructive, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      overlayScrim: Color.lerp(overlayScrim, other.overlayScrim, t)!,
      onOverlay: Color.lerp(onOverlay, other.onOverlay, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      sessions: Color.lerp(sessions, other.sessions, t)!,
    );
  }
}

extension SemanticColorsContext on BuildContext {
  /// Resolves [SemanticColors] from the nearest [FluentTheme].
  ///
  /// Falls back to the light palette so a missing extension degrades to a
  /// usable colour instead of throwing during build.
  SemanticColors get semanticColors =>
      FluentTheme.of(this).extension<SemanticColors>() ?? SemanticColors.light;
}
