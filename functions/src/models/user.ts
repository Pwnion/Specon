import {DocumentReference, DocumentData} from "firebase-admin/firestore";

class User {
  id: string;
  name: string;
  email: string;
  studentID: string;
  accessToken: string;
  refreshToken: string;
  subjects: Array<DocumentReference>;

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

  static fromDB(data: DocumentData): User {
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
