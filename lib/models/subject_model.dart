import 'package:specon/models/request_type.dart';

class SubjectModel {
  final String name; // not final because we can change name
  final String code;
  final List<RequestType> assessments;
  final String semester;
  final String year;

  SubjectModel(
      {required this.name,
      required this.code,
      required this.assessments,
      required this.semester,
      required this.year});
}
