/// This is a test file for [storage]
///
/// Author: Kuo Wei Wu

import 'package:flutter_test/flutter_test.dart';
import 'package:specon/storage.dart';

void main() async {
  test('storage test get aap name', () async {
    final testResult = await getAapFileName("testGetAAP");
    expect(testResult, "no AAP");
  });
}
