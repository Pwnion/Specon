import {onRequest} from "firebase-functions/v2/https";
import {LTI} from "./lti";
import {SERVER} from "./server";
import {
  createAssignmentOverride,
  getAssignmentOverrides,
  refreshAccessToken,
  updateAssignmentOverride,
} from "./api";
import {sendStaffEmails, sendStudentEmail} from "./mail";
import {AssessmentOverride} from "./models/assessment_override";
import {User} from "./models/user";
import {getUser, updateAccessToken} from "./db";

// Where in the world to deploy the cloud functions.
const REGION = "australia-southeast2";

// Inject the LTI Express server into our Express server as middleware.
SERVER.use(LTI.app);

// Deploy the Express server as a HTTP cloud function.
// This is called by Canvas.
export const lti = onRequest(
  {region: REGION, cors: true},
  SERVER
);

// Deploy a HTTP cloud function that refreshes
// a user's access token.
export const refresh = onRequest(
  {region: REGION, cors: true},
  async (req, res) => {
    const payload = req.body.data;
    const userUUID: string = payload.userUUID;
    const user: User = await getUser(userUUID);
    const newAccessToken = await refreshAccessToken(user.refreshToken);
    await updateAccessToken(userUUID, newAccessToken);
    res.status(200).send({
      data: {
        access_token: newAccessToken,
      },
    });
  }
);

// Deploy a HTTP cloud function that overrides an
// assignment due date for a specific user. This is
// called by the Specon app.
export const override = onRequest(
  {region: REGION, cors: true},
  async (req, res) => {
    const payload = req.body.data;
    const userId: number = payload.userId;
    const courseId: number = payload.courseId;
    const assignmentId: number = payload.assignmentId;
    const newDate: string = payload.newDate;
    const accessToken: string = payload.accessToken;

    const currAssignmentOverrides = await getAssignmentOverrides(
      courseId,
      assignmentId,
      accessToken
    );
    const matchingAssignmentOverride: AssessmentOverride | null =
      currAssignmentOverrides.findStudentOverride(userId);

    let result;
    if (matchingAssignmentOverride == null) {
      result = await createAssignmentOverride(
        courseId,
        new AssessmentOverride(null, assignmentId, [userId], newDate),
        accessToken
      );
    } else {
      matchingAssignmentOverride.dueDate = newDate;
      result = await updateAssignmentOverride(
        courseId,
        matchingAssignmentOverride,
        accessToken
      );
    }

    res.status(200).send({
      data: result,
    });
  }
);

// Deploy a HTTP cloud function that sends an email to
// a student that one of their requests has been considered.
// This is called by the Specon app.
export const student = onRequest(
  {region: REGION, cors: true},
  async (req, res) => {
    const payload = req.body.data;
    await sendStudentEmail(payload.to);
    res.status(200).send({data: {}});
  }
);

// Deploy a HTTP cloud function that sends
// staff a summary email if they have
// open requests.
export const staff = onRequest(
  {region: REGION, cors: true},
  async (_, res) => {
    await sendStaffEmails();
    res.status(200).send({data: {}});
  }
);
