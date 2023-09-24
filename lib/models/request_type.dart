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

  // fake request types
  static List<RequestType> importTypes() {
    return [
      RequestType(id: '01', name: 'Project 1', type: 'assignment extension'),
      RequestType(id: '04', name: 'Waiver', type: 'participation waiver'),
      RequestType(id: '06', name: 'Assignment 2', type: 'assignment extension'),
    ];
  }
}
