import {
  DocumentData,
  DocumentReference,
  DocumentSnapshot,
} from "firebase-admin/firestore";

/** Represents a Canvas user. */
class User {
  id: string;
  name: string;
  email: string;
  studentID: string;
  accessToken: string;
  refreshToken: string;
  subjects: Array<DocumentReference>;

  /**
   * @param id - The user account ID.
   * @param name - The user's full name.
   * @param email - The user's email address.
   * @param studentID - The user's student ID.
   * @param accessToken - The user's Canvas access token.
   * @param refreshToken - The user's Canvas refresh token.
   * @param subjects - The user's enrolled subjects.
   */
  constructor(
    id: string,
    name: string,
    email: string,
    studentID: string,
    accessToken: string,
    refreshToken: string,
    subjects: Array<DocumentReference>
  ) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.studentID = studentID;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.subjects = subjects;
  }

  /**
   * Creates a User object from data retrieved from the database.
   *
   * @param snapshot - Data from the database.
   * @returns The resulting user object.
   */
  static fromDB(snapshot: DocumentSnapshot): User {
    const data: DocumentData = snapshot.data()!;
    return new User(
      data["id"],
      data["name"],
      data["email"],
      data["student_id"],
      data["access_token"],
      data["refresh_token"],
      data["subjects"]
    );
  }

  /**
   * Converts the data in this user object to a plain object.
   *
   * @returns The user data in object form.
   */
  data(): object {
    return {
      id: this.id,
      name: this.name,
      email: this.email,
      student_id: this.studentID,
      access_token: this.accessToken,
      refresh_token: this.refreshToken,
      subjects: this.subjects,
    };
  }
}

export {User};
