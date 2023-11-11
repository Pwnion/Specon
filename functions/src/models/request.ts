/* eslint-disable @typescript-eslint/no-unused-vars */

import {
  // DocumentData,
  DocumentSnapshot,
} from "firebase-admin/firestore";

class Request {
  static fromDB(snapshot: DocumentSnapshot): Request {
    // const data: DocumentData = snapshot.data()!;
    return new Request();
  }

  data(): object {
    return {};
  }
}

export {Request};
