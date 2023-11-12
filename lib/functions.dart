import 'package:cloud_functions/cloud_functions.dart';

final FirebaseFunctions _fn = FirebaseFunctions.instanceFor(
  region: 'australia-southeast2'
);

Future<String> refreshAccessToken(final String userUUID) async {
  final HttpsCallableResult response = await _fn.httpsCallable('refresh').call({
    'userUUID': userUUID
  });
  final data = response.data as Map<String, dynamic>;
  return data['access_token'];
}

Future<String> createAssignmentOverride(
  final String userId,
  final int courseId,
  final int assignmentId,
  final DateTime newDate,
  final String accessToken
) async {
  final HttpsCallableResult response = await _fn.httpsCallable('override').call({
    'userId': int.parse(userId),
    'courseId': courseId,
    'assignmentId': assignmentId,
    'newDate': newDate.toIso8601String(),
    'accessToken': accessToken
  });
  return response.data.toString();
}

Future<void> sendStudentRequestConsideredEmail(final String to) async {
  await _fn.httpsCallable('student').call({'to': to});
}

Future<void> sendStaffSummaryEmails() async {
  await _fn.httpsCallable('staff').call();
}