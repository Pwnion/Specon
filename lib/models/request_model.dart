import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:specon/models/request_type.dart';

class RequestModel {
  final String requestedBy;
  final String reason;
  final String additionalInfo;
  final String assessedBy;
  final RequestType assessment;
  String state;
  final String requestedByStudentID;
  final String databasePath;

  RequestModel({
    required this.requestedBy,
    required this.reason,
    required this.additionalInfo,
    required this.assessedBy,
    required this.assessment,
    required this.state,
    required this.requestedByStudentID,
    required this.databasePath
  });

  Map<String, dynamic> toJson() {

    final db = FirebaseFirestore.instance;

    DocumentReference docRef = db.doc(assessment.id);

    return {
      'requested_by': requestedBy,
      'requested_by_student_id': requestedByStudentID,
      'reason': reason,
      'additional_info': additionalInfo,
      'assessed_by': assessedBy,
      'assessment': docRef,
      'state': state,
    };
  }
}
