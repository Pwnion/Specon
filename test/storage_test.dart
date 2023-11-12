import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:specon/firebase_options.dart';
import 'package:specon/storage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // TestWidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.web
  // );
  test('storage test get aap name', () async {
    final testResult = await getAapFileName("testGetAAP");
    expect(testResult, "no AAP");
  });
}
