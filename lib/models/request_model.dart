/// Author: Jeremy Annal

class RequestModel {
  final String requestedBy;
  final String reason;
  final String additionalInfo;
  final String assessedBy;
  final String assessment;
  final String state;
  final String requestedByStudentID;

  const RequestModel(
      {required this.requestedBy,
      required this.reason,
      required this.additionalInfo,
      required this.assessedBy,
      required this.assessment,
      required this.state,
      required this.requestedByStudentID});

  Map<String, String> toJson() {
    return {
      'requested_by': requestedBy,
      'requested_by_student_id': requestedByStudentID,
      'reason': reason,
      'additional_info': additionalInfo,
      'assessed_by': assessedBy,
      'assessment': assessment,
      'state': state,
    };
  }
}
