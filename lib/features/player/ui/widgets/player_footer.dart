import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/services/sleep_timer_service.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';
import 'package:canto_sync/features/player/ui/widgets/waveform_visualizer.dart';
import 'package:canto_sync/core/utils/format_duration.dart';

class PlayerFooterSection extends ConsumerWidget {
  final Duration chapterDuration;
  final Duration chapterPosition;
  final Duration? remainingTimer;

  const PlayerFooterSection({
    super.key,
    required this.chapterDuration,
    required this.chapterPosition,
    required this.remainingTimer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaService = ref.watch(mediaServiceProvider);
    final white70 = Colors.white.withValues(alpha: 0.7);
    final white54 = Colors.white.withValues(alpha: 0.54);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _FooterButton(
          icon: FluentIcons.playback_rate1x,
          label: '${mediaService.playRate.toStringAsFixed(2)}x',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => SpeedControlDialog(
                initialRate: mediaService.playRate,
                onRateChanged: (rate) => mediaService.setRate(rate),
              ),
            );
          },
        ),
        _FooterButton(
          icon: FluentIcons.timer,
          label: remainingTimer != null
              ? '${remainingTimer!.inMinutes}:${(remainingTimer!.inSeconds % 60).toString().padLeft(2, '0')}'
              : 'Timer',
          onTap: () {
            showSleepTimerMenu(context, ref, chapterDuration - chapterPosition);
          },
        ),
        _FooterButton(
          icon: FluentIcons.equalizer,
          label: 'EQ',
          onTap: () => showEQMenu(context, mediaService),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FluentIcons.ringer, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: Slider(
                value: mediaService.volume,
                min: 0,
                max: 100,
                onChanged: (v) => mediaService.setVolume(v),
                style: SliderThemeData(thumbRadius: WidgetStateProperty.all(6)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final white70 = Colors.white.withValues(alpha: 0.7);
    final white54 = Colors.white.withValues(alpha: 0.54);

    return HoverButton(
      onPressed: onTap,
      builder: (context, states) {
        return Column(
          children: [
            Icon(icon, color: white70, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: white54, fontSize: 11)),
          ],
        );
      },
    );
  }
}

class SpeedControlDialog extends StatefulWidget {
  final double initialRate;
  final ValueChanged<double> onRateChanged;

  const SpeedControlDialog({
    super.key,
    required this.initialRate,
    required this.onRateChanged,
  });

  @override
  State<SpeedControlDialog> createState() => _SpeedControlDialogState();
}

class _SpeedControlDialogState extends State<SpeedControlDialog> {
  late double _rate;

  @override
  void initState() {
    super.initState();
    _rate = widget.initialRate;
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Playback Speed'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_rate.toStringAsFixed(2)}x',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Slider(
            value: _rate,
            min: 0.5,
            max: 3.0,
            onChanged: (v) {
              final snapped = (v * 20).round() / 20.0;
              setState(() => _rate = snapped);
              widget.onRateChanged(snapped);
            },
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final preset in [1.0, 1.25, 1.5, 1.75, 2.0, 2.5])
                FilledButton(
                  onPressed: () {
                    setState(() => _rate = preset);
                    widget.onRateChanged(preset);
                  },
                  style: ButtonStyle(
                    backgroundColor: _rate == preset
                        ? WidgetStateProperty.all(
                            FluentTheme.of(context).accentColor,
                          )
                        : null,
                  ),
                  child: Text('${preset}x'),
                ),
            ],
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text('Done'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

void showEQMenu(BuildContext context, MediaService mediaService) {
  showDialog(
    context: context,
    builder: (context) => ContentDialog(
      title: const Text('Equalizer Presets'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EQOption(
            label: 'Flat (Off)',
            onTap: () => mediaService.setAudioFilter(''),
          ),
          EQOption(
            label: 'Spoken Word (Optimized)',
            onTap: () => mediaService.setAudioFilter(
              'lavfi=[highpass=f=200,lowpass=f=3000]',
            ),
          ),
          EQOption(
            label: 'Bass Boost',
            onTap: () => mediaService.setAudioFilter('lavfi=[bass=g=10:f=100]'),
          ),
          EQOption(
            label: 'Treble Boost',
            onTap: () =>
                mediaService.setAudioFilter('lavfi=[treble=g=10:f=5000]'),
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

class EQOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const EQOption({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      onPressed: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }
}

class TimerOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const TimerOption({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Button(
        onPressed: () {
          onTap();
          Navigator.pop(context);
        },
        child: Align(alignment: Alignment.centerLeft, child: Text(label)),
      ),
    );
  }
}

void showSleepTimerMenu(
  BuildContext context,
  WidgetRef ref,
  Duration remainingChapter,
) {
  final timerService = ref.read(sleepTimerServiceProvider.notifier);
  showDialog(
    context: context,
    builder: (context) {
      return ContentDialog(
        title: const Text('Sleep Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TimerOption(label: 'Off', onTap: () => timerService.cancelTimer()),
            TimerOption(
              label: '15 Minutes',
              onTap: () => timerService.startTimer(const Duration(minutes: 15)),
            ),
            TimerOption(
              label: '30 Minutes',
              onTap: () => timerService.startTimer(const Duration(minutes: 30)),
            ),
            TimerOption(
              label: '60 Minutes',
              onTap: () => timerService.startTimer(const Duration(minutes: 60)),
            ),
            TimerOption(
              label: 'End of Chapter',
              onTap: () => timerService.setEndOfChapter(),
            ),
            SizedBox(
              width: double.infinity,
              child: Button(
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      final controller = TextEditingController();
                      return ContentDialog(
                        title: const Text('Set Sleep Timer'),
                        content: TextBox(
                          controller: controller,
                          placeholder: 'Minutes',
                          keyboardType: TextInputType.number,
                        ),
                        actions: [
                          Button(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          FilledButton(
                            child: const Text('Start'),
                            onPressed: () {
                              final mins = int.tryParse(controller.text) ?? 30;
                              timerService.startTimer(Duration(minutes: mins));
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Custom...'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

class WaveformSection extends ConsumerWidget {
  final bool isPlaying;

  const WaveformSection({super.key, required this.isPlaying});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(appSettingsProvider).showWaveform) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        const SizedBox(height: 20),
        WaveformVisualizer(
          isPlaying: isPlaying,
          color: Colors.white,
          height: 40,
        ),
      ],
    );
  }
}

class GlobalProgressBar extends StatelessWidget {
  final double globalPositionSeconds;
  final Duration totalDuration;
  final String percentageText;

  const GlobalProgressBar({
    super.key,
    required this.globalPositionSeconds,
    required this.totalDuration,
    required this.percentageText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Book Progress',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          Row(
            children: [
              Text(
                formatDuration(
                  Duration(seconds: globalPositionSeconds.toInt()),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' / ${formatDuration(totalDuration)} ',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              Text(
                '($percentageText)',
                style: TextStyle(
                  color: FluentTheme.of(context).accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
