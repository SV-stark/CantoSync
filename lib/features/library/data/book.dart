import 'package:isar/isar.dart';

part 'book.g.dart';

@collection
class Book {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? path;

  String? title;

  @Index()
  String? author;

  double? durationSeconds;
  double? positionSeconds;

  @Index()
  DateTime? lastPlayed;

  String? coverPath;
  String? album;

  @Index()
  String? series;

  int? seriesIndex;

  List<Bookmark>? bookmarks;
  List<String>? audioFiles;

  bool? isDirectory;

  int? lastTrackIndex;
  String? description;
  List<FileMetadata>? filesMetadata;

  @Index()
  String? narrator;

  List<String>? collections;

  Book({
    this.path,
    this.title,
    this.author,
    this.narrator,
    this.durationSeconds,
    this.positionSeconds,
    this.lastPlayed,
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
    this.lastPlayed ??= DateTime.now();
    this.bookmarks ??= [];
    this.audioFiles ??= [];
    this.collections ??= [];
  }
}

@embedded
class Bookmark {
  String? label;
  double? timestampSeconds;
  DateTime? createdAt;

  Bookmark({
    this.label,
    this.timestampSeconds,
    this.createdAt,
  }) {
    label ??= '';
    timestampSeconds ??= 0;
    createdAt ??= DateTime.now();
  }
}

@embedded
class FileMetadata {
  String? title;
  double? duration;
  String? path;

  FileMetadata({
    this.title,
    this.duration,
    this.path,
  }) {
    title ??= '';
    path ??= '';
  }
}
