/// Class representing a subject.
///
/// A subject has various attributes including its [name], [code], [assessments],
/// [semester], and [year].
///
/// [name]: The name of the subject.
/// [code]: The subject code (e.g., "comp20001").
/// [assessments]: A list of request types associated with the subject.
/// [semester]: The semester in which the subject is offered.
/// [year]: The academic year in which the subject is offered.
///
/// Author: Drey Nguyen
import 'package:specon/models/request_type.dart';

class SubjectModel {
  final String name; // not final because we can change name
  final String code;
  final List<RequestType> assessments;
  final String semester;
  final String year;

  SubjectModel({
    required this.name,
    required this.code,
    required this.assessments,
    required this.semester,
    required this.year,
  });
}
