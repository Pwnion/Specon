import {onRequest} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {LTI} from "./lti";
import {SERVER} from "./server";
import {createAssignmentOverride} from "./api";
import {sendStaffEmails, sendStudentEmail} from "./mail";

// Where in the world to deploy the cloud functions.
const REGION = "australia-southeast2";

// Inject the LTI Express server into our Express server as middleware.
SERVER.use(LTI.app);

// Deploy the Express server as a HTTP cloud function.
export const lti = onRequest(
  {region: REGION, cors: true},
  SERVER
);

export const override = onRequest(
  {region: REGION, cors: true},
  async (req, res) => {
    const payload = req.body.data;
    const userId: number = payload.userId;
    const courseId: number = payload.courseId;
    const assignmentId: number = payload.assignmentId;
    const newDate: string = payload.newDate;
    const accessToken: string = payload.accessToken;
    const result = await createAssignmentOverride(
      userId,
      courseId,
      assignmentId,
      newDate,
      accessToken
    );
    res.status(200).send({
      data: result,
    });
  }
);

export const student = onRequest(
  {region: REGION, cors: true},
  async (req, res) => {
    const payload = req.body.data;
    await sendStudentEmail(payload.to);
    res.status(200).send({data: {}});
  }
);

export const staff = onSchedule(
  "every day 18:00", async () => {
    await sendStaffEmails();
  }
);
