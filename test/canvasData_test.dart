import 'package:flutter_test/flutter_test.dart';

import 'package:specon/models/canvas_data_model.dart';

void main(){
  List<Map<String, dynamic>> input = [{"assessments": [], "code": 'COMP10002', "id": 3,
  "name": "Foundations of Algorithms", "roles": {1: "Subject Coordinator", 10: "Student"}, "term": {"name": "Semester 2", "year": "2024"},
  "uuid": "PXiK1bUsMAAka2gioOPA1TLP1NMUuE4ibHgidUqF"}];

  // test starts here
  test('CanvasData fromDB', () async {
    final testResult = CanvasData.fromDB(input);
    expect(testResult.runtimeType, CanvasData);
  });
}