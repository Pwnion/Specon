import "package:cloud_firestore/cloud_firestore.dart";

import '../firebase_options.dart';
import '../models/requestModel.dart';

class DataBase {
  //static DataBase get instance => Get.find();

  final db = FirebaseFirestore.instance;

  createRequest(RequestModel request) async {
    await db
        .collection("Specon")
        .doc("placeHolder")
        .collection(request.subject)
        .add(request.toJson());
  }

  //.whenComplete(() => 1)
  //.catchError((error, stackTrace) {});
}
