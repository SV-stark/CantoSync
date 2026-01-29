import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String path;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? author;

  @HiveField(3)
  double? durationSeconds;

  @HiveField(4)
  double? positionSeconds;

  @HiveField(5)
  late DateTime lastPlayed;

  @HiveField(6)
  String? coverPath;

  @HiveField(7)
  String? album;

  @HiveField(8)
  String? series;

  @HiveField(9)
  List<Bookmark>? bookmarks;

  @HiveField(10)
  List<String>? audioFiles;

  @HiveField(11)
  bool isDirectory;

  @HiveField(12)
  int? lastTrackIndex;

  @HiveField(13)
  String? description;

  Book({
    required this.path,
    required this.title,
    this.author,
    this.durationSeconds,
    this.positionSeconds,
    DateTime? lastPlayed,
    this.coverPath,
    this.album,
    this.series,
    this.bookmarks,
    this.audioFiles,
    this.isDirectory = false,
    this.lastTrackIndex,
    this.description,
  }) {
    this.lastPlayed = lastPlayed ?? DateTime.now();
    bookmarks ??= [];
    audioFiles ??= [];
  }
}

@HiveType(typeId: 1)
class Bookmark {
  @HiveField(0)
  final String label;

  @HiveField(1)
  final double timestampSeconds;

  @HiveField(2)
  final DateTime createdAt;

  Bookmark({
    required this.label,
    required this.timestampSeconds,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
