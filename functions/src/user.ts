import {DocumentReference, DocumentData} from "firebase-admin/firestore";

class User {
  accountId: string;
  name: string;
  email: string;
  accessToken: string;
  refreshToken: string;
  subjects: Array<DocumentReference>;

  constructor(
    accountId: string,
    name: string,
    email: string,
    accessToken: string,
    refreshToken: string,
    subjects: Array<DocumentReference>
  ) {
    this.accountId = accountId;
    this.name = name;
    this.email = email;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.subjects = subjects;
  }

  static fromDB(data: DocumentData): User {
    return new User(
      data["account_id"],
      data["name"],
      data["email"],
      data["access_token"],
      data["refresh_token"],
      data["subjects"]
    );
  }

  data(): object {
    return {
      account_id: this.accountId,
      name: this.name,
      email: this.email,
      access_token: this.accessToken,
      refresh_token: this.refreshToken,
      subjects: this.subjects,
    };
  }
}

export {User};
