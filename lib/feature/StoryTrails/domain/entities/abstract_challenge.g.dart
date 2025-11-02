// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abstract_challenge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeTypeAdapter extends TypeAdapter<ChallengeType> {
  @override
  final int typeId = 3;

  @override
  ChallengeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChallengeType.singleChoice;
      case 1:
        return ChallengeType.imageChoice;
      case 2:
        return ChallengeType.audioSelection;
      case 3:
        return ChallengeType.textInput;
      case 4:
        return ChallengeType.speechRecognition;
      case 5:
        return ChallengeType.dragAndDrop;
      default:
        return ChallengeType.singleChoice;
    }
  }

  @override
  void write(BinaryWriter writer, ChallengeType obj) {
    switch (obj) {
      case ChallengeType.singleChoice:
        writer.writeByte(0);
        break;
      case ChallengeType.imageChoice:
        writer.writeByte(1);
        break;
      case ChallengeType.audioSelection:
        writer.writeByte(2);
        break;
      case ChallengeType.textInput:
        writer.writeByte(3);
        break;
      case ChallengeType.speechRecognition:
        writer.writeByte(4);
        break;
      case ChallengeType.dragAndDrop:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
