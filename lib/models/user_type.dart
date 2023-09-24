/// The type of user that can be authenticated in the app.
/// Author: Jeremy Annal
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
  static UserType convertString(String roleString) {
    switch (roleString) {
      case 'subject_coordinator':
        return UserType.subjectCoordinator;
      case 'tutor':
        return UserType.tutor;
      default:
        return UserType.student;
    }
  }
}
