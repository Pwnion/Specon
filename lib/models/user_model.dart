import 'package:specon/user_type.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final List<dynamic> subjects;
  final String? aap_path;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.subjects,
    required this.aap_path,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': name,
      'email': email,
      'subjects': subjects.toString(),
      'aap': aap_path,
    };
  }
}
