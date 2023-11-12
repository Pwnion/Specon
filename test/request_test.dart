/// This is a test file for [request_page]
///
/// Author: Kuo Wei Wu

import 'package:flutter_test/flutter_test.dart';
import 'package:specon/models/canvas_data_model.dart';
import 'package:specon/models/request_model.dart';
import 'package:specon/models/request_type.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/models/user_model.dart';
import 'package:specon/page/dashboard/requests_page.dart';
import 'package:specon/user_type.dart';


void incrementCounter(){}
void closeSubmittedRequest(){}

void main() async{
  RequestType requestType = RequestType(name: "assessment_name", id: "assessment_id",);
  Map<String, dynamic> roles = {"test": "test"};

  SubjectModel getCS(){
    SubjectModel subjectModel = SubjectModel(id: 0, name: "name", code: "code", assessments: [requestType], semester: "semester", year: "year", databasePath: "databasePath", roles: roles);

    return subjectModel;
  }

  void openSubmittedRequest(RequestModel request) {
  }

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
  SubjectModel subjectModel = SubjectModel(id: 0, name: "name", code: "code", assessments: [requestType], semester: "semester", year: "year", databasePath: "databasePath", roles: roles);
  UserModel currentUser = UserModel(uuid: "uuid", id: "id", name: "name", email: "email", accessToken: "accessToken", selectedSubject: "0",
      subjects: ["subjects"], studentID: "studentID", canvasData: CanvasData.fromDB([]));

  Requests requests = Requests(getCurrentSubject: getCS, openSubmittedRequest: openSubmittedRequest,
      currentUser: currentUser, selectedAssessment: "selectedAssessment", role: UserType.student, counter: 1, selectedRequest: RequestModel.emptyRequest);

  // test starts here
  test('request widget test 1', () async{
    expect(requests.toString(), "Requests");
  });

  test('request widget test 2', () async{
    expect(requests.role, UserType.student);
  });

  test('request widget test 3', () async{
    expect(requests.counter, 1);
  });
}