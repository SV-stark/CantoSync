import 'dart:io';
import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:canto_sync/features/library/data/book.dart';

class CoverArtWithReflection extends StatelessWidget {
  final Book? book;
  final double size;
  final bool showReflection;

  const CoverArtWithReflection({
    super.key,
    required this.book,
    required this.size,
    this.showReflection = true,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.black.withAlpha(102),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: book?.coverPath != null
                  ? Image.file(File(book!.coverPath!), fit: BoxFit.cover)
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
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: book?.coverPath != null
                  ? Transform(
                      alignment: Alignment.topCenter,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.003)
                        ..setEntry(1, 1, -0.3),
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return material.LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withAlpha(128),
                              Colors.transparent,
                            ],
                          ).createShader(bounds);
                        },
                        blendMode: material.BlendMode.dstIn,
                        child: Image.file(
                          File(book!.coverPath!),
                          fit: BoxFit.cover,
                        ),
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
