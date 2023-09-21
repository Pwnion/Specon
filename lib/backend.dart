import 'package:flutter/cupertino.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/models/userModel.dart';
import 'package:specon/user_type.dart';

import 'mock_data.dart';

class BackEnd extends ChangeNotifier {
  BackEnd._privateConstructor();

  static final BackEnd _instance = BackEnd._privateConstructor();

  factory BackEnd() {
    return _instance;
  }

  List<String> getAssessments(String subjectID) {
    return assessments;
  }

  List<String> getRequestStates() {
    return requestStates;
  }

  void accept(int requestID) {
    for (final request in allRequests) {
      if (request['requestID'] == requestID) {
        request['state'] = "Approved";
        notifyListeners();
      }
    }
  }

  void decline(int requestID) {
    for (final request in allRequests) {
      if (request['requestID'] == requestID) {
        request['state'] = "Declined";
        notifyListeners();
      }
    }
  }

  void flag(int requestID) {
    for (final request in allRequests) {
      if (request['requestID'] == requestID) {
        request['state'] = "Flagged";
      }
    }
  }
}
