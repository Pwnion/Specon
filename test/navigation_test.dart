/// This is a test file for [navigation_page]
///
/// Author: Kuo Wei Wu

import 'package:flutter_test/flutter_test.dart';
import 'package:specon/models/canvas_data_model.dart';
import 'package:specon/models/request_model.dart';
import 'package:specon/models/request_type.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/models/user_model.dart';
import 'package:specon/page/dashboard/navigation_page.dart';

void incrementCounter(){}
void closeSubmittedRequest(){}

void main() async{
  RequestType requestType = RequestType(name: "assessment_name", id: "assessment_id",);
  Map<String, dynamic> roles = {"test": "test"};

  void setCurrentSubject(SubjectModel subjectModel){
  }
  void setSelectedAssessment(String string){}

  void openNewRequestForm() {
  }
  String getSelectedAssessment(){
    return "";
  }
  void setRole(SubjectModel subjectModel, UserModel userModel){}

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

  Navigation navigation = Navigation(openNewRequestForm: openNewRequestForm, setCurrentSubject: setCurrentSubject, subjectList: [subjectModel], currentUser: currentUser, currentSubject: subjectModel,
    setSelectedAssessment: setSelectedAssessment, getSelectedAssessment: getSelectedAssessment, role: "role", setRole: setRole);

  // test start here
  test('Navigation widget test 1', () async{
    expect(navigation.toString(), "Navigation");
  });

  test('Navigation widget test 2', () async{
    expect(navigation.role, "role");
  });

  test('Navigation widget test 3', () async{
    expect(navigation.currentUser, currentUser);
  });
}