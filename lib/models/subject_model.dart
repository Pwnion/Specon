import 'package:specon/models/request_type.dart';

class SubjectModel {
  final int id;
  final String name; // TODO: not final because we can change name
  final String code;
  final List<RequestType> assessments;
  final String semester;
  final String year;
  final String databasePath;
  final Map<String, dynamic> roles;

  static final emptySubject = SubjectModel(
    id: 0,
    roles: {},
    name: '',
    code: '',
    assessments: [],
    semester: '',
    year: '',
    databasePath: '',
  );

  SubjectModel(
      {
      required this.id,
      required this.name,
      required this.code,
      required this.assessments,
      required this.semester,
      required this.year,
      required this.databasePath,
      required this.roles});
}
