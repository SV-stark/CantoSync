// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 0;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      path: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String?,
      durationSeconds: fields[3] as double?,
      positionSeconds: fields[4] as double?,
      lastPlayed: fields[5] as DateTime?,
      coverPath: fields[6] as String?,
      album: fields[7] as String?,
      series: fields[8] as String?,
      bookmarks: (fields[9] as List?)?.cast<Bookmark>(),
      audioFiles: (fields[10] as List?)?.cast<String>(),
      isDirectory: fields[11] as bool,
      lastTrackIndex: fields[12] as int?,
      description: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.positionSeconds)
      ..writeByte(5)
      ..write(obj.lastPlayed)
      ..writeByte(6)
      ..write(obj.coverPath)
      ..writeByte(7)
      ..write(obj.album)
      ..writeByte(8)
      ..write(obj.series)
      ..writeByte(9)
      ..write(obj.bookmarks)
      ..writeByte(10)
      ..write(obj.audioFiles)
      ..writeByte(11)
      ..write(obj.isDirectory)
      ..writeByte(12)
      ..write(obj.lastTrackIndex)
      ..writeByte(13)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookmarkAdapter extends TypeAdapter<Bookmark> {
  @override
  final int typeId = 1;

  @override
  Bookmark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bookmark(
      label: fields[0] as String,
      timestampSeconds: fields[1] as double,
      createdAt: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Bookmark obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.timestampSeconds)
      ..writeByte(2)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
