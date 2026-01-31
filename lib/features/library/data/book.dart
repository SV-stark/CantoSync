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

  @HiveField(17)
  int? seriesIndex;

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

  @HiveField(14)
  List<FileMetadata>? filesMetadata;

  @HiveField(15)
  String? narrator;

  @HiveField(16)
  List<String>? collections;

  Book({
    required this.path,
    required this.title,
    this.author,
    this.narrator,
    this.durationSeconds,
    this.positionSeconds,
    DateTime? lastPlayed,
    this.coverPath,
    this.album,
    this.series,
    this.seriesIndex,
    this.bookmarks,
    this.audioFiles,
    this.isDirectory = false,
    this.lastTrackIndex,
    this.description,
    this.filesMetadata,
    this.collections,
  }) {
    this.lastPlayed = lastPlayed ?? DateTime.now();
    bookmarks ??= [];
    audioFiles ??= [];
    collections ??= [];
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

@HiveType(typeId: 2)
class FileMetadata {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final double? duration;

  @HiveField(2)
  final String path;

  FileMetadata({required this.title, this.duration, required this.path});
}
