import 'package:cloud_functions/cloud_functions.dart';

final FirebaseFunctions _fn = FirebaseFunctions.instanceFor(
  region: 'australia-southeast2'
);

Future<String> createAssignmentOverride(
  final String userId,
  final int courseId,
  final int assignmentId,
  final DateTime newDate,
  final String accessToken
) async {
  final HttpsCallableResult response = await _fn.httpsCallable('assignmentOverride').call({
    'userId': int.parse(userId),
    'courseId': courseId,
    'assignmentId': assignmentId,
    'newDate': newDate.toIso8601String(),
    'accessToken': accessToken
  });
  return response.data.toString();
}