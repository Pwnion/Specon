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
  String databasePath;
  DateTime timeSubmitted;
  final String requestType;
  final int daysExtending;

  RequestModel({
    required this.requestedBy,
    required this.reason,
    required this.additionalInfo,
    required this.assessedBy,
    required this.assessment,
    required this.state,
    required this.requestedByStudentID,
    required this.databasePath,
    required this.timeSubmitted,
    required this.requestType,
    required this.daysExtending
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
      'request_type': requestType,
      'days_extending': daysExtending
    };
  }

  static final emptyRequest = RequestModel(
    requestedBy: '',
    reason: '',
    additionalInfo: '',
    assessedBy: '',
    assessment:
    RequestType(
      name: '',
      type: '',
      id: ''
    ),
    state: '',
    requestedByStudentID: '',
    databasePath: '',
    timeSubmitted: DateTime.now(),
    requestType: '',
    daysExtending: 0
  );

  String timeSinceSubmission() {

    final difference = timeSubmitted.difference(DateTime.now());
    final seconds = (difference.inMilliseconds/1000).abs().round();
    final minutes = (difference.inMinutes).abs().round();
    final hours = (difference.inHours).abs().round();
    final days = (difference.inDays).abs().round();

    // Seconds
    if (seconds < 60) {
      return '${seconds}s';
    }
    // Minutes
    else if (minutes < 60){
      return '${minutes}m';
    }
    // Hours
    else if (hours < 24){
      return '${hours}h';
    }
    // Days
    else {
      return '${days}d';
    }
  }

}
