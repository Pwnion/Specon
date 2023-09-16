import 'package:flutter/cupertino.dart';
import 'package:specon/user_type.dart';

import 'mock_data.dart';

class BackEnd extends ChangeNotifier{
  BackEnd._privateConstructor();

  static final BackEnd _instance = BackEnd._privateConstructor();

  factory BackEnd() {
    return _instance;
  }

  List<Map<String, dynamic>> getRequests(
    final String subjectID,
    final Map<String, dynamic> user
  ) {
    final List<Map<String, dynamic>> filteredByUserType;
    final List<Map<String, dynamic>> filteredBySubject = <Map<String, dynamic>>[];

    if (subjectID.isEmpty) return [];

    // Only show the student's request
    if (user['userType'] == UserType.student) {
      filteredByUserType = allRequests.where((request) {
        return request['submittedBy'] == user['userID'];
      }).toList();
    // Show everything
    } else if (user['userType'] == UserType.subjectCoordinator) {
      filteredByUserType = allRequests;
    // Show based on restrictions given by coordinator (Tutor, etc)
    } else {
      filteredByUserType = allRequests; // TODO: Determine which role gets to view what types of request
    }

    for(final request in filteredByUserType) {
      if(request['subject'] == subjectID) {
        filteredBySubject.add(request);
      }
    }

    return filteredBySubject;
  }

  List<String> getBasicFields(String subjectID) {
    return basicFieldTitles;
  }

  Map getTypesOfRequest(String subjectID) {
    return typesOfRequest;
    // return database[subjectID]['typesOfRequest'];
  }

  List<Map<String, String>> getSubjectList(String userID) {
    return subjectList;
  }

  List<String> getAssessments(String subjectID) {
    return assessments;
    // return database[subjectID]['assessments'];
  }

  List<String> getRequestStates() {
    return requestStates;
    // return database[subjectID]['assessments'];
  }

  void accept(int requestID){
    for(final request in allRequests){
      if(request['requestID'] == requestID){
        request['state'] = "Approved";
        notifyListeners();
      }
    }
  }
  void decline(int requestID){
    for(final request in allRequests){
      if(request['requestID'] == requestID){
        request['state'] = "Declined";
        notifyListeners();
      }
    }
  }
  void flag(int requestID){
    for(final request in allRequests){
      if(request['requestID'] == requestID){
        request['state'] = "Flagged";
        notifyListeners();
      }
    }
  }
}