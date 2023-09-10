import "package:cloud_firestore/cloud_firestore.dart";

import '../firebase_options.dart';
import '../models/requestModel.dart';
import '../models/extensionModel.dart';
import '../models/participationWaiverModel.dart';
import '../models/otherReasonModel.dart';
import '../models/changeTuteModel.dart';

class DataBase {
  //static DataBase get instance => Get.find();

  final db = FirebaseFirestore.instance;

  // createRequest(RequestModel request) async {
  //   await db
  //       .collection("Specon")
  //       .doc("placeHolder")
  //       .collection(request.subject)
  //       .add(request.toJson());
  // }

  //.whenComplete(() => 1)
  //.catchError((error, stackTrace) {});
  createExtensionRequest(ExtensionModel request) async {
    await db
        .collection("Specon")
        .doc("placeHolder")
        .collection(request.subject)
        .add(request.toJson());
  }
}
