import 'package:cloud_firestore/cloud_firestore.dart';
import 'requestModel.dart';

class OtherReasonModel extends RequestModel {
  final String what;
  //final String considerationType = "Extension";

  const OtherReasonModel({
    required id,
    required studentId,
    required firstName,
    required lastName,
    required emailAddress,
    required subject,
    required reason,
    required this.what,
    //required this.considerationType,
  }) : super(
          id: id,
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
      "What": what,
      "Type": "ChangeTute",
    };
  }

  factory OtherReasonModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return OtherReasonModel(
      id: document.id,
      studentId: data["StudentID"],
      firstName: data["FirstName"],
      lastName: data["LastName"],
      emailAddress: data["EmailAddress"],
      subject: data["Subject"],
      reason: data['Reason'],
      what: data['What'],
    );
  }
}
