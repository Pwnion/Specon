import path = require("path");
import {config} from "dotenv";

// The URL of the Canvas instance.
const CANVAS_URL = "https://canvas.ngrok.app";

// The URL of the LTI cloud function.
const LTI_URL = "https://lti-tzff7thfsa-km.a.run.app";

// The URL that receives a code from Canvas used to request an access token
// to make Canvas API requests on a user's behalf.
const API_REDIRECT_URL = `${LTI_URL}/code`;

// The Canvas instance's OAuth 2 endpoint.
const ACCESS_TOKEN_ENDPOINT = `${CANVAS_URL}/login/oauth2/token`;

// The LTI developer key client ID from the Canvas instance.
const LTI_CLIENT_ID = "10000000000001";

// The API developer key client ID from the Canvas instance.
const API_CLIENT_ID = "10000000000002";

// The path to the folder with the Specon app's static files.
const SPECON_APP_FOLDER_PATH = path.join(__dirname, "..", "public");

// The path to the 'index.html' file in the Specon app's static files.
const SPECON_APP_INDEX_FILE_PATH = path.join(
  SPECON_APP_FOLDER_PATH,
  "./index.html"
);

// Load all the environment variables from the '.env' file.
config();

export {
  CANVAS_URL,
  LTI_URL,
  API_REDIRECT_URL,
  ACCESS_TOKEN_ENDPOINT,
  LTI_CLIENT_ID,
  API_CLIENT_ID,
  SPECON_APP_FOLDER_PATH,
  SPECON_APP_INDEX_FILE_PATH,
};
