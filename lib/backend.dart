class BackEnd {

  BackEnd._privateConstructor();

  static final BackEnd _instance = BackEnd._privateConstructor();

  factory BackEnd() {
    return _instance;
  }

  List allRequests = [
    {"ID": 1, "submittedBy": 1, "name": 'Alex', "subject": "COMP30023", "type": "Project 1"},
    {"ID": 2, "submittedBy": 1, "name": 'Bob', "subject": "COMP30019", "type": "Project 2"},
    {"ID": 3, "submittedBy": 2, "name": 'Aren', "subject": "COMP30022", "type": "Final Exam"},
    {"ID": 4, "submittedBy": 1, "name": 'Aden', "subject": "COMP30023", "type": "Mid Semester Exam"},
    {"ID": 5, "submittedBy": 1, "name": 'Lo', "subject": "COMP30020", "type": "Project 1"},
    {"ID": 6, "submittedBy": 1, "name": 'Harry', "subject": "COMP30019", "type": "Project 2"},
    {"ID": 7, "submittedBy": 1, "name": 'Drey', "subject": "COMP30022", "type": "Project 2"},
    {"ID": 8, "submittedBy": 1, "name": 'Brian', "subject": "COMP30023", "type": "Final Exam"},
    {"ID": 9, "submittedBy": 1, "name": 'David', "subject": "COMP30019", "type": "Project 1"},
    {"ID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1"},
    {"ID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1"},
    {"ID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1"},
    {"ID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1"},
    {"ID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1"},
    {"ID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1"},
    {"ID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1"},
    {"ID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1"},
    {"ID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1"},
    {"ID": 10, "submittedBy": 1, "name": 'Po', "subject": "COMP30022", "type": "Project 1"},
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


  List getAllRequest(String subjectID) {
    return allRequests;
  }

  List<String> getBasicFields(String subjectID) {
    return basicFieldTitles;
  }

  Map getTypesOfRequest(String subjectID) {
    return typesOfRequest;
  }

  List<Map<String, String>> getSubjectList(String userID) {
    return subjectList;
  }

}