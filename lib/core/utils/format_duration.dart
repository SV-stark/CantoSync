String formatDuration(Duration d) {
  if (d.inHours > 0) {
    return '${d.inHours}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
  return '${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
}

String formatDurationSeconds(double seconds) {
  final duration = Duration(seconds: seconds.toInt());
  if (duration.inHours > 0) {
    return '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
  return '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
}

String formatDurationVerbose(double? seconds) {
  if (seconds == null) return 'Unknown';
  final duration = Duration(seconds: seconds.toInt());
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final secs = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '${hours}h ${minutes}m ${secs}s';
  } else {
    return '${minutes}m ${secs}s';
  }
}
