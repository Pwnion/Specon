/// This is a test file for [onboader]
///
/// Author: Kuo Wei Wu

import 'package:flutter_test/flutter_test.dart';
import 'package:specon/models/request_type.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/page/onboarder.dart';


void main(){
  RequestType requestType = RequestType(name: "assessment_name", id: "assessment_id",databasePath: "");
  Map<String, dynamic> roles = {"test": "test"};
  SubjectModel subjectModel = SubjectModel(id: 0, name: "name", code: "code", assessments: [requestType], semester: "semester", year: "year", databasePath: "databasePath", roles: roles);


  Onboarder onboarder = Onboarder(subject: subjectModel);

  // test start here
  test('onboarder widget test 1', () async{
    expect(onboarder.toString(), "Onboarder");
  });

  test('onboarder widget test 2', () async{
    expect(onboarder.subject, subjectModel);
  });
}