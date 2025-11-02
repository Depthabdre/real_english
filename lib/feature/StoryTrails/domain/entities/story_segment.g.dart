// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_segment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SegmentTypeAdapter extends TypeAdapter<SegmentType> {
  @override
  final int typeId = 2;

  @override
  SegmentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SegmentType.narration;
      case 1:
        return SegmentType.choiceChallenge;
      case 2:
        return SegmentType.audioChallenge;
      case 3:
        return SegmentType.speechChallenge;
      case 4:
        return SegmentType.dragDropChallenge;
      default:
        return SegmentType.narration;
    }
  }

  @override
  void write(BinaryWriter writer, SegmentType obj) {
    switch (obj) {
      case SegmentType.narration:
        writer.writeByte(0);
        break;
      case SegmentType.choiceChallenge:
        writer.writeByte(1);
        break;
      case SegmentType.audioChallenge:
        writer.writeByte(2);
        break;
      case SegmentType.speechChallenge:
        writer.writeByte(3);
        break;
      case SegmentType.dragDropChallenge:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SegmentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
