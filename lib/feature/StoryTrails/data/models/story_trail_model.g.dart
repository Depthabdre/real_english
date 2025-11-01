// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_trail_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoryTrailModelAdapter extends TypeAdapter<StoryTrailModel> {
  @override
  final int typeId = 0;

  @override
  StoryTrailModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryTrailModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      imageUrl: fields[3] as String,
      difficultyLevel: fields[4] as int,
      segments: (fields[5] as List).cast<StorySegmentModel>(),
      userProgress: fields[6] as StoryProgress?,
    );
  }

  @override
  void write(BinaryWriter writer, StoryTrailModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.difficultyLevel)
      ..writeByte(5)
      ..write(obj.segments)
      ..writeByte(6)
      ..write(obj.userProgress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryTrailModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
