// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_learning_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserLearningProfileModelAdapter
    extends TypeAdapter<UserLearningProfileModel> {
  @override
  final int typeId = 8;

  @override
  UserLearningProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserLearningProfileModel(
      userId: fields[0] as String,
      currentLearningLevel: fields[1] as int,
      xpGlobal: fields[2] as int,
      completedTrailIds: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserLearningProfileModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.currentLearningLevel)
      ..writeByte(2)
      ..write(obj.xpGlobal)
      ..writeByte(3)
      ..write(obj.completedTrailIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLearningProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
