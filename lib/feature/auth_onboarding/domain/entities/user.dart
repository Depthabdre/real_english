import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final int level;

  const User({required this.id, required this.fullName, required this.email , required this.level});

  @override
  List<Object?> get props => [id, fullName, email];
}
