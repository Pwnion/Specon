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
// This is called by Canvas.
export const lti = onRequest(
  {region: REGION, cors: true},
  SERVER
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

// Run a cloud function every day at 6pm to
// send staff a summary email if they have
// open requests.
export const staff = onSchedule(
  "every day 18:00", async () => {
    await sendStaffEmails();
  }
);
