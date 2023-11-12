/// This is a test file for [assessment_manager]
///
/// Author: Kuo Wei Wu

import 'package:flutter_test/flutter_test.dart';
import 'package:specon/models/request_type.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/page/assessment_manager_page.dart';


void main(){
  void emptyFunction(){}
  RequestType requestType = RequestType(name: "assessment_name", id: "assessment_id",);
  Map<String, dynamic> roles = {"test": "test"};
  SubjectModel subjectModel = SubjectModel(id: 0, name: "name", code: "code", assessments: [requestType], semester: "semester", year: "year", databasePath: "databasePath", roles: roles);
  AssessmentManager assessmentManager = AssessmentManager(subject: subjectModel, refreshFn: emptyFunction);

  // test starts here
  test('assessment manager widget test 1', () async{
      expect(assessmentManager.toString(), "AssessmentManager");
  });

  test('assessment manager widget test 2', () async{
    expect(assessmentManager.subject, subjectModel);
  });
}