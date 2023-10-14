import 'package:specon/models/request_type.dart';

class SubjectModel {
  final String name; // TODO: not final because we can change name
  final String code;
  final List<RequestType> assessments;
  final String semester;
  final String year;
  final String? id;

  const SubjectModel(
      {this.id,
      required this.name,
      required this.code,
      required this.assessments,
      required this.semester,
      required this.year});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'semester': semester,
      'year': year,
    };
  }
}
