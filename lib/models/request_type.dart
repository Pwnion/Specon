/// class responsible for type of requests
/// [name]: name of the requests to display
/// [type]: different types to call API
/// [id]: for the order it display
///
/// Author: Drey Nguyen

class RequestType {
  String name; // not final because we can change name
  String id;
  DateTime? dueDate;
  String databasePath;

  RequestType(
      {required this.name,
      required this.id,
      required this.databasePath,
      this.dueDate});

  static final emptyAssessment =
      RequestType(name: '', id: '', databasePath: '');

  static List<String> getAssessmentNames(List<RequestType> assessments) {
    List<String> names = [];

    for (final assessment in assessments) {
      names.add(assessment.name);
    }

    return names;
  }

  // // fake request types
  // static Future<List<String>?> importTypes(String subjectCode) async{
  //   return await _db.importFromCanvas(subjectCode);
  // }
  // fake request types
  static List<RequestType> importTypes() {
    return [
      // RequestType(id: '01', name: 'Project 1'),
      // RequestType(id: '02', name: 'Project 2'),
      // RequestType(id: '03', name: 'Mid Semester Test'),
      // RequestType(id: '04', name: 'Project 3'),
    ];
  }
}
