/// Some utility code for handling different types of users.
///
/// Author: Aden McCusker

/// The type of user that can be authenticated in the app.
enum UserType {
  student,
  nonAccreditedLearner,
  externalUser,
  instructor,
  subjectCoordinator,
  tutor,
  marker,
  subjectDesigner,
  auditor,
  itasTutor,
  collegeTutor
}

class UserTypeUtils {
  static UserType convertString(String roleString){
    switch (roleString) {
      case 'subject_coordinator':
        return UserType.subjectCoordinator;
      case 'tutor':
        return UserType.tutor;
      case 'student':
        return UserType.student;
      default:
        return UserType.collegeTutor;
    }
  }
}