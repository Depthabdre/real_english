// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoryProgressModelAdapter extends TypeAdapter<StoryProgressModel> {
  @override
  final int typeId = 6;

  @override
  StoryProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryProgressModel(
      storyTrailId: fields[0] as String,
      currentSegmentIndex: fields[1] as int,
      modelChallengeAttempts:
          (fields[2] as Map).cast<String, ChallengeAttemptModel>(),
      isCompleted: fields[3] as bool,
      completionDate: fields[4] as DateTime?,
      xpEarned: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StoryProgressModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(2)
      ..write(obj.modelChallengeAttempts)
      ..writeByte(0)
      ..write(obj.storyTrailId)
      ..writeByte(1)
      ..write(obj.currentSegmentIndex)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.completionDate)
      ..writeByte(5)
      ..write(obj.xpEarned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
