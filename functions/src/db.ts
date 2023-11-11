import {initializeApp, App} from "firebase-admin/app";
import {
  getFirestore,
  Firestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
} from "firebase-admin/firestore";
import {User} from "./models/user";
import {Course, Courses} from "./models/course";

// Initialise the Firebase admin SDK.
const app: App = initializeApp();
const db: Firestore = getFirestore(app);

// Declare some important collection references.
const usersRef: CollectionReference = db.collection("users");
const coursesRef: CollectionReference = db.collection("subjects");

/**
 * Checks if a user exists in the database.
 *
 * @param uid - A Canvas UUID.
 * @returns True if the user exists, otherwise false.
 */
async function doesUserExist(uid: string): Promise<boolean> {
  const userSnapshot: DocumentSnapshot = await usersRef.doc(uid).get();
  return userSnapshot.exists;
}

/**
 * Initialises a user in the database.
 *
 * @param uid - A Canvas UUID.
 * @param user - The user to add to the database.
 */
async function initUser(uid: string, user: User): Promise<void> {
  await usersRef.doc(uid).set(user.data());
}

/**
 * Get a user from the database.
 *
 * @param uid - A Canvas UUID.
 * @returns The user that the Canvas UUID belongs to.
 */
async function getUser(uid: string): Promise<User> {
  const userSnapshot: DocumentSnapshot = await usersRef.doc(uid).get();
  return User.fromDB(userSnapshot);
}

/**
 * Get all users from the database.
 *
 * @returns All the users in the database.
 */
async function getUsers(): Promise<Array<User>> {
  const usersSnapshot: QuerySnapshot = await usersRef.get();
  return usersSnapshot.docs.map((userSnapshot) => {
    return User.fromDB(userSnapshot);
  });
}

/**
 * Gets all courses from the database.
 *
 * @returns All the courses in the database.
 */
async function getCourses(): Promise<Array<Course>> {
  const coursesSnapshot: QuerySnapshot = await coursesRef.get();
  return coursesSnapshot.docs.map((courseSnapshot) => {
    return Course.fromDB(courseSnapshot);
  });
}

/**
 * Get the number of open requests for a course.
 *
 * @param courseUUID - The course UUID.
 * @returns The number of open requests.
 */
async function countOpenRequests(courseUUID: string): Promise<number> {
  const requestsSnapshot: QuerySnapshot = await coursesRef
    .doc(courseUUID)
    .collection("requests")
    .where("state", "==", "Open")
    .get();

  return requestsSnapshot.size;
}

/**
 * Update the access token for a user in the database.
 *
 * @param uid - A Canvas UUID.
 * @param newAccessToken - The new access token.
 */
async function updateAccessToken(
  uid: string,
  newAccessToken: string
): Promise<void> {
  await usersRef.doc(uid).update({access_token: newAccessToken});
}

/**
 * Add/Update Canvas launch data for a user in the database.
 *
 * @param uid - A Canvas UUID.
 * @param selectedCourseCode - The course code the Specon link was clicked in.
 * @param courses - All the data for the user's courses to add to the database.
 */
async function putUserInfoForLaunch(
  uid: string,
  selectedCourseCode: string,
  courses: Courses
): Promise<void> {
  const infoRef: DocumentReference = usersRef
    .doc(uid)
    .collection("launch")
    .doc("data");

  await infoRef.set({
    selected_course: selectedCourseCode,
    subjects: courses.data(),
  });
}

/**
 * Adds a document to the database which triggers an email to send.
 * The email is sent by a Firestore triggered cloud function that
 * is setup by a Firebase extension.
 *
 * @param to - The email address of the recipient.
 * @param subject - The subject of the email.
 * @param body - The HTML body of the email.
 */
async function sendEmail(
  to: string,
  subject: string,
  body: string
): Promise<void> {
  await db.collection("mail").add({
    to: [to],
    message: {
      subject: subject,
      html: body,
    },
  });
}

export {
  doesUserExist,
  initUser,
  getUser,
  getUsers,
  getCourses,
  countOpenRequests,
  updateAccessToken,
  putUserInfoForLaunch,
  sendEmail,
};
