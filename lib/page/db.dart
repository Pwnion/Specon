import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/models/user_model.dart';
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

    if (subject.databasePath.isEmpty){
      return [];
    }

    // Subject Coordinator
    if (user.role == UserType.subjectCoordinator) {

      // Get subject's reference
      final requestsRef = await _db.doc(subject.databasePath).collection('requests').get();

      final requestsFromDB = requestsRef.docs;

      for(final request in requestsFromDB) {
        requests.add(
          RequestModel(
            requestedBy: request['requested_by'],
            requestedByStudentID: request['requested_by_student_id'],
            reason: request['reason'],
            additionalInfo: request['additional_info'],
            assessedBy: request['assessed_by'],
            assessment: request['assessment'],
            state: request['state'],
            databasePath: request.reference.path
          )
        );
      }
    }

    // Student
    else if (user.role == UserType.student) {

      // Query for student's requests from the subject
      final requestListFromDB = await _db
          .doc(subject.databasePath)
          .collection('requests')
          .where('requested_by_student_id', isEqualTo: user.studentID)
          .get();


      for(final request in requestListFromDB.docs){
        print(request['requested_by_student_id']+"asdfadf");
        requests.add(
          RequestModel(
            requestedBy: request['requested_by'],
            reason: request['reason'],
            additionalInfo: request['additional_info'],
            assessedBy: request['assessed_by'],
            assessment: request['assessment'],
            state: request['state'],
            requestedByStudentID: request['requested_by_student_id'],
            databasePath: request.reference.path
          )
        );
      }
    }

    // TODO: for permission (Tutor, etc)
    else {
      return [];
    }

    return requests;
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

  Future<DocumentReference> submitRequest(UserModel user, SubjectModel subject, RequestModel request) async {

    // Get subject's reference
    final DocumentReference subjectRef = _db.doc(subject.databasePath);

    // Add request to subject's collection
    final DocumentReference requestRef = await subjectRef.collection('requests').add(request.toJson());

    // Add first discussion to the database
    await requestRef.collection('discussions').add(
      {'subject': subject.code,
      'reason': request.reason,
      'assessment': request.assessment,
      'submittedBy': user.firstName,
      'submittedByUserID': user.id,
      'type': 'request'}
    );

    return requestRef;
  }

  Future<List<Map<String, String>>> getDiscussionThreads(RequestModel request) async {

    DocumentReference docRef = FirebaseFirestore.instance.doc(request.databasePath);
    List<Map<String, String>> allDiscussions = [];

    // use it after deleting all past discussion
    //final discussions = await docRef.collection('discussions').orderBy("timestamp").get();
    final discussions = await docRef.collection('discussions').get();

    for (final discussion in discussions.docs) {
      allDiscussions.add(
        {'assessment': discussion['assessment'],
          'reason': discussion['reason'],
          'subject': discussion['subject'],
          'submittedBy': discussion['submittedBy'],
          'submittedByUserID': discussion['submittedByUserID'],
          'type': discussion['type'],
        }
      );
    }
    return allDiscussions;
  }

  Future<void> addNewDiscussion(RequestModel request, Map<String, String> newDiscussion) async {

    DocumentReference docRef = FirebaseFirestore.instance.doc(request.databasePath);
    newDiscussion['timestamp'] = DateTime.now().toString();
    await docRef.collection('discussions').add(newDiscussion);
  }

}

Future<void> acceptRequest(RequestModel request) async {

  DocumentReference docRef = FirebaseFirestore.instance.doc(request.databasePath);

  await docRef.update({'state': 'Approved'});
}

Future<void> declineRequest(RequestModel request) async {

  DocumentReference docRef = FirebaseFirestore.instance.doc(request.databasePath);

  await docRef.update({'state': 'Declined'});
}

Future<void> flagRequest(RequestModel request) async {

  DocumentReference docRef = FirebaseFirestore.instance.doc(request.databasePath);

  await docRef.update({'state': 'Flagged'});
}
