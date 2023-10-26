/// This class has all the functions relating to the database, this includes
/// adding data from the database, removing and fetching data from the database
///
/// Author: Jeremy Annal, Zhi Xiang Chan (Lucas)

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:specon/models/request_type.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/models/user_model.dart';
import 'package:specon/models/request_model.dart';
import 'package:collection/collection.dart';

import 'models/canvas_data_model.dart';

class DataBase {
  final _db = FirebaseFirestore.instance;

  static UserModel? user;

  /// Function that queries the users collection with an email and returns an user model
  Future<UserModel> getUserFromEmail(String emailToMatch) async {
    final usersRef = _db.collection("users");
    final query = await usersRef.where('email', isEqualTo: emailToMatch).get();

    final fetchedUser = query.docs[0];

    final fetchedCanvasDataQuery = await usersRef
        .doc(fetchedUser.id)
        .collection('launch')
        .doc('data')
        .get();
    final List<dynamic> fetchedCanvasData =
        fetchedCanvasDataQuery.data()!['subjects'];

    final userModel = UserModel(
        uuid: fetchedUser.id,
        id: fetchedUser["id"],
        email: fetchedUser["email"],
        name: fetchedUser["name"],
        subjects: fetchedUser["subjects"],
        studentID: fetchedUser["student_id"],
        canvasData: CanvasData.fromDB(fetchedCanvasData));

    user = userModel;
    return userModel;
  }

  /// Function that sets the student id on a student's document
  Future<void> setStudentID(String studentID) async {
    final usersRef = _db.collection("users");
    final query = await usersRef.where('email', isEqualTo: user!.email).get();

    final fetchedUser = query.docs[0];

    await fetchedUser.reference.update({'student_id': studentID});
  }

  /// Function create new assessment through Assessment Manager to DB
  Future<void> createAssessment(
      String subjectPath, RequestType assessment) async {
    CollectionReference subjectRef =
        _db.doc(subjectPath).collection('assessments');

    DocumentReference documentRef = await subjectRef.add({
      'name': assessment.name,
    });

    assessment.id = documentRef.id;
  }

  /// Function update assessment name through Assessment Manager to DB
  Future<void> updateAssessmentName(
      String assessmentPath, String newName) async {
    DocumentReference assessmentsRef = _db.doc(assessmentPath);

    await assessmentsRef.update({'name': newName});
  }

  /// Function delete assessment through Assessment Manager to DB
  Future<void> deleteAssessment(String assessmentPath) async {
    DocumentReference assessmentsRef = _db.doc(assessmentPath);

    await assessmentsRef.delete();
  }

