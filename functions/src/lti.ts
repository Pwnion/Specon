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

const LTI = Provider;

LTI.setup(
  process.env.LTI_KEY!,
  {plugin: new Firestore({collectionPrefix: "lti/index/"})},
  {
    staticPath: SPECON_APP_FOLDER_PATH,
    cookies: {
      secure: true,
      sameSite: "None",
    },
    tokenMaxAge: 60,
  }
);

LTI.onConnect(async (token, _req, res) => {
  if (!token) {
    return res.sendFile(SPECON_APP_INDEX_FILE_PATH);
  }

  const canvasUid: string = token.user;
  if (await doesUserExist(canvasUid)) {
    const user: User = await getUser(canvasUid);
    const newAccessToken: string = await refreshAccessToken(user.refreshToken);
    await updateAccessToken(canvasUid, newAccessToken);
    await putUserInfoForLaunch(
      canvasUid,
      res.locals.context!.context.label,
      await getCourses(user.id, newAccessToken)
    );
    return res.redirect(`/app?email=${user.email}`);
  }
  return res.redirect(getCodeUrl(canvasUid));
});

const setup = async () => {
  LTI.whitelist(LTI.appRoute());
  await LTI.deploy({serverless: true});
  await LTI.registerPlatform({
    url: "https://canvas.instructure.com",
    name: "Specon",
    clientId: LTI_CLIENT_ID,
    authenticationEndpoint: `${CANVAS_URL}/api/lti/authorize_redirect`,
    accesstokenEndpoint: ACCESS_TOKEN_ENDPOINT,
    authConfig: {method: "JWK_SET", key: `${CANVAS_URL}/api/lti/security/jwks`},
  });
};

setup();

export {LTI};
