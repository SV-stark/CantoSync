// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_shortcuts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KeyboardShortcutAdapter extends TypeAdapter<KeyboardShortcut> {
  @override
  final int typeId = 7;

  @override
  KeyboardShortcut read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KeyboardShortcut(
      action: fields[0] as String,
      keyValue: fields[1] as String,
      ctrl: fields[2] as bool,
      alt: fields[3] as bool,
      shift: fields[4] as bool,
      description: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KeyboardShortcut obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.action)
      ..writeByte(1)
      ..write(obj.keyValue)
      ..writeByte(2)
      ..write(obj.ctrl)
      ..writeByte(3)
      ..write(obj.alt)
      ..writeByte(4)
      ..write(obj.shift)
      ..writeByte(5)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyboardShortcutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
