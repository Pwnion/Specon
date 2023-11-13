/// This class has all the functions relating to the database, this includes
/// adding data from the database, removing and fetching data from the database
///
/// Author: Jeremy Annal, Zhi Xiang Chan (Lucas)

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:specon/models/request_type.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/models/user_model.dart';
import 'package:specon/models/request_model.dart';

import 'models/canvas_data_model.dart';

import 'package:firebase_auth/firebase_auth.dart';

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
    final String selectedSubject =
        fetchedCanvasDataQuery.data()!['selected_course'];

    final userModel = UserModel(
        uuid: fetchedUser.id,
        id: fetchedUser["id"],
        email: fetchedUser["email"],
        accessToken: fetchedUser["access_token"],
        name: fetchedUser["name"],
        subjects: fetchedUser["subjects"],
        studentID: fetchedUser["student_id"],
        canvasData: CanvasData.fromDB(fetchedCanvasData),
        selectedSubject: selectedSubject);

    user = userModel;
    return userModel;
  }

  Future<String?> getCurrentUserEmail() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    return user?.email;
  }

  Future<String?> getDocumentIdByEmail(String email) async {
    try {
      // Reference to the Firestore collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Query for the document with the specified email
      QuerySnapshot querySnapshot =
          await users.where('email', isEqualTo: email).get();

      // Check if a document with the given email exists
      if (querySnapshot.docs.isNotEmpty) {
        // Return the document ID of the first matching document
        return querySnapshot.docs.first.id;
      } else {
        // Return null if no document is found
        return null;
      }
    } catch (e) {
      // Handle any errors that may occur during the process
      print('Error getting document ID by email: $e');
      return null;
    }
  }

  Future<String?> getUserLaunchDataPath() async {
    try {
      // Get the current user's email
      String? userEmail = await getCurrentUserEmail();

      // Check if user email is available
      if (userEmail != null) {
        // Get the document ID corresponding to the user's email
        String? documentId = await getDocumentIdByEmail(userEmail);

        // Check if document ID is available
        if (documentId != null) {
          // Return the combined path
          return '/users/$documentId/launch/data';
        } else {
          // Return null if document ID is not found
          return null;
        }
      } else {
        // Return null if user email is not found
        return null;
      }
    } catch (e) {
      // Handle any errors that may occur during the process
      print('Error getting user launch data path: $e');
      return null;
    }
  }

  Future<List<RequestType>> importFromCanvas(String subjectCode) async {
    try {
      // Get the current user's email
      String? userEmail = await getCurrentUserEmail();
      String? userID = await getDocumentIdByEmail(userEmail!);

      // Check if user email is available
      // Get the document corresponding to the user's email in the "launch" collection
      DocumentSnapshot userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('launch')
          .doc('data')
          .get();

      // Check if the document exists
      if (userDocument.exists) {
        // Extract the 'subjects' field
        List<dynamic> subjects = userDocument['subjects'];

        // Find the subject with the provided subject code
        Map<String, dynamic>? matchingSubject = subjects.firstWhere((subject) {
          return subject['code'] == subjectCode;
        }, orElse: () => null);

        if (matchingSubject != null) {
          // Cast the 'assessments' field to List<String>
          List<RequestType> returnList = [];
          List<dynamic> assessments = matchingSubject['assessments'];

          assessments.forEach((element) {
            if (element['due_date'] == null) {
              returnList.add(RequestType(
                  name: element['name'],
                  id: element['id'].toString(),
                  databasePath: ""));
            } else {
              returnList.add(RequestType(
                  name: element['name'],
                  id: element['id'].toString(),
                  dueDate: DateTime.parse(element['due_date']),
                  databasePath: ""));
            }
          });

          return returnList;
        } else {
          // Print a message if the subject with the provided code is not found
          return [];
        }
      } else {
        // Print a message if the document does not exist
        return [];
      }
    } catch (e) {
      // Handle any errors that may occur during the process
      return [];
    }
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
      'id': int.parse(assessment.id),
      'dueDate': assessment.dueDate
    });

    DocumentReference assessmentsRef =
        _db.doc('${subjectPath}/assessments/${documentRef.id}');
    assessmentsRef
        .update({'dataPath': '${subjectPath}/assessments/${documentRef.id}'});

    assessment.databasePath = documentRef.id;
  }

  /// Function update assessment name through Assessment Manager to DB
  Future<void> updateAssessmentName(
      String assessmentPath, String newName) async {
    DocumentReference assessmentsRef = _db.doc(assessmentPath);

    await assessmentsRef.update({'name': newName});
  }

  /// Function delete assessment through Assessment Manager to DB
  Future<void> deleteAssessment(
      String subjectPath, String assessmentPath) async {
    DocumentReference assessmentsRef = _db.doc(assessmentPath);

    await assessmentsRef.delete();

    CollectionReference requestsRef =
        _db.doc(subjectPath).collection('requests');

    QuerySnapshot querySnapshot =
        await requestsRef.where('assessment', isEqualTo: assessmentPath).get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
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
              databasePath: request['assessment'].path,
              id: request['assessment'].path);
        });

        final timeSubmitted = (request['time_submitted'] as Timestamp).toDate();

        requests.add(RequestModel(
            requestedBy: request['requested_by'],
            requestedByStudentID: request['requested_by_student_id'],
            reason: request['reason'],
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
              databasePath: request['assessment'].path,
              id: request['assessment'].path);
        });

        final timeSubmitted = (request['time_submitted'] as Timestamp).toDate();

        requests.add(RequestModel(
            requestedBy: request['requested_by'],
            reason: request['reason'],
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
      if (!subject.roles.keys.toList().contains(user.id)) return [];

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

        if (allowedRequestTypes!.isEmpty) continue;

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
                databasePath: request['assessment'].path,
                id: documentSnapshot['id']);
          });

          final timeSubmitted =
              (request['time_submitted'] as Timestamp).toDate();

          requests.add(RequestModel(
              requestedBy: request['requested_by'],
              reason: request['reason'],
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
    bool newSubjectInitialised = false;

    for (final subject in user!.subjects) {
      DocumentReference docRef = FirebaseFirestore.instance.doc(subject.path);

      final assessments = await getAssessments(subject.path);

      await docRef.get().then((DocumentSnapshot documentSnapshot) async {
        subjects.add(SubjectModel(
            id: documentSnapshot['id'],
            name: documentSnapshot['name'],
            code: documentSnapshot['code'],
            roles: documentSnapshot['roles'],
            assessments: assessments,
            semester: documentSnapshot['semester'],
            year: documentSnapshot['year'],
            databasePath: subject.path));
      });
    }

    // Check if a subject is being initialised or not
    for (final subject in user!.canvasData.subjects) {
      if (subject['roles'][user!.id] != 'Subject Coordinator') break;

      final subjectRef = await _db
          .collection('subjects')
          .where('code', isEqualTo: subject['code'])
          .where('semester', isEqualTo: subject['term']['name'])
          .where('year', isEqualTo: subject['term']['year'])
          .get();

      if (subjectRef.docs.isEmpty) {
        initialiseSubject(subject);
        newSubjectInitialised = true;
      }
    }

    // Refresh with the new initialised subjects
    if (newSubjectInitialised) {
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
          id: '-404',
          databasePath: assessment.reference.path));
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

  /// function that returns discussion related to the request
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

  /// Function that add discussion text to the corresponding request
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

      for (final userID in group['users']) {
        roles[userID] = group['name'];
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

  /// Function that initialises basic information for a subject onto the database
  Future<void> initialiseSubject(
      Map<String, dynamic> subjectInformation) async {
    Map<String, String> roles = convertRoles(subjectInformation);

    Map<String, String> studentAndCoordinator = {...roles};
    Map<String, String> staff = {...roles};

    studentAndCoordinator.removeWhere(
        (key, value) => value != 'student' && value != 'subject_coordinator');
    staff.removeWhere(
        (key, value) => value == 'student' || value == 'subject_coordinator');

    final subjectsRef = _db.collection('subjects');
    final subjectID = await subjectsRef.add({
      'id': subjectInformation['id'],
      'name': subjectInformation['name'],
      'code': subjectInformation['code'],
      'semester': subjectInformation['term']['name'],
      'year': subjectInformation['term']['year'],
      'roles': studentAndCoordinator,
      'staff': staff
    });

    for (final userID in subjectInformation['roles'].keys.toList()) {
      final userRef =
          await _db.collection('users').where('id', isEqualTo: userID).get();

      final userDatabasePath = userRef.docs[0].reference.path;

      await _db.doc(userDatabasePath).update({
        'subjects': FieldValue.arrayUnion([subjectID])
      });
    }
  }

  /// Function to update subject's role (In case new student has enrolled in this subject),
  /// also updates each user's subjects array
  Future<void> updateSubjectRoles(List<SubjectModel> subjects) async {
    for (final subject in subjects) {
      final subjectRef = _db.doc(subject.databasePath);
      final subjectDoc = await subjectRef.get();
      final Map<String, dynamic> databaseRoles = subjectDoc['roles'];
      final Map<String, dynamic> databaseStaff = subjectDoc['staff'];

      // If user is a subject coordinator, sync it with canvas
      if (databaseRoles.keys.toList().contains(user!.id) &&
          databaseRoles[user!.id] == 'subject_coordinator') {
        for (final canvasSubject in user!.canvasData.subjects) {
          if (canvasSubject['id'] == subject.id) {
            final Map<String, dynamic> canvasRoles = canvasSubject['roles'];

            final Map<String, dynamic> databaseStudentsOnly = {
              ...databaseRoles
            };
            databaseStudentsOnly
                .removeWhere((key, value) => value != 'student');

            final Map<String, dynamic> canvasStudentsOnly = {...canvasRoles};
            canvasStudentsOnly.removeWhere((key, value) => value != 'Student');

            final Map<String, dynamic> canvasStaffsOnly = {...canvasRoles};
            canvasStaffsOnly.removeWhere((key, value) =>
                value == 'Student' || value == 'Subject Coordinator');

            final List studentInDatabaseButNotInCanvas =
                databaseStudentsOnly.keys.toList();
            studentInDatabaseButNotInCanvas.removeWhere((element) =>
                canvasStudentsOnly.keys.toList().contains(element));

            final List studentInCanvasButNotInDatabase =
                canvasStudentsOnly.keys.toList();
            studentInCanvasButNotInDatabase.removeWhere((element) =>
                databaseStudentsOnly.keys.toList().contains(element));

            final List staffInDatabaseButNotInCanvas =
                canvasStaffsOnly.keys.toList();
            staffInDatabaseButNotInCanvas.removeWhere(
                (element) => canvasStaffsOnly.keys.toList().contains(element));

            final List staffInCanvasButNotInDatabase =
                canvasStaffsOnly.keys.toList();
            staffInCanvasButNotInDatabase.removeWhere(
                (element) => databaseStaff.keys.toList().contains(element));

            // If new students has enrolled into subject, add into subject array
            if (studentInCanvasButNotInDatabase.isNotEmpty) {
              for (final studentID in studentInCanvasButNotInDatabase) {
                final studentRef = await _db
                    .collection('users')
                    .where('id', isEqualTo: studentID)
                    .get();

                if (studentRef.docs.isEmpty) continue;

                final studentDocID = studentRef.docs[0].id;

                await _db.collection('users').doc(studentDocID).update({
                  'subjects': FieldValue.arrayUnion([subjectDoc.reference])
                });
                databaseRoles[studentID] = 'student';
              }
            }

            // Some students unenrolled from subject, removed from subject array
            if (studentInDatabaseButNotInCanvas.isNotEmpty) {
              for (final studentID in studentInDatabaseButNotInCanvas) {
                final studentRef = await _db
                    .collection('users')
                    .where('id', isEqualTo: studentID)
                    .get();

                if (studentRef.docs.isEmpty) continue;

                final studentDocID = studentRef.docs[0].id;

                await _db.collection('users').doc(studentDocID).update({
                  'subjects': FieldValue.arrayRemove([subjectDoc.reference])
                });
                databaseRoles.remove(studentID);
              }
            }

            // If new staff has enrolled into subject, add into subject array
            if (staffInCanvasButNotInDatabase.isNotEmpty) {
              for (final staffID in staffInCanvasButNotInDatabase) {
                final staffRef = await _db
                    .collection('users')
                    .where('id', isEqualTo: staffID)
                    .get();

                if (staffRef.docs.isEmpty) continue;

                final staffDocID = staffRef.docs[0].id;

                await _db.collection('users').doc(staffDocID).update({
                  'subjects': FieldValue.arrayUnion([subjectDoc.reference])
                });
                databaseStaff[staffID] = canvasStaffsOnly[staffID];
              }
            }

            // Some staffs unenrolled from subject, removed from subject array
            if (staffInDatabaseButNotInCanvas.isNotEmpty) {
              for (final staffID in staffInDatabaseButNotInCanvas) {
                final staffRef = await _db
                    .collection('users')
                    .where('id', isEqualTo: staffID)
                    .get();

                if (staffRef.docs.isEmpty) continue;

                final staffDocID = staffRef.docs[0].id;

                await _db.collection('users').doc(staffDocID).update({
                  'subjects': FieldValue.arrayRemove([subjectDoc.reference])
                });
                databaseStaff.remove(staffID);
              }
            }

            await subjectRef.update({'staff': databaseStaff});
            await subjectRef.update({'roles': databaseRoles});
            break;
          }
        }
      }
    }
  }

  /// Function to convert Subject Coordinator and Student roles to subject_coordinator and student
  Map<String, String> convertRoles(Map<String, dynamic> subjectInformation) {
    Map<String, String> convertedRoles = {};

    for (final user in subjectInformation['roles'].keys.toList()) {
      if (subjectInformation['roles'][user] == 'Subject Coordinator') {
        convertedRoles[user] = 'subject_coordinator';
      } else if (subjectInformation['roles'][user] == 'Student') {
        convertedRoles[user] = 'student';
      } else {
        convertedRoles[user] = subjectInformation['roles'][user];
      }
    }

    return convertedRoles;
  }

  ///
  Future<Map<String, String>> getSubjectStaff(SubjectModel subject) async {
    final subjectRef = await _db.doc(subject.databasePath).get();

    final Map<String, dynamic> staffDynamic = subjectRef['staff'];

    final Map<String, String> staff =
        staffDynamic.map((key, value) => MapEntry(key, value!.toString()));

    return staff;
  }

  ///
  Future<Map<String, String>> getStaffNames(List<String> userIDs) async {
    Map<String, String> names = {};

    if (userIDs.isEmpty) return {};

    final usersRef =
        await _db.collection('users').where('id', whereIn: userIDs).get();

    final userDocs = usersRef.docs;

    for (final user in userDocs) {
      names[user['id']] = user['name'];
    }

    return names;
  }

  ///
  Future<String> getUserID(String name, String studentID) async {
    final userRef = await _db
        .collection('users')
        .where('student_id', isEqualTo: studentID)
        .where('name', isEqualTo: name)
        .get();

    return userRef.docs[0]['id'];
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
