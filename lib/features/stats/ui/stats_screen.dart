import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canto_sync/features/stats/data/stats_service.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(listeningStatsProvider);

    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Listening Statistics'),
      ),
      content: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(context, stats),
              const SizedBox(height: 24),
              _buildStreakSection(context, stats),
              const SizedBox(height: 24),
              _buildContributionCalendar(context, stats),
              const SizedBox(height: 24),
              _buildTopAuthorsSection(context, stats),
              const SizedBox(height: 24),
              _buildSpeedPreferenceCard(context, stats),
            ],
          ),
        ),
        loading: () => const Center(child: ProgressRing()),
        error: (err, stack) => Center(
          child: Text('Error loading stats: $err'),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, ListeningStatsSummary stats) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          context,
          icon: FluentIcons.clock,
          title: 'Total Hours',
          value: stats.totalHoursListened.toStringAsFixed(1),
          subtitle: 'of audiobooks listened',
          color: Colors.blue,
        ),
        _buildStatCard(
          context,
          icon: FluentIcons.completed,
          title: 'Books Completed',
          value: stats.totalBooksCompleted.toString(),
          subtitle: 'out of ${stats.totalBooksStarted} started',
          color: Colors.successPrimaryColor,
        ),
        _buildStatCard(
          context,
          icon: FluentIcons.calendar_day,
          title: 'Current Streak',
          value: '${stats.currentStreak} days',
          subtitle: 'Longest: ${stats.longestStreak} days',
          color: Colors.orange,
        ),
        _buildStatCard(
          context,
          icon: FluentIcons.play_resume,
          title: 'Sessions',
          value: stats.totalListeningSessions.toString(),
          subtitle: 'total listening sessions',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: FluentTheme.of(context).typography.caption,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: FluentTheme.of(context).typography.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: FluentTheme.of(context).typography.caption?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context, ListeningStatsSummary stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Listening Streak',
              style: FluentTheme.of(context).typography.subtitle,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStreakIndicator(
                    context,
                    label: 'Current Streak',
                    days: stats.currentStreak,
                    icon: FluentIcons.brightness,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStreakIndicator(
                    context,
                    label: 'Longest Streak',
                    days: stats.longestStreak,
                    icon: FluentIcons.trophy,
                    color: Colors.yellow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakIndicator(
    BuildContext context, {
    required String label,
    required int days,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FluentTheme.of(context).typography.caption?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(
                '$days days',
                style: FluentTheme.of(context).typography.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContributionCalendar(BuildContext context, ListeningStatsSummary stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Listening Activity',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                Text(
                  'Last 30 Days',
                  style: FluentTheme.of(context).typography.caption?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ContributionCalendar(dailyStats: stats.last30Days),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Less',
                  style: FluentTheme.of(context).typography.caption?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(width: 8),
                _buildLegendBox(Colors.grey.withAlpha(26)),
                const SizedBox(width: 4),
                _buildLegendBox(Colors.blue.withAlpha(77)),
                const SizedBox(width: 4),
                _buildLegendBox(Colors.blue.withAlpha(128)),
                const SizedBox(width: 4),
                _buildLegendBox(Colors.blue.withAlpha(179)),
                const SizedBox(width: 4),
                _buildLegendBox(Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'More',
                  style: FluentTheme.of(context).typography.caption?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTopAuthorsSection(BuildContext context, ListeningStatsSummary stats) {
    if (stats.topAuthors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Authors',
              style: FluentTheme.of(context).typography.subtitle,
            ),
            const SizedBox(height: 16),
            ...stats.topAuthors.asMap().entries.map((entry) {
              final index = entry.key;
              final author = entry.value;
              return _buildAuthorRow(context, index + 1, author);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorRow(BuildContext context, int rank, author) {
    final progressColor = _getRankColor(rank);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: progressColor.withAlpha(26),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.authorName,
                  style: FluentTheme.of(context).typography.body?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${author.totalHours.toStringAsFixed(1)} hours • ${author.booksCompleted} completed',
                  style: FluentTheme.of(context).typography.caption?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _buildSpeedPreferenceCard(BuildContext context, ListeningStatsSummary stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(FluentIcons.speed_high, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Average Listening Speed',
                    style: FluentTheme.of(context).typography.body?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your preferred playback speed',
                    style: FluentTheme.of(context).typography.caption?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${stats.averageListeningSpeed.toStringAsFixed(2)}x',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributionCalendar extends StatelessWidget {
  final List<dynamic> dailyStats;

  const _ContributionCalendar({required this.dailyStats});

  @override
  Widget build(BuildContext context) {
    // Group by weeks
    final weeks = <List<dynamic>>[];
    var currentWeek = <dynamic>[];

    for (final day in dailyStats) {
      currentWeek.add(day);
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }

    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day labels
        Row(
          children: [
            const SizedBox(width: 32),
            ...['Mon', 'Wed', 'Fri'].map((day) => Expanded(
                  child: Text(
                    day,
                    style: FluentTheme.of(context).typography.caption?.copyWith(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                    textAlign: TextAlign.center,
                  ),
                )),
          ],
        ),
        const SizedBox(height: 4),
        // Calendar grid
        Row(
          children: weeks.map((week) {
            return Expanded(
              child: Column(
                children: week.map((day) {
                  return _buildDayCell(context, day);
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDayCell(BuildContext context, dynamic day) {
    final seconds = day.totalSecondsListened ?? 0;
    final color = _getActivityColor(seconds);
    final date = DateTime.parse(day.date);
    final tooltip = '${DateFormat('MMM d').format(date)}: ${_formatDuration(seconds)}';

    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.all(2),
        height: 20,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Color _getActivityColor(int seconds) {
    if (seconds == 0) return Colors.grey.withAlpha(26);
    if (seconds < 1800) return Colors.blue.withAlpha(77); // < 30 min
    if (seconds < 3600) return Colors.blue.withAlpha(128); // < 1 hour
    if (seconds < 7200) return Colors.blue.withAlpha(179); // < 2 hours
    return Colors.blue;
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return 'No listening';
    if (seconds < 60) return '$seconds sec';
    if (seconds < 3600) return '${(seconds / 60).floor()} min';
    final hours = (seconds / 3600).floor();
    final mins = ((seconds % 3600) / 60).floor();
    return '${hours}h ${mins}m';
  }
}
