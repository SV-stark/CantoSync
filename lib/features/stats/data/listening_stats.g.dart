// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listening_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyListeningStatsAdapter extends TypeAdapter<DailyListeningStats> {
  @override
  final int typeId = 3;

  @override
  DailyListeningStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyListeningStats(
      date: fields[0] as String,
      totalSecondsListened: fields[1] as int,
      booksListened: (fields[2] as List?)?.cast<String>(),
      listeningSessions: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyListeningStats obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.totalSecondsListened)
      ..writeByte(2)
      ..write(obj.booksListened)
      ..writeByte(3)
      ..write(obj.listeningSessions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyListeningStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AuthorStatsAdapter extends TypeAdapter<AuthorStats> {
  @override
  final int typeId = 4;

  @override
  AuthorStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthorStats(
      authorName: fields[0] as String,
      totalSecondsListened: fields[1] as int,
      booksCompleted: fields[2] as int,
      booksStarted: fields[3] as int,
      bookTitles: (fields[4] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AuthorStats obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.authorName)
      ..writeByte(1)
      ..write(obj.totalSecondsListened)
      ..writeByte(2)
      ..write(obj.booksCompleted)
      ..writeByte(3)
      ..write(obj.booksStarted)
      ..writeByte(4)
      ..write(obj.bookTitles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookCompletionStatsAdapter extends TypeAdapter<BookCompletionStats> {
  @override
  final int typeId = 5;

  @override
  BookCompletionStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookCompletionStats(
      bookPath: fields[0] as String,
      bookTitle: fields[1] as String,
      author: fields[2] as String?,
      completedDate: fields[3] as DateTime?,
      totalSecondsListened: fields[4] as int,
      startedDate: fields[5] as DateTime?,
      isCompleted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BookCompletionStats obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.bookPath)
      ..writeByte(1)
      ..write(obj.bookTitle)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.completedDate)
      ..writeByte(4)
      ..write(obj.totalSecondsListened)
      ..writeByte(5)
      ..write(obj.startedDate)
      ..writeByte(6)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookCompletionStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ListeningSpeedPreferenceAdapter
    extends TypeAdapter<ListeningSpeedPreference> {
  @override
  final int typeId = 6;

  @override
  ListeningSpeedPreference read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListeningSpeedPreference(
      averageSpeed: fields[0] as double,
      totalSessionsAtSpeed: fields[1] as int,
      speedUsageCount: (fields[2] as Map?)?.cast<double, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, ListeningSpeedPreference obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.averageSpeed)
      ..writeByte(1)
      ..write(obj.totalSessionsAtSpeed)
      ..writeByte(2)
      ..write(obj.speedUsageCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListeningSpeedPreferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
