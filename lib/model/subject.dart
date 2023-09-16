import 'package:specon/model/request_type.dart';

class Subject {
  final String name; // not final because we can change name
  final String code;
  final List<RequestType> assessments;

  Subject({
    required this.name,
    required this.code,
    required this.assessments,
  });
}
