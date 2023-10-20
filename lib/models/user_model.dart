import 'package:specon/user_type.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final List<dynamic> subjects;
  final String? aapPath;
  String studentID;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.subjects,
    required this.aapPath,
    required this.studentID
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'subjects': subjects.toString(),
      'aap': aapPath,
    };
  }
}
