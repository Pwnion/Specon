import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String? id;
  final String studentId;
  final String firstName;
  final String lastName;
  final String email;
  final String subject;
  final String reason;
  final String additionalInfo;

  const RequestModel({
    this.id,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.subject,
    required this.reason,
    required this.additionalInfo,
  });

  Map<String, String> toJson() {
    return {
      'student_id': studentId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'subject': subject,
      'reason': reason,
      'additional_info': additionalInfo,
    };
  }

  factory RequestModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document
  ) {
    final data = document.data()!;
    return RequestModel(
      id: document.id,
      studentId: data['student_id'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      email: data['email'],
      subject: data['subject'],
      reason: data['reason'],
      additionalInfo: data['additional_info'],
    );
  }
}
