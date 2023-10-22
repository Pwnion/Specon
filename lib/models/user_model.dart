import 'package:cloud_firestore/cloud_firestore.dart';

import 'canvas_data_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final List<dynamic> subjects;
  final String? aapPath;
  String studentID;
  final CanvasData canvasData;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.subjects,
    required this.aapPath,
    required this.studentID,
    required this.canvasData
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'subjects': subjects.toString(),
      'aap': aapPath,
      'student_id': studentID
    };
  }
}
