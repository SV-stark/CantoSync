import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String path;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? author;

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

  Book({
    required this.path,
    required this.title,
    this.author,
    this.durationSeconds,
    this.positionSeconds,
    DateTime? lastPlayed,
    this.coverPath,
    this.album,
  }) {
    this.lastPlayed = lastPlayed ?? DateTime.now();
  }
}
