import 'dart:ui';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:canto_sync/features/library/data/book.dart';

class BookmarkFlyout extends StatelessWidget {
  final Book book;
  final List<Bookmark> bookmarks;
  final Duration currentPosition;
  final Function(Bookmark bookmark) onJumpToBookmark;
  final Function(Bookmark bookmark) onDeleteBookmark;
  final VoidCallback? onClose;

  const BookmarkFlyout({
    super.key,
    required this.book,
    required this.bookmarks,
    required this.currentPosition,
    required this.onJumpToBookmark,
    required this.onDeleteBookmark,
    this.onClose,
  });

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = FluentTheme.of(context).accentColor;
    final sortedBookmarks = List<Bookmark>.from(bookmarks)
      ..sort((a, b) => a.timestampSeconds.compareTo(b.timestampSeconds));

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 320,
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      FluentIcons.bookmarks,
                      color: accentColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bookmarks',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${sortedBookmarks.length}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                    if (onClose != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          FluentIcons.chrome_close,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 14,
                        ),
                        onPressed: onClose,
                      ),
                    ],
                  ],
                ),
              ),

              // Bookmark List
              Flexible(
                child: sortedBookmarks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: sortedBookmarks.length,
                        itemBuilder: (context, index) {
                          final bookmark = sortedBookmarks[index];
                          final isActive = (currentPosition.inSeconds -
                                      bookmark.timestampSeconds)
                                  .abs() <
                              2;

                          return _BookmarkListItem(
                            bookmark: bookmark,
                            isActive: isActive,
                            formattedTime: _formatDuration(bookmark.timestampSeconds),
                            formattedDate: _formatDate(bookmark.createdAt),
                            accentColor: accentColor,
                            onJump: () => onJumpToBookmark(bookmark),
                            onDelete: () => _showDeleteConfirmation(context, bookmark),
                          );
                        },
                      ),
              ),

              // Current Position Indicator
              if (sortedBookmarks.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FluentIcons.location,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current: ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(currentPosition.inSeconds.toDouble()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FluentIcons.bookmarks,
            size: 48,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add bookmarks to save your place',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Bookmark bookmark) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Delete Bookmark'),
        content: Text('Are you sure you want to delete "${bookmark.label}"?'),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
              onDeleteBookmark(bookmark);
            },
          ),
        ],
      ),
    );
  }
}

class _BookmarkListItem extends StatefulWidget {
  final Bookmark bookmark;
  final bool isActive;
  final String formattedTime;
  final String formattedDate;
  final Color accentColor;
  final VoidCallback onJump;
  final VoidCallback onDelete;

  const _BookmarkListItem({
    required this.bookmark,
    required this.isActive,
    required this.formattedTime,
    required this.formattedDate,
    required this.accentColor,
    required this.onJump,
    required this.onDelete,
  });

  @override
  State<_BookmarkListItem> createState() => _BookmarkListItemState();
}

class _BookmarkListItemState extends State<_BookmarkListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onJump,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.accentColor.withValues(alpha: 0.2)
                : _isHovered
                    ? Colors.white.withValues(alpha: 0.05)
                    : null,
            borderRadius: BorderRadius.circular(8),
            border: widget.isActive
                ? Border.all(
                    color: widget.accentColor.withValues(alpha: 0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Timestamp Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? widget.accentColor.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.formattedTime,
                  style: TextStyle(
                    color: widget.isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Consolas',
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Label and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.bookmark.label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.formattedDate,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              if (_isHovered || widget.isActive) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    FluentIcons.delete,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  onPressed: widget.onDelete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Convenience widget to show bookmark flyout as an overlay
class BookmarkFlyoutButton extends StatelessWidget {
  final Book book;
  final List<Bookmark> bookmarks;
  final Duration currentPosition;
  final Function(Bookmark bookmark) onJumpToBookmark;
  final Function(Bookmark bookmark) onDeleteBookmark;

  const BookmarkFlyoutButton({
    super.key,
    required this.book,
    required this.bookmarks,
    required this.currentPosition,
    required this.onJumpToBookmark,
    required this.onDeleteBookmark,
  });

  void _showBookmarkFlyout(BuildContext context) {
    final flyoutController = FlyoutController();
    
    flyoutController.showFlyout(
      builder: (context) {
        return BookmarkFlyout(
          book: book,
          bookmarks: bookmarks,
          currentPosition: currentPosition,
          onJumpToBookmark: (bookmark) {
            flyoutController.close();
            onJumpToBookmark(bookmark);
          },
          onDeleteBookmark: onDeleteBookmark,
          onClose: () => flyoutController.close(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final flyoutController = FlyoutController();
    
    return FlyoutTarget(
      controller: flyoutController,
      child: IconButton(
        icon: const Icon(FluentIcons.bookmarks),
        onPressed: () => _showBookmarkFlyout(context),
      ),
    );
  }
}
