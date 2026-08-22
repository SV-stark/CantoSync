import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:canto_sync/features/library/data/book.dart';

class CoverArtWithReflection extends StatelessWidget {
  const CoverArtWithReflection({
    super.key,
    required this.book,
    required this.size,
    this.showReflection = true,
  });
  final Book? book;
  final double size;
  final bool showReflection;

  @override
  Widget build(BuildContext context) {
    final imageProvider = book?.coverPath != null
        ? FileImage(File(book!.coverPath!))
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Cover Art
        Hero(
          tag: 'player_cover',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: imageProvider != null
                  ? Image(image: imageProvider, fit: BoxFit.cover)
                  : const Icon(
                      FluentIcons.music_in_collection,
                      size: 80,
                      color: Colors.grey,
                    ),
            ),
          ),
        ),

        if (showReflection) ...[
          const SizedBox(height: 8),
          // Reflection
          Container(
            width: size * 0.9,
            height: size * 0.15,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: imageProvider != null
                  ? Transform(
                      alignment: Alignment.topCenter,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.003)
                        ..setEntry(1, 1, -0.3),
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Image(image: imageProvider, fit: BoxFit.cover),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ],
    );
  }
}
