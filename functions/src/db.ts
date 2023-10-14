import {initializeApp, App} from "firebase-admin/app";
import {
  getFirestore,
  Firestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
} from "firebase-admin/firestore";
import {User} from "./models/user";
import {Courses} from "./models/course";


const app: App = initializeApp();
const db: Firestore = getFirestore(app);

const usersRef: CollectionReference = db.collection("users");

async function doesUserExist(uid: string): Promise<boolean> {
  const userSnapshot: DocumentSnapshot = await usersRef.doc(uid).get();
  return userSnapshot.exists;
}

async function initUser(uid: string, user: User): Promise<void> {
  await usersRef.doc(uid).set(user.data());
}

async function getUser(uid: string): Promise<User> {
  const userSnapshot: DocumentSnapshot = await usersRef.doc(uid).get();
  return User.fromDB(userSnapshot.data()!);
}

async function updateAccessToken(
  uid: string,
  newAccessToken: string
): Promise<void> {
  await usersRef.doc(uid).update({access_token: newAccessToken});
}

async function putUserInfoForLaunch(
  uid: string,
  courses: Courses
): Promise<void> {
  const infoRef: DocumentReference = usersRef
    .doc(uid)
    .collection("launch")
    .doc("data");

  await infoRef.set({subjects: courses.data()});
}

export {
  doesUserExist,
  initUser,
  getUser,
  updateAccessToken,
  putUserInfoForLaunch,
};
