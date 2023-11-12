/// This is a test file for [request_model]
///
/// Author: Kuo Wei Wu

import 'package:flutter_test/flutter_test.dart';
import 'package:specon/models/request_model.dart';
import 'package:specon/models/request_type.dart';

void main() async {
  test('request model return submission time', () async {
    RequestModel currentRequest = RequestModel(
        requestedBy: "test_RB",
        reason: "test_reason",
        assessedBy: "test_AB",
        assessment: RequestType(name: "assessment_name", id: "assessment_id"),
        state: "Open",
        requestedByStudentID: "0000",
        databasePath: "test_path",
        timeSubmitted: DateTime.utc(10, 10, 10),
        requestType: "test_RT",
        daysExtending: 0
    );
    final testResult = currentRequest.timeSinceSubmission();
    expect(testResult.isNotEmpty, true);
  });
}