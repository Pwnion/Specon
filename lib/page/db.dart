import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:specon/models/userModel.dart';

import '../firebase_options.dart';
import '../models/request_model.dart';

class DataBase {
  //static DataBase get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  createRequest(RequestModel request) async {
    await _db
        .collection("subjects")
        .doc(request.subject)
        .collection("requests")
        .add(request.toJson());
  }

  Future<UserModel> getUserFromEmail(
      String matchField, String emailToMatch) async {
    final usersRef = _db.collection("users");
    final query =
        await usersRef.where(matchField, isEqualTo: emailToMatch).get();

    final fetchedUser = query.docs[0];

    final userModel = UserModel(
      id: fetchedUser["id"],
      studentID: fetchedUser["student_id"],
      emailAddress: fetchedUser["email"],
      firstName: fetchedUser["first_name"],
      middleName: fetchedUser["middle_name"],
      lastName: fetchedUser["last_name"],
      role: fetchedUser["role"],
      subjects: fetchedUser["subjects"],
    );

    return userModel;
  }

  Future<List<RequestModel>> getRequests(
      String subjectID, String userID) async {
    final requestsRef =
        _db.collection("subjects").doc(subjectID).collection("requests");
    final query =
        await requestsRef.where("requested_user_id", isEqualTo: userID).get();
    print(query);

    List<RequestModel> requests = [];

    for (final request in query.docs) {
      requests.add(RequestModel(
          requested_user_id: request["requested_user_id"],
          reason: request["reason"],
          additional_info: request["additional_info"],
          assessed_user_id: request["assessed_user_id"],
          state: request["state"],
          subject: request["subject"]));
    }
    return requests;
  }
}
