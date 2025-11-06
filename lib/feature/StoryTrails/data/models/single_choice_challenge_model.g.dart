// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_choice_challenge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SingleChoiceChallengeModelAdapter
    extends TypeAdapter<SingleChoiceChallengeModel> {
  @override
  final int typeId = 4;

  @override
  SingleChoiceChallengeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SingleChoiceChallengeModel(
      id: fields[0] as String,
      prompt: fields[1] as String,
      choices: (fields[3] as List).cast<ChoiceModel>(),
      correctAnswerId: fields[4] as String,
      correctFeedback: fields[5] as String?,
      incorrectFeedback: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SingleChoiceChallengeModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.prompt)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.choices)
      ..writeByte(4)
      ..write(obj.correctAnswerId)
      ..writeByte(5)
      ..write(obj.correctFeedback)
      ..writeByte(6)
      ..write(obj.incorrectFeedback);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SingleChoiceChallengeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
