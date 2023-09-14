import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String studentID;
  // TODO: Use better name because staff will have a staff number
  final String firstName;
  final String middleName;
  final String lastName;
  final String emailAddress;
  final String role;
  final List<String> subjects;

  const UserModel({
    this.id,
    required this.studentID,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.emailAddress,
    required this.role,
    required this.subjects,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentID,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'email': emailAddress,
      'role': role,
      'sujects': subjects,
    };
  }
}
