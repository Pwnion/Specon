/// class responsible for type of requests
/// [name]: name of the requests to display
/// [type]: different types to call API
/// [id]: for the order it display
///
/// Author: Drey Nguyen

class RequestType {
  String name; // not final because we can change name
  final String type;
  final String id;

  RequestType({
    required this.name,
    required this.type,
    required this.id,
  });

  static final emptyAssessment = RequestType(
    name: '',
    type: '',
    id: ''
  );

  static List<String> getAssessmentNames(List<RequestType> assessments) {

    List<String> names = [];

    for(final assessment in assessments){
      names.add(assessment.name);
    }

    return names;
  }

  // fake request types
  static List<RequestType> importTypes() {
    return [
      RequestType(id: '01', name: 'Project 1', type: 'assignment extension'),
      RequestType(id: '02', name: 'Project 2', type: 'participation waiver'),
      RequestType(
          id: '03', name: 'Mid Semester Test', type: 'assignment extension'),
      RequestType(id: '04', name: 'Project 3', type: 'assignment extension'),
    ];
  }
}
