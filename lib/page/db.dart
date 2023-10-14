import "package:cloud_firestore/cloud_firestore.dart";
import 'package:specon/models/subject_model.dart';
import 'package:specon/models/user_model.dart';
import 'package:specon/models/request_model.dart';

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
      email: fetchedUser["email"],
      name: fetchedUser["name"],
      subjects: fetchedUser["subjects"],
      aap_path: fetchedUser["aap_path"],
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
    if (subject.roles[user.id] == 'subject_coordinator') {

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
    else if (subject.roles[user.id] == 'student') {

      // Query for student's requests from the subject
      final requestListFromDB = await _db
          .doc(subject.databasePath)
          .collection('requests')
          .where('requested_by_student_id', isEqualTo: user.id) // TODO:
          .get();

      for(final request in requestListFromDB.docs){
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
            roles: documentSnapshot['roles'],
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

    // Add first discussion to the database
    await requestRef.collection('discussions').add(
      {'subject': subject.code,
      'reason': request.reason,
      'assessment': request.assessment,
      'submittedBy': user.name,
      'submittedByUserID': user.id,
      'type': 'request'}
    );
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
