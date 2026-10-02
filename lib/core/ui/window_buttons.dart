import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

/// Window caption buttons (minimise / maximise / close) for the custom title
/// bar.
///
/// The height is driven by the parent `SizedBox` in the root layout: a fixed
/// height of 50 inside the 32px `TitleBar` overflowed its slot and pushed the
/// caption out of the draggable title-bar area.
class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return WindowCaption(
      brightness: theme.brightness,
      backgroundColor: Colors.transparent,
    );
  }
}
