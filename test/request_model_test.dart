import 'package:flutter_test/flutter_test.dart';
import 'package:specon/models/request_model.dart';
import 'package:specon/models/request_type.dart';

void main() async {
  test('request model return submission time', () async {
    RequestModel currentRequest = RequestModel(
        requestedBy: "test_RB",
        reason: "test_reason",
        additionalInfo: "test_AI",
        assessedBy: "test_AB",
        assessment: RequestType(name: "assessment_name", type: "assessment_type", id: "assessment_id"),
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