import {onRequest} from "firebase-functions/v2/https";
import {LTI} from "./lti";
import {SERVER} from "./server";

SERVER.use(LTI.app);
export const lti = onRequest(
  {region: "australia-southeast2", cors: true},
  SERVER
);
