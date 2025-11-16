// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_completion_status_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LevelCompletionStatusModelAdapter
    extends TypeAdapter<LevelCompletionStatusModel> {
  @override
  final int typeId = 9;

  @override
  LevelCompletionStatusModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LevelCompletionStatusModel(
      didLevelUp: fields[0] as bool,
      newLevel: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LevelCompletionStatusModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.didLevelUp)
      ..writeByte(1)
      ..write(obj.newLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelCompletionStatusModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
