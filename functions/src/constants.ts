import path = require("path");
import {config} from "dotenv";

const CANVAS_URL = "https://canvas.ngrok.app";
const LTI_URL = "https://lti-tzff7thfsa-km.a.run.app";
const API_REDIRECT_URL = `${LTI_URL}/code`;
const ACCESS_TOKEN_ENDPOINT = `${CANVAS_URL}/login/oauth2/token`;
const LTI_CLIENT_ID = "10000000000001";
const API_CLIENT_ID = "10000000000002";
const SPECON_APP_FOLDER_PATH = path.join(__dirname, "..", "public");
const SPECON_APP_INDEX_FILE_PATH = path.join(
  SPECON_APP_FOLDER_PATH,
  "./index.html"
);

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
