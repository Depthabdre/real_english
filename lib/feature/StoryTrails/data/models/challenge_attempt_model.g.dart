// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_attempt_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeAttemptModelAdapter extends TypeAdapter<ChallengeAttemptModel> {
  @override
  final int typeId = 7;

  @override
  ChallengeAttemptModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeAttemptModel(
      challengeId: fields[0] as String,
      userAnswer: fields[1] as String,
      isCorrect: fields[2] as bool,
      attemptDate: fields[3] as DateTime,
      feedbackMessage: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeAttemptModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.challengeId)
      ..writeByte(1)
      ..write(obj.userAnswer)
      ..writeByte(2)
      ..write(obj.isCorrect)
      ..writeByte(3)
      ..write(obj.attemptDate)
      ..writeByte(4)
      ..write(obj.feedbackMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeAttemptModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
