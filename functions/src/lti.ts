import {Firestore} from "@examind/ltijs-firestore";
import {
  ACCESS_TOKEN_ENDPOINT,
  CANVAS_URL, LTI_CLIENT_ID,
  SPECON_APP_FOLDER_PATH,
  SPECON_APP_INDEX_FILE_PATH,
} from "./constants";
import {
  doesUserExist,
  getUser,
  putUserInfoForLaunch,
  updateAccessToken,
} from "./db";
import {User} from "./models/user";
import {getCodeUrl, getCourses, refreshAccessToken} from "./api";
import {Provider} from "ltijs";

// Get the main LTI object to work with.
const LTI = Provider;

// Configure the LTI instance.
LTI.setup(
  process.env.LTI_KEY!, // The LTI key from Canvas.
  // Configure the Firestore database connection.
  {plugin: new Firestore({collectionPrefix: "lti/index/"})},
  {
    staticPath: SPECON_APP_FOLDER_PATH, // The path to our compiled Specon app.
    cookies: {
      // Set to true because we're using TLS.
      secure: true,
      // Set to None because the Canvas instance and
      // the LTI server are on different domains.
      sameSite: "None",
    },
    // Increase the TTL of the token from Canvas to accomodate
    // slow connections when loading the Specon app.
    tokenMaxAge: 60,
  }
);

// Add the callback for when the negotiation between the LTI server
// and Canvas has finished and we have a token.
LTI.onConnect(async (token, _req, res) => {
  // If we don't have a token, (because the Specon app was logged in
  // from outside of Canvas) then just serve the Specon app and exit.
  if (!token) {
    return res.sendFile(SPECON_APP_INDEX_FILE_PATH);
  }

  // A UUID for the user from the Canvas token.
  const canvasUid: string = token.user;

  // The course code of the course that the
  // 'Specon' link was clicked in.
  const selectedCourseCode: string = res.locals.context!.context.label;

  // If the user already exists in the database, then just refresh
  // the access token, update the launch data and redirect to the app
  // with automatic login.
  if (await doesUserExist(canvasUid)) {
    const user: User = await getUser(canvasUid);
    const newAccessToken: string = await refreshAccessToken(user.refreshToken);
    await updateAccessToken(canvasUid, newAccessToken);
    await putUserInfoForLaunch(
      canvasUid,
      selectedCourseCode,
      await getCourses(user.id, newAccessToken)
    );
    return res.redirect(`/app?email=${user.email}`);
  }

  // If the user is new, redirect to the Canvas endpoint
  // to request authorisation from the user to make API
  // calls on their behalf (get their access token).
  return res.redirect(getCodeUrl(canvasUid, selectedCourseCode));
});

/**
 * Configures information specific to the Canvas instance.
 */
async function setup(): Promise<void> {
  // Whitelist the app route so that the Specon app can be accessed
  // even if a token is not present (login from outside of Canvas).
  LTI.whitelist(LTI.appRoute());

  // Deploy the LTI instance as serverless so it can be used as middleware
  // in our main Express server.
  await LTI.deploy({serverless: true});

  // Register the connecting Canvas instance.
  await LTI.registerPlatform({
    url: "https://canvas.instructure.com",
    name: "Specon",
    clientId: LTI_CLIENT_ID,
    authenticationEndpoint: `${CANVAS_URL}/api/lti/authorize_redirect`,
    accesstokenEndpoint: ACCESS_TOKEN_ENDPOINT,
    authConfig: {method: "JWK_SET", key: `${CANVAS_URL}/api/lti/security/jwks`},
  });
}

setup();

export {LTI};
