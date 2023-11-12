import express = require("express");

import {DocumentReference} from "firebase-admin/firestore";
import {SPECON_APP_INDEX_FILE_PATH} from "./constants";
import {User} from "./models/user";
import {requestAccessToken, getProfile, getCourses} from "./api";
import {initUser, putUserInfoForLaunch} from "./db";

// The main Express server instance.
const SERVER = express();

// Define the 'code' endpoint for the Express server.
// This receives a code from Canvas that is used to
// request an access token to access a user's Canvas
// account on their behalf via the Canvas API.
SERVER.get("/code", async (req, res) => {
  // The state string passed back from the LTI 'onConnect'
  // callback that contains information from the Canvas token
  // used to initialise the user in the database.
  const state: string = req.query.state as string;
  const splitState: Array<string> = state.split(":");

  // A UUID for the user from Canvas.
  const canvasUid: string = splitState[0];

  // The course code of the course that the
  // 'Specon' link was clicked in.
  const selectedCourseCode: string = splitState[1];

  // The code from Canvas used to request an access token.
  const code: string = req.query.code as string;

  const tokenData: Map<string, string> = await requestAccessToken(code);
  const accountId: string = tokenData.get("accountId")!;
  const accessToken: string = tokenData.get("accessToken")!;
  const profile: Map<string, string> = await getProfile(accountId, accessToken);
  const email: string = profile.get("email")!;

  // Build a user object with all the information from Canvas.
  const user: User = new User(
    accountId,
    profile.get("name")!,
    email,
    "", // Student ID starts empty. It must be manually entered in Specon.
    accessToken,
    tokenData.get("refreshToken")!,
    new Array<DocumentReference>()
  );

  // Initialise the user in the database.
  await initUser(canvasUid, user);

  // Add Canvas launch data into the database.
  await putUserInfoForLaunch(
    canvasUid,
    selectedCourseCode,
    await getCourses(accountId, accessToken)
  );

  // Redirect to the Specon app with automatic login.
  return res.redirect(`/app?email=${email}`);
});

// Define the 'app' endpoint for the Express server.
// This simply serves the Specon app.
SERVER.get("/app", async (_req, res) => {
  return res.sendFile(SPECON_APP_INDEX_FILE_PATH);
});

export {SERVER};
