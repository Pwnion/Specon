import {initializeApp, App} from "firebase-admin/app";
import {
  getFirestore,
  Firestore,
  CollectionReference,
  DocumentSnapshot,
} from "firebase-admin/firestore";
import {User} from "./user";


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

export {doesUserExist, initUser, getUser, updateAccessToken};
