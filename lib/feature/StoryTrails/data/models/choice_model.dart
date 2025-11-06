import 'package:real_english/feature/StoryTrails/domain/entities/single_choice_challenge.dart';

import 'package:hive/hive.dart';

part 'choice_model.g.dart';

@HiveType(typeId: 5)
class ChoiceModel extends Choice {
  const ChoiceModel({required super.id, required super.text, super.imageUrl});

  factory ChoiceModel.fromJson(Map<String, dynamic> json) {
    return ChoiceModel(
      id: json['id'] as String,
      text: json['text'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'image_url': imageUrl};
  }

  @override
  @HiveField(0)
  String get id => super.id;

  @override
  @HiveField(1)
  String get text => super.text;

  @override
  @HiveField(2) // --- UPDATED HIVEFIELD INDEX ---
  String? get imageUrl => super.imageUrl;
}
