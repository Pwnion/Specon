import "package:cloud_firestore/cloud_firestore.dart";

import '../firebase_options.dart';
import '../models/request_model.dart';

class DataBase {
  //static DataBase get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  createRequest(RequestModel request) async {
    await _db
    .collection("Specon")
    .doc("placeHolder")
    .collection(request.subject)
    .add(request.toJson());
  }
}
