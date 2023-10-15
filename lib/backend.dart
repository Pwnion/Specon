import 'package:flutter/cupertino.dart';
import 'mock_data.dart';

class BackEnd extends ChangeNotifier {
  BackEnd._privateConstructor();

  static final BackEnd _instance = BackEnd._privateConstructor();

  factory BackEnd() {
    return _instance;
  }

  List<String> getRequestStates() {
    return requestStates;
  }
}
