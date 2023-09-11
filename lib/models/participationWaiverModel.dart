// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'requestModel.dart';

// class ParticipationWaiverModel extends RequestModel {
//   final String myClass;
//   @override
//   // ignore: overridden_fields
//   final String? id;

//   //final String considerationType = "Extension";

//   const ParticipationWaiverModel({
//     this.id,
//     required studentId,
//     required firstName,
//     required lastName,
//     required emailAddress,
//     required subject,
//     required reason,
//     required this.myClass,
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
//       "MyClass": myClass,
//       "Type": "ChangeTute",
//     };
//   }

//   factory ParticipationWaiverModel.fromSnapshot(
//       DocumentSnapshot<Map<String, dynamic>> document) {
//     final data = document.data()!;
//     return ParticipationWaiverModel(
//       id: document.id,
//       studentId: data["StudentID"],
//       firstName: data["FirstName"],
//       lastName: data["LastName"],
//       emailAddress: data["EmailAddress"],
//       subject: data["Subject"],
//       reason: data['Reason'],
//       myClass: data['MyClass'],
//     );
//   }
// }
