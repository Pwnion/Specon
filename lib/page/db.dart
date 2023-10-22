import "package:cloud_firestore/cloud_firestore.dart";
import 'package:specon/models/request_type.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/models/user_model.dart';
import 'package:specon/models/request_model.dart';

class DataBase {
  final _db = FirebaseFirestore.instance;

  static UserModel? user;

  Future<UserModel> getUserFromEmail(String emailToMatch) async {
    final usersRef = _db.collection("users");
    final query = await usersRef.where('email', isEqualTo: emailToMatch).get();

    final fetchedUser = query.docs[0];

    final userModel = UserModel(
      id: fetchedUser["id"],
      email: fetchedUser["email"],
      name: fetchedUser["name"],
      subjects: fetchedUser["subjects"],
      aapPath: fetchedUser["aap_path"],
    );

    user = userModel;
    return userModel;
  }

  Future<List<RequestModel>> getRequests(
      UserModel user, SubjectModel subject) async {
    List<RequestModel> requests = [];

    if (subject.databasePath.isEmpty) {
      return [];
    }

    // Subject Coordinator
    if (subject.roles[user.id] == 'subject_coordinator') {
      // Get subject's reference
      final requestsRef =
          await _db.doc(subject.databasePath).collection('requests').get();

      final requestsFromDB = requestsRef.docs;
      for (final request in requestsFromDB) {
        final assessmentRef = _db.doc(request['assessment'].path);
        late final RequestType assessmentFromDB;

        await assessmentRef.get().then((DocumentSnapshot documentSnapshot) {
          assessmentFromDB = RequestType(
              name: documentSnapshot['name'],
              type: '',
              id: request['assessment'].path);
        });

        requests.add(RequestModel(
            requestedBy: request['requested_by'],
            requestedByStudentID: request['requested_by_student_id'],
            reason: request['reason'],
            additionalInfo: request['additional_info'],
            assessedBy: request['assessed_by'],
            assessment: assessmentFromDB,
            state: request['state'],
            databasePath: request.reference.path));
      }
    }

    // Student
    else if (subject.roles[user.id] == 'student') {
      // Query for student's requests from the subject
      final requestListFromDB = await _db
          .doc(subject.databasePath)
          .collection('requests')
          .where('requested_by_student_id', isEqualTo: user.id) // TODO:
          .get();

      for (final request in requestListFromDB.docs) {
        final assessmentRef = _db.doc(request['assessment'].path);
        late final RequestType assessmentFromDB;

        await assessmentRef.get().then((DocumentSnapshot documentSnapshot) {
          assessmentFromDB = RequestType(
              name: documentSnapshot['name'],
              type: '',
              id: request['assessment'].path);
        });

        requests.add(RequestModel(
            requestedBy: request['requested_by'],
            reason: request['reason'],
            additionalInfo: request['additional_info'],
            assessedBy: request['assessed_by'],
            assessment: assessmentFromDB,
            state: request['state'],
            requestedByStudentID: request['requested_by_student_id'],
            databasePath: request.reference.path));
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

    for (final subject in user!.subjects) {
      DocumentReference docRef = FirebaseFirestore.instance.doc(subject.path);

      final assessments = await getAssessments(subject.path);

      await docRef.get().then((DocumentSnapshot documentSnapshot) {
        subjects.add(SubjectModel(
            name: documentSnapshot['name'],
            code: documentSnapshot['code'],
            roles: documentSnapshot['roles'],
            assessments: assessments,
            semester: documentSnapshot['semester'],
            year: documentSnapshot['year'],
            databasePath: subject.path));
      });
    }
    return subjects;
  }

  Future<List<RequestType>> getAssessments(String subjectPath) async {
    List<RequestType> assessments = [];

    CollectionReference assessmentsRef =
        FirebaseFirestore.instance.doc(subjectPath).collection('assessments');

    QuerySnapshot querySnapshot = await assessmentsRef.get();

    for (final assessment in querySnapshot.docs) {
      assessments.add(RequestType(
          name: assessment['name'],
          type: '', // TODO:
          id: assessment.reference.path));
    }

    return assessments;
  }

  Future<void> updateAssessmentName(
      String assessmentPath, String newName) async {
    DocumentReference assessmentsRef = _db.doc(assessmentPath);

    await assessmentsRef.update({'name': newName});
  }

  Future<void> createAssessment(
      String subjectPath, String assessmentName) async {
    CollectionReference subjectRef =
        _db.doc(subjectPath).collection('assessments');

    await subjectRef.add({
      'assessments': assessmentName,
    });
  }

  // Future<void> updateAssessmentName(String subjectID, String newName) async {
//     try {
//       await Firebase.initializeApp();
//       FirebaseFirestore firestore = FirebaseFirestore.instance;

//       await firestore.collection('subjects').doc(subjectID).collection('assessments').doc(assessmentID).update({
//         'name': newName,
//       });

//       notifyListeners();
//     } catch (e) {
//       print('Error updating assessment name: $e');
//     }
//   }

  Future<DocumentReference> submitRequest(
      UserModel user, SubjectModel subject, RequestModel request) async {
    // Get subject's reference
    final DocumentReference subjectRef = _db.doc(subject.databasePath);

    // Add request to subject's collection
    final DocumentReference requestRef =
        await subjectRef.collection('requests').add(request.toJson());

    return requestRef;
  }

  Future<List<Map<String, String>>> getDiscussionThreads(
      RequestModel request) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.doc(request.databasePath);
    List<Map<String, String>> allDiscussions = [];

    // use it after deleting all past discussion
    final discussions =
        await docRef.collection('discussions').orderBy("timestamp").get();
    //final discussions = await docRef.collection('discussions').get();

    for (final discussion in discussions.docs) {
      allDiscussions.add({
        //'assessment': discussion['assessment'],
        'text': discussion['text'],
        //'subject': discussion['subject'],
        'submittedBy': discussion['submittedBy'],
        'submittedByUserID': discussion['submittedByUserID'],
        'type': discussion['type'],
      });
    }
    return allDiscussions;
  }

  Future<void> addNewDiscussion(
      RequestModel request, Map<String, String> newDiscussion) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.doc(request.databasePath);
    newDiscussion['timestamp'] = DateTime.now().toString();
    await docRef.collection('discussions').add(newDiscussion);
  }
}

Future<void> acceptRequest(RequestModel request) async {
  DocumentReference docRef =
      FirebaseFirestore.instance.doc(request.databasePath);

  await docRef.update({'state': 'Approved'});
}

Future<void> declineRequest(RequestModel request) async {
  DocumentReference docRef =
      FirebaseFirestore.instance.doc(request.databasePath);

  await docRef.update({'state': 'Declined'});
}

Future<void> flagRequest(RequestModel request) async {
  DocumentReference docRef =
      FirebaseFirestore.instance.doc(request.databasePath);

  await docRef.update({'state': 'Flagged'});
}
