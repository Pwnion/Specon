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

  List<Map<String, dynamic>> getRequests(
      final String subjectID, UserModel user) {
    final List<Map<String, dynamic>> filteredByUserType;
    final List<Map<String, dynamic>> filteredBySubject =
        <Map<String, dynamic>>[];

    if (subjectID.isEmpty) return [];

    // Only show the student's request
    if (user.role == UserType.student) {
      filteredByUserType = allRequests.where((request) {
        return request['submittedBy'] == user.id;
      }).toList();
      // Show everything
    } else if (user.role == UserType.subjectCoordinator) {
      filteredByUserType = allRequests;
      // Show based on restrictions given by coordinator (Tutor, etc)
    } else {
      filteredByUserType =
          allRequests; // TODO: Determine which role gets to view what types of request
    }

    for (final request in filteredByUserType) {
      if (request['subject'] == subjectID) {
        filteredBySubject.add(request);
      }
    }

    return filteredBySubject;
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
