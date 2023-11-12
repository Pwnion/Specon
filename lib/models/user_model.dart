import 'canvas_data_model.dart';

class UserModel {
  final String uuid;
  final String id;
  final String name;
  final String email;
  final String accessToken;
  final List<dynamic> subjects;
  String studentID;
  final CanvasData canvasData;
  final String selectedSubject;

  UserModel({
    required this.uuid,
    required this.id,
    required this.name,
    required this.email,
    required this.accessToken,
    required this.subjects,
    required this.studentID,
    required this.canvasData,
    required this.selectedSubject
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'subjects': subjects.toString(),
      'student_id': studentID
    };
  }
}
