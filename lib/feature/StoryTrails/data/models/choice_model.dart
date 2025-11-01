import 'package:real_english/feature/StoryTrails/domain/entities/single_choice_challenge.dart';
import 'package:hive/hive.dart';

part 'choice_model.g.dart';

@HiveType(typeId: 5) // Unique ID for ChoiceModel
class ChoiceModel extends Choice {
  const ChoiceModel({
    required super.id,
    required super.text,
    super.imageUrl,
    super.audioUrl,
  });

  factory ChoiceModel.fromJson(Map<String, dynamic> json) {
    return ChoiceModel(
      id: json['id'] as String,
      text: json['text'] as String,
      imageUrl: json['image_url'] as String?,
      audioUrl: json['audio_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'image_url': imageUrl,
      'audio_url': audioUrl,
    };
  }

  @override
  @HiveField(0)
  String get id => super.id;

  @override
  @HiveField(1)
  String get text => super.text;

  @override
  @HiveField(2)
  String? get imageUrl => super.imageUrl;

  @override
  @HiveField(3)
  String? get audioUrl => super.audioUrl;
}
