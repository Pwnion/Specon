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

const app: App = initializeApp();
const db: Firestore = getFirestore(app);

const usersRef: CollectionReference = db.collection("users");
const coursesRef: CollectionReference = db.collection("subjects");

async function doesUserExist(uid: string): Promise<boolean> {
  const userSnapshot: DocumentSnapshot = await usersRef.doc(uid).get();
  return userSnapshot.exists;
}

async function initUser(uid: string, user: User): Promise<void> {
  await usersRef.doc(uid).set(user.data());
}

async function getUser(uid: string): Promise<User> {
  const userSnapshot: DocumentSnapshot = await usersRef.doc(uid).get();
  return User.fromDB(userSnapshot);
}

async function getUsers(): Promise<Array<User>> {
  const usersSnapshot: QuerySnapshot = await usersRef.get();
  return usersSnapshot.docs.map((userSnapshot) => {
    return User.fromDB(userSnapshot);
  });
}

async function getCourses(): Promise<Array<Course>> {
  const coursesSnapshot: QuerySnapshot = await coursesRef.get();
  return coursesSnapshot.docs.map((courseSnapshot) => {
    return Course.fromDB(courseSnapshot);
  });
}

async function countOpenRequests(courseUUID: string): Promise<number> {
  const requestsSnapshot: QuerySnapshot = await coursesRef
    .doc(courseUUID)
    .collection("requests")
    .where("state", "==", "Open")
    .get();

  return requestsSnapshot.size;
}

async function updateAccessToken(
  uid: string,
  newAccessToken: string
): Promise<void> {
  await usersRef.doc(uid).update({access_token: newAccessToken});
}

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
