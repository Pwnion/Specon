import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/models/userModel.dart';
import 'package:specon/user_type.dart';

import '../firebase_options.dart';
import '../models/request_model.dart';

class DataBase {

  final _db = FirebaseFirestore.instance;

  static UserModel? user;

  Future<UserModel> getUserFromEmail(String emailToMatch) async {
    final usersRef = _db.collection("users");
    final query =
        await usersRef.where('email', isEqualTo: emailToMatch).get();

    final fetchedUser = query.docs[0];

    final userModel = UserModel(
      id: fetchedUser["id"],
      studentID: fetchedUser["student_id"],
      emailAddress: fetchedUser["email"],
      firstName: fetchedUser["first_name"],
      middleName: fetchedUser["middle_name"],
      lastName: fetchedUser["last_name"],
      role: UserTypeUtils.convertString(fetchedUser["role"]),
      subjects: fetchedUser["subjects"],
    );

    user = userModel;
    return userModel;
  }

  Future<List<RequestModel>> getRequests(UserModel user, SubjectModel subject) async {

    List<RequestModel> requests = [];

    // TODO: Make it return all requests for now
    // if (user.role == UserType.subjectCoordinator) {

      // Get subject's reference
      final requestsRef = await _db.doc(subject.databasePath).collection('requests').get();

      final requestsFromDB = requestsRef.docs;

      for(final request in requestsFromDB) {
        requests.add(
          RequestModel(
            requestedBy: request['requested_by'],
            reason: request['reason'],
            additionalInfo: request['additional_info'],
            assessedBy: request['assessed_by'],
            assessment: request['assessment'],
            state: request['state'],
          )
        );
      }
    return requests;
    // }

    // TODO: For student
    // final requestsRef = _db.collection("subjects").doc(subjectID).collection("requests");
    // final query =
    //     await requestsRef.where("requested_user_id", isEqualTo: userID).get();
    // print(query);

  }

  Future<List<SubjectModel>> getEnrolledSubjects() async {
    List<SubjectModel> subjects = [];

    for (final subject in user!.subjects){

      DocumentReference docRef = FirebaseFirestore.instance.doc(subject.path);

      await docRef.get().then((DocumentSnapshot documentSnapshot) {
        subjects.add(
          SubjectModel(
            name: documentSnapshot['name'],
            code: documentSnapshot['code'],
            assessments: [], // documentSnapshot['test_assessment'], // TODO:
            semester: documentSnapshot['semester'],
            year: documentSnapshot['year'],
            databasePath: subject.path
          )
        );
      });
    }
    return subjects;
  }

  Future<void> submitRequest(UserModel user, SubjectModel subject, RequestModel request) async {

    // Get subject's reference
    final DocumentReference subjectRef = _db.doc(subject.databasePath);

    // Add request to subject's collection
    final DocumentReference requestRef = await subjectRef.collection('requests').add(request.toJson());

    // Query for user
    final usersRef = _db.collection("users");
    final query = await usersRef.where('email', isEqualTo: user.emailAddress).get();

    // Add reference to user's requests array
    await query
      .docs[0]
      .reference
      .update({'requests': FieldValue.arrayUnion([requestRef])});
  }
}
