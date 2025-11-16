// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_segment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StorySegmentModelAdapter extends TypeAdapter<StorySegmentModel> {
  @override
  final int typeId = 1;

  @override
  StorySegmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StorySegmentModel(
      id: fields[0] as String,
      type: fields[1] as SegmentType,
      textContent: fields[2] as String,
      imageUrl: fields[3] as String?,
      audioEndpoint: fields[4] as String?,
      challenge: fields[5] as Challenge?,
    );
  }

  @override
  void write(BinaryWriter writer, StorySegmentModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.textContent)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.audioEndpoint)
      ..writeByte(5)
      ..write(obj.challenge);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorySegmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
