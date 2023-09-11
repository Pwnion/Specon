import 'package:flutter/cupertino.dart';
import 'package:specon/user_type.dart';

class BackEnd extends ChangeNotifier{

  BackEnd._privateConstructor();

  static final BackEnd _instance = BackEnd._privateConstructor();

  factory BackEnd() {
    return _instance;
  }

  Map database =
  {'COMP30022':
    {'requests':
      [
        {"requestID": 1, "submittedBy": 1, "name": 'Alex', "assessment": "Project 1", 'status': 'approved'},
        {"requestID": 2, "submittedBy": 1, "name": 'Bob', "assessment": "Project 2", 'status': 'pending'},
        {"requestID": 3, "submittedBy": 2, "name": 'Aren', "assessment": "Final Exam", 'status': 'pending'},
      ],

    'typesOfRequest':
      {
        "Participation Waiver": {'fields': ["Class", "Reason"], 'allowedToView': ["Tutor"]},

        "Due date extension": {'fields': ["How long", "Reason"], 'allowedToView': ["Tutor"]},

        "Change tutorial": {'fields': ["From Class", "To Class", "Reason"], 'allowedToView': []},

        "Others": {'fields': ["What", "Why"], 'allowedToView': []},
      },

    'assessments':
      [
        "All",
        "Project 1",
        "Project 2",
        "Final Exam",
        "Mid Semester Exam",
      ]
    }
  };

  List allRequests = [
    {"requestID": 1, "submittedBy": 1, "name": 'Alex', "subject": "COMP30023", "type": "Project 1", "state": "unassessed"},
    {"requestID": 2, "submittedBy": 1, "name": 'Bob', "subject": "COMP30019", "type": "Project 2", "state": "unassessed"},
    {"requestID": 3, "submittedBy": 2, "name": 'Aren', "subject": "COMP30022", "type": "Final Exam", "state": "unassessed"},
    {"requestID": 4, "submittedBy": 1, "name": 'Aden', "subject": "COMP30023", "type": "Mid Semester Exam", "state": "unassessed"},
    {"requestID": 5, "submittedBy": 1, "name": 'Lo', "subject": "COMP30020", "type": "Project 1", "state": "unassessed"},
    {"requestID": 6, "submittedBy": 1, "name": 'Harry', "subject": "COMP30019", "type": "Project 2", "state": "unassessed"},
    {"requestID": 7, "submittedBy": 1, "name": 'Drey', "subject": "COMP30022", "type": "Project 2", "state": "unassessed"},
    {"requestID": 8, "submittedBy": 1, "name": 'Brian', "subject": "COMP30023", "type": "Final Exam", "state": "unassessed"},
    {"requestID": 9, "submittedBy": 1, "name": 'David', "subject": "COMP30019", "type": "Project 1", "state": "unassessed"},
    {"requestID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1", "state": "unassessed"},
    {"requestID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1", "state": "unassessed"},
    {"requestID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1", "state": "unassessed"},
    {"requestID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1", "state": "unassessed"},
    {"requestID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1", "state": "unassessed"},
    {"requestID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1", "state": "unassessed"},
    {"requestID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1", "state": "unassessed"},
    {"requestID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1", "state": "unassessed"},
    {"requestID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1", "state": "unassessed"},
    {"requestID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1", "state": "unassessed"},
  ];

  List<Map<String, String>> subjectList = [
    {'code': 'COMP10001', 'name': 'Foundations of Computing'},
    {'code': 'COMP10002', 'name': 'Foundations of Algorithms'},
    {'code': 'COMP20003', 'name': 'Algorithms and Data Structures'},
    {'code': 'COMP20005', 'name': 'Intro. to Numerical Computation in C'},
    {'code': 'COMP20007', 'name': 'Design of Algorithms'},
    {'code': 'COMP20008', 'name': 'Elements of Data Processing'},
    {'code': 'SWEN20003', 'name': 'Object Oriented Software Development'},
    {'code': 'COMP30013', 'name': 'Advanced Studies in Computing'},
    {'code': 'COMP30019', 'name': 'Graphics and Interaction'},
    {'code': 'COMP30020', 'name': 'Declarative Programming'},
    {'code': 'COMP30022', 'name': 'IT Project'},
    {'code': 'COMP30023', 'name': 'Computer Systems'},
    {'code': 'COMP30024', 'name': 'Artificial Intelligence'},
    {'code': 'COMP30026', 'name': 'Models of Computation'},
    {'code': 'COMP30027', 'name': 'Machine Learning'},
    {'code': 'SWEN30006', 'name': 'Software Modelling and Design'},
  ];

  Map typesOfRequest = {
    "Participation Waiver":
      {'fields': ["Class", "Reason"],
       'allowedToView': ["Tutor"]},

    "Due date extension":
      {'fields': ["How long", "Reason"],
      'allowedToView': ["Tutor"]},

    "Change tutorial":
      {'fields': ["From Class", "To Class", "Reason"],
      'allowedToView': []},

    "Others":
      {'fields': ["What", "Why"],
      'allowedToView': []},
  };

  List<String> basicFieldTitles = [
  "Given Name",
  "Last Name",
  "Email",
  "Student ID",
  "Subject"
  ];

  List<String> assessments = [
    "All",
    "Project 1",
    "Project 2",
    "Final Exam",
    "Mid Semester Exam",
  ];

  List getRequests(String subjectID, Map user) {

    List filteredByUserType = [];
    List filteredBySubject = [];

    if (subjectID == '') return [];

    // Only show the student's request
    if (user['userType'] == UserType.student) {
      filteredByUserType = allRequests.where((request) =>
      request['submittedBy'] == user['userID']).toList();

      // Show everything
    } else if (user['userType'] == UserType.subjectCoordinator) {
      filteredByUserType = allRequests;

      // Show based on restrictions given by coordinator (Tutor, etc)
    } else {
      // TODO: Determine which role gets to view what types of request
    }

    filteredBySubject = [];
    for (var request in filteredByUserType) {
      if (request['subject'] == subjectID) {
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

  void accept(int requestID){
    for(var request in allRequests){
      if(request['requestID'] == requestID){
        request['state'] = "approved";
        notifyListeners();
      }
    }
  }
}