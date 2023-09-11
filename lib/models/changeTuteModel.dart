// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'requestModel.dart';

// class ChangeTuteModel extends RequestModel {
//   final String fromClass;
//   final String toClass;
//   final String? id;
//   //final String considerationType = "Extension";

//   const ChangeTuteModel({
//     this.id,
//     required studentId,
//     required firstName,
//     required lastName,
//     required emailAddress,
//     required subject,
//     required reason,
//     required this.fromClass,
//     required this.toClass,
//     //required this.considerationType,
//   }) : super(
//           studentId: studentId,
//           firstName: firstName,
//           lastName: lastName,
//           emailAddress: emailAddress,
//           subject: subject,
//           reason: reason,
//         );

//   toJson() {
//     return {
//       "StudentID": studentId,
//       "FirstName": firstName,
//       "LastName": lastName,
//       "EmailAddress": emailAddress,
//       "Subject": subject,
//       "Reason": reason,
//       "FromClass": fromClass,
//       "ToClass": toClass,
//       "Type": "ChangeTute",
//     };
//   }

//   factory ChangeTuteModel.fromSnapshot(
//       DocumentSnapshot<Map<String, dynamic>> document) {
//     final data = document.data()!;
//     return ChangeTuteModel(
//       id: document.id,
//       studentId: data["StudentID"],
//       firstName: data["FirstName"],
//       lastName: data["LastName"],
//       emailAddress: data["EmailAddress"],
//       subject: data["Subject"],
//       reason: data['Reason'],
//       fromClass: data['FromClass'],
//       toClass: data['ToClass'],
//     );
//   }
// }
