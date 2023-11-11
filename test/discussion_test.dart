import 'package:flutter_test/flutter_test.dart';
import 'package:specon/models/canvas_data_model.dart';
import 'package:specon/models/request_model.dart';
import 'package:specon/models/request_type.dart';
import 'package:specon/models/user_model.dart';
import 'package:specon/page/dashboard/discussion_page.dart';

void incrementCounter(){}
void closeSubmittedRequest(){}

void discussionWidgetTest(){
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


  UserModel currentUser = UserModel(uuid: "uuid", id: "id", name: "name", email: "email", accessToken: "accessToken",
      subjects: ["subjects"], studentID: "studentID", canvasData: CanvasData.fromDB([]));



  testWidgets('test', (tester) async{
    tester.pumpWidget(Discussion(currentRequest: currentRequest, currentUser: currentUser,
        role: "", subjectCode: "test_SC", incrementCounter: incrementCounter,
        closeSubmittedRequest: closeSubmittedRequest));



  }
  );
}