  /// Function that fetches the requests for a subject based on a user's role
  Future<List<RequestModel>> getRequests(
      UserModel user, SubjectModel subject) async {
    List<RequestModel> requests = [];

    if (subject.code.isEmpty) return [];

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

        final timeSubmitted = (request['time_submitted'] as Timestamp).toDate();

        requests.add(RequestModel(
            requestedBy: request['requested_by'],
            requestedByStudentID: request['requested_by_student_id'],
            reason: request['reason'],
            additionalInfo: request['additional_info'],
            assessedBy: request['assessed_by'],
            assessment: assessmentFromDB,
            state: request['state'],
            databasePath: request.reference.path,
            timeSubmitted: timeSubmitted,
            requestType: request['request_type'],
            daysExtending: request['days_extending']));
      }
    }

    // Student
    else if (subject.roles[user.id] == 'student') {
      // Query for student's requests from the subject
      final requestListFromDB = await _db
          .doc(subject.databasePath)
          .collection('requests')
          .where('requested_by_student_id', isEqualTo: user.studentID)
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

        final timeSubmitted = (request['time_submitted'] as Timestamp).toDate();

        requests.add(RequestModel(
            requestedBy: request['requested_by'],
            reason: request['reason'],
            additionalInfo: request['additional_info'],
            assessedBy: request['assessed_by'],
            assessment: assessmentFromDB,
            state: request['state'],
            requestedByStudentID: request['requested_by_student_id'],
            databasePath: request.reference.path,
            timeSubmitted: timeSubmitted,
            requestType: request['request_type'],
            daysExtending: request['days_extending']));
      }
    }

    // For other roles (Determined by permissions set by subject coordinator)
    else {
      final subjectRef = await _db.doc(subject.databasePath).get();

      // Get user's role in the subject
      final userRole = subjectRef['roles'][user.id];

      // Query for the group's reference with the role
      final groupRef = await _db
          .doc(subject.databasePath)
          .collection('groups')
          .where('name', isEqualTo: userRole)
          .get();

      final group = groupRef.docs[0];

      // Get all assessments under a group
      final assessments =
          await _db.doc(group.reference.path).collection('assessments').get();

      Map<DocumentReference, List<String>> allowedPermissions = {};

      // If a assessment's request type is allowed, add it into list
      for (final assessment in assessments.docs) {
        List<String> allowedRequestTypes = [];

        assessment.data().forEach((key, value) {
          if (value) allowedRequestTypes.add(key);
        });

        final assessmentPath =
            '${subjectRef.reference.path}/assessments/${assessment.id}';
        final assessmentRef = await _db.doc(assessmentPath).get();

        allowedPermissions[assessmentRef.reference] = [...allowedRequestTypes];
      }

      // Query for all request which this role has permission to view
      for (final assessmentRef in allowedPermissions.keys.toList()) {
        final allowedRequestTypes = allowedPermissions[assessmentRef];

        final requestListFromDB = await _db
            .doc(subject.databasePath)
            .collection('requests')
            .where('assessment', isEqualTo: assessmentRef)
            .where('request_type', whereIn: allowedRequestTypes)
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

          final timeSubmitted =
              (request['time_submitted'] as Timestamp).toDate();

          requests.add(RequestModel(
              requestedBy: request['requested_by'],
              reason: request['reason'],
              additionalInfo: request['additional_info'],
              assessedBy: request['assessed_by'],
              assessment: assessmentFromDB,
              state: request['state'],
              requestedByStudentID: request['requested_by_student_id'],
              databasePath: request.reference.path,
              timeSubmitted: timeSubmitted,
              requestType: request['request_type'],
              daysExtending: request['days_extending']));
        }
      }
    }

    // Sort by oldest requests on the top
    requests.sort((a, b) => a.timeSubmitted.compareTo(b.timeSubmitted));

    return requests;
  }

  /// Function that fetches a user's enrolled subjects
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

    // Checks if any subject is not initialised yet
    if (subjects.length != user!.canvasData.subjects.length) {

      final subjectCodesInDatabase = subjects.map((subject) => subject.code).toList();
      final subjectCodesInCanvas = user!.canvasData.subjects.map((subject) => subject['code']).toList();

      subjectCodesInCanvas.removeWhere((subject) => subjectCodesInDatabase.contains(subject));

      for (final subjectCode in subjectCodesInCanvas) {

        final subjectInformation = user!.canvasData.subjects.where((element) => element['code'] == subjectCode);
        await initialiseSubject(subjectInformation.first);
      }
      user = await getUserFromEmail(user!.email);
      return getEnrolledSubjects();
    }

    updateSubjectRoles(subjects);

    return subjects;
  }

  /// Function that fetches the assessments of a subject
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

  /// Function that adds a request onto the database
  Future<DocumentReference> submitRequest(
      UserModel user, SubjectModel subject, RequestModel request) async {
    // Get subject's reference
    final DocumentReference subjectRef = _db.doc(subject.databasePath);

    // Add request to subject's collection
    final DocumentReference requestRef =
        await subjectRef.collection('requests').add(request.toJson());

    await requestRef.update({'time_submitted': Timestamp.now()});

    return requestRef;
  }

  ///
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

  ///
  Future<void> addNewDiscussion(
      RequestModel request, Map<String, String> newDiscussion) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.doc(request.databasePath);
    newDiscussion['timestamp'] = DateTime.now().toString();
    await docRef.collection('discussions').add(newDiscussion);
  }

  /// Function that deletes a request from the database
  Future<void> deleteOpenRequest(RequestModel request) async {
    await FirebaseFirestore.instance.doc(request.databasePath).delete();
  }

  /// Function that fetches permission groups of a subject from the database
  Future<List<Map<String, dynamic>>> getPermissionGroups(
      SubjectModel subject) async {
    final groups =
        await _db.doc(subject.databasePath).collection('groups').get();
    final assessments =
        await _db.doc(subject.databasePath).collection('assessments').get();
    List<Map<String, dynamic>> userGroups = [];
    Map<String, String> assessmentsInSubject = {};

    // Get all assessments in the subject
    for (final assessment in assessments.docs) {
      assessmentsInSubject[assessment.id] = assessment['name'];
    }

    // Get information of all groups and append to list
    for (final group in groups.docs) {
      final assessmentsInGroup =
          await _db.doc(group.reference.path).collection('assessments').get();

      Map<String, Map<String, bool>> allAssessments = {};

      for (final assessment in assessmentsInGroup.docs) {
        String assessmentName = assessmentsInSubject[assessment.id]!;
        Map<String, bool> requestTypes =
            assessment.data().map((key, value) => MapEntry(key, value));

        allAssessments[assessmentName] = {...requestTypes};
      }

      userGroups.add({
        'name': group['name'],
        'priority': group['priority'],
        'users': group['users'], // TODO:
        'assessments': allAssessments
      });
    }

    // Sort by priority (1 at the top)
    userGroups.sort((a, b) => a['priority'].compareTo(b['priority']));

    return userGroups;
  }

  /// Function that updates the permission groups in the database if changes were made
  Future<void> updatePermissionGroups(
      SubjectModel subject, List<Map<String, dynamic>> groups) async {
    final groupsOnDatabase =
        await _db.doc(subject.databasePath).collection('groups').get();
    final assessments =
        await _db.doc(subject.databasePath).collection('assessments').get();
    final subjectRef = _db.doc(subject.databasePath);
    Map<String, String> assessmentsToID = {};

    // Get name and ID of assessments
    for (final assessment in assessments.docs) {
      assessmentsToID[assessment['name']] = assessment.id;
    }

    // Delete old groups
    for (final group in groupsOnDatabase.docs) {
      final assessments =
          await _db.doc(group.reference.path).collection('assessments').get();

      for (final assessment in assessments.docs) {
        await _db.doc(assessment.reference.path).delete();
      }

      await _db.doc(group.reference.path).delete();
    }

    final subjectFields = await subjectRef.get();
    Map<String, dynamic> roles = subjectFields['roles'];
    roles.removeWhere(
        (key, value) => value != 'subject_coordinator' && value != 'student');

    // Add new groups
    for (final group in groups) {
      final groupRef =
          await _db.doc(subject.databasePath).collection('groups').add({
        'name': group['name'],
        'priority': group['priority'],
        'users': FieldValue.arrayUnion(group['users']) // TODO:
      });

      for (final user in group['users']) {
        final userRef =
            await _db.collection('users').where('name', isEqualTo: user).get();

        if (userRef.docs.isNotEmpty) {
          final userID = userRef.docs[0]['id'];
          roles[userID] = group['name'];
        }
      }

      for (final assessment in group['assessments'].keys.toList()) {
        final assessmentID = assessmentsToID[assessment];
        await _db
            .doc(groupRef.path)
            .collection('assessments')
            .doc(assessmentID)
            .set(group['assessments'][assessment]);
      }
    }

    await subjectRef.update({'roles': roles});
  }

  /// Function that syncs the database with Canvas (Updates the database)
  Future<void> syncDatabaseWithCanvas() async {

    await Future.delayed(const Duration(seconds: 3)); // TODO
  }

  /// Function that initialises basic information for a subject onto the database
  Future<void> initialiseSubject(Map<String, dynamic> subjectInformation) async {

    final findSubjectRef = await _db.collection('subjects').where('code', isEqualTo: subjectInformation['code']).get(); // TODO: semester and year

    Map<String, String> roles = convertRoles(subjectInformation);

    if (findSubjectRef.docs.isNotEmpty) return;

    final subjectsRef = _db.collection('subjects');
    final subjectID = await subjectsRef.add(
      {'name': subjectInformation['name'],
       'code': subjectInformation['code'],
       'semester': subjectInformation['term']['name'],
       'year': subjectInformation['term']['year'],
       'roles': roles}
    );

    for(final userID in subjectInformation['roles'].keys.toList()) {

      final userRef = await _db.collection('users').where('id', isEqualTo: userID).get();

      final userDatabasePath = userRef.docs[0].reference.path;

      await _db.doc(userDatabasePath).update({'subjects': FieldValue.arrayUnion([subjectID])});
    }
    
  }

  /// Function to update subject's role (In case new student has enrolled in this subject),
  /// also updates each user's subjects array
  Future<void> updateSubjectRoles(List<SubjectModel> subjects) async {

    for (final subject in subjects) {

      for (final canvasSubject in user!.canvasData.subjects) {

        if(subject.code == canvasSubject['code']) {

          final subjectRef = await _db.doc(subject.databasePath).get();
          final Map<String, String> canvasRoles = convertRoles(canvasSubject);
          final Map<String, dynamic> databaseRoles = subjectRef['roles'];

          Map<String, String> databaseStudentsRemoved = {...databaseRoles};
          Map<String, String> canvasStudentsOnly = {...canvasRoles};

          // Remove students from database role map
          databaseStudentsRemoved.removeWhere((key, value) => value == 'student');

          // Keep students only on canvas role map
          canvasStudentsOnly.removeWhere((key, value) => value != 'student');

          Map<String, dynamic> updatedStudents = {...databaseStudentsRemoved, ...canvasStudentsOnly};

          // If no changes, don't have to check anymore
          if (const DeepCollectionEquality().equals(databaseRoles, updatedStudents)) {
            continue;
          }

          // Update subjects array in each user
          for(final userID in updatedStudents.keys.toList()){

            final userRef = await _db
              .collection('users')
              .where('id', isEqualTo: userID)
              .get();

            if(userRef.docs.isEmpty) continue;

            final studentDoc = userRef.docs[0];
            final subjectList = studentDoc['subjects'];
            final subjectRefs = subjectList.map((subject) => subject.path);

            if (!subjectRefs.contains(subject.databasePath)) {
              await _db.collection('users')
                .doc(studentDoc.id)
                .update({'subjects': FieldValue.arrayUnion([subjectRef.reference])});
            }
          }

          await _db.doc(subject.databasePath).update({'roles': updatedStudents});
        }
      }
    }
  }

  /// Function to convert Subject Coordinator and Student roles to subject_coordinator and student
  Map<String, String> convertRoles(Map<String, dynamic> subjectInformation) {

    Map<String, String> convertedRoles = {};

    for (final user in subjectInformation['roles'].keys.toList()){
      if (subjectInformation['roles'][user] == 'Subject Coordinator') {
        convertedRoles[user] = 'subject_coordinator';
      }
      else if (subjectInformation['roles'][user] == 'Student') {
        convertedRoles[user] = 'student';
      }
      else {
        convertedRoles[user] = subjectInformation['roles'][user];
      }
    }

    return convertedRoles;
  }

}

///
Future<void> acceptRequest(RequestModel request) async {
  DocumentReference docRef =
      FirebaseFirestore.instance.doc(request.databasePath);

  await docRef.update({'state': 'Approved'});
}

///
Future<void> declineRequest(RequestModel request) async {
  DocumentReference docRef =
      FirebaseFirestore.instance.doc(request.databasePath);

  await docRef.update({'state': 'Declined'});
}

///
Future<void> flagRequest(RequestModel request) async {
  DocumentReference docRef =
      FirebaseFirestore.instance.doc(request.databasePath);

  await docRef.update({'state': 'Flagged'});
}
