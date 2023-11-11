import express = require("express");

import {DocumentReference} from "firebase-admin/firestore";
import {SPECON_APP_INDEX_FILE_PATH} from "./constants";
import {User} from "./models/user";
import {requestAccessToken, getProfile, getCourses} from "./api";
import {initUser, putUserInfoForLaunch} from "./db";

const SERVER = express();

SERVER.get("/code", async (req, res) => {
  const state: string = req.query.state as string;
  console.log(state);
  const splitState: Array<string> = state.split(":");
  const canvasUid: string = splitState[0];
  const selectedCourseCode: string = splitState[1];
  const code: string = req.query.code as string;
  const tokenData: Map<string, string> = await requestAccessToken(code);
  const accountId: string = tokenData.get("accountId")!;
  const accessToken: string = tokenData.get("accessToken")!;
  const profile: Map<string, string> = await getProfile(accountId, accessToken);
  const email: string = profile.get("email") != null ?
    profile.get("email")! : "null";

  const user: User = new User(
    accountId,
    profile.get("name") != null ? profile.get("name")! : "null",
    email,
    "",
    accessToken,
    tokenData.get("refreshToken")!,
    new Array<DocumentReference>()
  );
  await initUser(canvasUid, user);
  await putUserInfoForLaunch(
    canvasUid,
    selectedCourseCode,
    await getCourses(accountId, accessToken)
  );
  return res.redirect(`/app?email=${email}`);
});

SERVER.get("/app", async (_req, res) => {
  return res.sendFile(SPECON_APP_INDEX_FILE_PATH);
});

export {SERVER};
