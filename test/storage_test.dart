import 'package:flutter_test/flutter_test.dart';
import 'package:specon/storage.dart';

void storageUnitTest() {
  test('storage test get aap name', () async {
    final testResult = await getAapFileName("testGetAAP");
    expect(testResult, "test.txt");
  });
}
