import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String? id;
  final String studentId;
  final String firstName;
  final String lastName;
  final String emailAddress;
  final String subject;
  final String reason;

  const RequestModel({
    this.id,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.subject,
    required this.reason,
  });

  // toJson() {
  //   return {
  //     "StudentID": studentId,
  //     "FirstName": firstName,
  //     "LastName": lastName,
  //     "EmailAddress": emailAddress,
  //   };
  // }

  factory RequestModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return RequestModel(
      id: document.id,
      studentId: data["StudentID"],
      firstName: data["FirstName"],
      lastName: data["LastName"],
      emailAddress: data["EmailAddress"],
      subject: data["Subject"],
      reason: data['Reason'],
    );
  }
}
