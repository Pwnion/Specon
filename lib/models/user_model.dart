import 'package:specon/user_type.dart';

class UserModel {
  final String id;
  final String name;
  final String emailAddress;
  final List<dynamic> subjects;
  final String? aap;

  const UserModel({
    required this.id,
    required this.name,
    required this.emailAddress,
    required this.subjects,
    required this.aap,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': name,
      'email': emailAddress,
      'subjects': subjects.toString(),
      'aap': aap,
    };
  }
}
