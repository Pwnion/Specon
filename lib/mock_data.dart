/// Temporary mock data to use for testing throughout the application.
///
/// Author: Aden McCusker

List<Map<String, dynamic>> allRequests = [
  {
    'requestID': 1,
    'submittedBy': 1,
    'name': 'Alex',
    'subject': 'COMP10001',
    'assessment': 'Project 1',
    'state': 'Open'
  },
  {
    'requestID': 2,
    'submittedBy': 1,
    'name': 'Bob',
    'subject': 'COMP10001',
    'assessment': 'Project 2',
    'state': 'Open'
  },
  {
    'requestID': 3,
    'submittedBy': 2,
    'name': 'Aren',
    'subject': 'COMP10001',
    'assessment': 'Final Exam',
    'state': 'Open'
  },
  {
    'requestID': 4,
    'submittedBy': 1,
    'name': 'Aden',
    'subject': 'COMP10001',
    'assessment': 'Mid Semester Exam',
    'state': 'Open'
  },
  {
    'requestID': 5,
    'submittedBy': 1,
    'name': 'Lo',
    'subject': 'COMP10001',
    'assessment': 'Project 1',
    'state': 'Open'
  },
  {
    'requestID': 6,
    'submittedBy': 1,
    'name': 'Harry',
    'subject': 'COMP10001',
    'assessment': 'Project 2',
    'state': 'Open'
  },
  {
    'requestID': 7,
    'submittedBy': 1,
    'name': 'Drey',
    'subject': 'COMP30022',
    'assessment': 'Project 2',
    'state': 'Open'
  },
  {
    'requestID': 8,
    'submittedBy': 1,
    'name': 'Brian',
    'subject': 'COMP30023',
    'assessment': 'Final Exam',
    'state': 'Open'
  },
  {
    'requestID': 9,
    'submittedBy': 1,
    'name': 'David',
    'subject': 'COMP30019',
    'assessment': 'Project 1',
    'state': 'Open'
  },
  {
    'requestID': 10,
    'submittedBy': 1,
    'name': 'Po',
    'subject': 'COMP30022',
    'assessment': 'Project 1',
    'state': 'Open'
  },
  {
    'requestID': 10,
    'submittedBy': 1,
    'name': 'Po',
    'subject': 'COMP30022',
    'assessment': 'Project 1',
    'state': 'Open'
  },
  {
    'requestID': 10,
    'submittedBy': 1,
    'name': 'Po',
    'subject': 'COMP30022',
    'assessment': 'Project 1',
    'state': 'Open'
  },
  {
    'requestID': 10,
    'submittedBy': 1,
    'name': 'Po',
    'subject': 'COMP30022',
    'assessment': 'Project 1',
    'state': 'Open'
  },
  {
    'requestID': 10,
    'submittedBy': 1,
    'name': 'Po',
    'subject': 'COMP30022',
    'assessment': 'Project 1',
    'state': 'Open'
  },
  {
    'requestID': 10,
    'submittedBy': 1,
    'name': 'Po',
    'subject': 'COMP30022',
    'assessment': 'Project 1',
    'state': 'Open'
  },
  {
    'requestID': 10,
    'submittedBy': 1,
    'name': 'Po',
    'subject': 'COMP30022',
    'assessment': 'Project 1',
    'state': 'Open'
  },
  {
    'requestID': 10,
    'submittedBy': 1,
    'name': 'Po',
    'subject': 'COMP30022',
    'assessment': 'Project 1',
    'state': 'Open'
  },
  {
    'requestID': 10,
    'submittedBy': 1,
    'name': 'Po',
    'subject': 'COMP30022',
    'assessment': 'Project 1',
    'state': 'Open'
  },
  {
    'requestID': 10,
    'submittedBy': 1,
    'name': 'Po',
    'subject': 'COMP30022',
    'assessment': 'Project 1',
    'state': 'Open'
  },
];

const List<String> assessments = [
  'All assessment',
  'Project 1',
  'Project 2',
  'Final Exam',
  'Mid Semester Exam',
];

const List<String> requestStates = [
  'Open',
  'Approved',
  'Flagged',
  'Declined',
  'All state',
];

// permission.dart
List<Map<String, dynamic>> permissionGroups = [
  {
    'group': 'Head Tutor',
    'users': ['Alex'],
    'permissions': ['Final Exam']
  },
  {
    'group': 'Tutor',
    'users': ['Lucas'],
    'permissions': ['Participation Waiver']
  },
  {
    'group': 'Lecturer',
    'users': ['Tawfiq'],
    'permissions': ['Due date extension']
  },
];

const List<String> typesOfPermissions = [
  "Project 1",
  "Project 2",
  "Final Exam",
  "Mid Semester Exam",
  "Participation Waiver",
  "Due date extension",
  "Change tutorial",
  "Others",
];

const Map<String, dynamic> permGroup = {
  'group': 'Lecturer',
  'users': ['Tawfiq'],
  'permissions': ['Extension']
};
