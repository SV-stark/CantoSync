import 'package:isar_community/isar.dart';

part 'book.g.dart';

@collection
class Book {
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
    this.internalChapters,
  }) {
    bookmarks ??= [];
    audioFiles ??= [];
    collections ??= [];
    internalChapters ??= [];
  }
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
  List<ChapterMetadata>? internalChapters;

  String get fileExtension {
    if (audioFiles != null && audioFiles!.isNotEmpty) {
      final file = audioFiles!.first;
      final dotIndex = file.lastIndexOf('.');
      if (dotIndex != -1 && dotIndex < file.length - 1) {
        return file.substring(dotIndex + 1).toLowerCase();
      }
    }
    if (path != null) {
      final dotIndex = path!.lastIndexOf('.');
      if (dotIndex != -1 && dotIndex < path!.length - 1) {
        return path!.substring(dotIndex + 1).toLowerCase();
      }
    }
    return '';
  }
}

@embedded
class Bookmark {
  Bookmark({this.label, this.timestampSeconds, this.createdAt}) {
    label ??= '';
    timestampSeconds ??= 0;
    createdAt ??= DateTime.now();
  }
  String? label;
  double? timestampSeconds;
  DateTime? createdAt;
}

@embedded
class FileMetadata {
  FileMetadata({this.title, this.duration, this.path}) {
    title ??= '';
    path ??= '';
  }
  String? title;
  double? duration;
  String? path;
}

@embedded
class ChapterMetadata {
  ChapterMetadata({this.title, this.startTime, this.endTime, this.coverPath}) {
    title ??= '';
    startTime ??= 0;
  }
  String? title;
  double? startTime;
  double? endTime;
  String? coverPath;
}
