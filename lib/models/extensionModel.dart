import 'package:cloud_firestore/cloud_firestore.dart';
import 'requestModel.dart';

class ExtensionModel extends RequestModel {
  final String numDays;
  final String? id;
  //final String considerationType = "Extension";

  const ExtensionModel({
    this.id,
    required studentId,
    required firstName,
    required lastName,
    required emailAddress,
    required subject,
    required reason,
    required this.numDays,
    //required this.considerationType,
  }) : super(
          //id: id,
          studentId: studentId,
          firstName: firstName,
          lastName: lastName,
          emailAddress: emailAddress,
          subject: subject,
          reason: reason,
        );

  toJson() {
    return {
      "StudentID": studentId,
      "FirstName": firstName,
      "LastName": lastName,
      "EmailAddress": emailAddress,
      "Subject": subject,
      "Reason": reason,
      "NumberOfDays": numDays,
      "Type": "Extension",
    };
  }

  factory ExtensionModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ExtensionModel(
      id: document.id,
      studentId: data["StudentID"],
      firstName: data["FirstName"],
      lastName: data["LastName"],
      emailAddress: data["EmailAddress"],
      subject: data["Subject"],
      reason: data['Reason'],
      numDays: data['NumberOfDays'],
    );
  }
}
