import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String? id;
  final String requested_user_id;
  final String reason;
  final String additional_info;
  final String assessed_user_id;
  final String state;
  final String subject;

  const RequestModel({
    this.id,
    required this.requested_user_id,
    required this.reason,
    required this.additional_info,
    required this.assessed_user_id,
    required this.state,
    required this.subject,
  });

  Map<String, String> toJson() {
    return {
      'user': requested_user_id,
      'reason': reason,
      'additional_info': additional_info,
      'assessed_by_user': assessed_user_id,
      'state': state,
    };
  }

  factory RequestModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return RequestModel(
      id: document.id,
      requested_user_id: data['requested_user_id'],
      reason: data['reason'],
      additional_info: data['additional_info'],
      assessed_user_id: data['assessed_user_id'],
      state: data['status'],
      subject: data['subject'],
    );
  }
}
