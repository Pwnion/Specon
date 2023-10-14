import {
  CANVAS_URL,
  API_REDIRECT_URL,
  ACCESS_TOKEN_ENDPOINT,
  API_CLIENT_ID,
} from "./constants";

const JSON_HEADERS = {"Content-Type": "application/json"};

function getCodeUrl(canvasUid: string): string {
  return [
    `${CANVAS_URL}/login/oauth2/auth?`,
    `client_id=${API_CLIENT_ID}&`,
    `response_type=code&state=${canvasUid}&`,
    `redirect_uri=${API_REDIRECT_URL}`,
  ].join("");
}

async function requestAccessToken(code: string): Promise<Map<string, string>> {
  const tokenResponse: Response = await fetch(ACCESS_TOKEN_ENDPOINT, {
    method: "POST",
    headers: JSON_HEADERS,
    body: JSON.stringify({
      grant_type: "authorization_code",
      client_id: API_CLIENT_ID,
      client_secret: process.env.API_KEY,
      redirect_uri: API_REDIRECT_URL,
      code: code,
    }),
  });

  const tokenData = await tokenResponse.json();
  return new Map<string, string>(Object.entries({
    accountId: tokenData["user"]["id"],
    accessToken: tokenData["access_token"],
    refreshToken: tokenData["refresh_token"],
  }));
}

async function refreshAccessToken(refreshToken: string): Promise<string> {
  const response: Response = await fetch(ACCESS_TOKEN_ENDPOINT, {
    method: "POST",
    headers: JSON_HEADERS,
    body: JSON.stringify({
      grant_type: "refresh_token",
      client_id: API_CLIENT_ID,
      client_secret: process.env.API_KEY,
      refresh_token: refreshToken,
    }),
  });

  const data = await response.json();
  return data["access_token"];
}

async function getProfile(
  accountId: string,
  accessToken: string
): Promise<Map<string, string>> {
  const response: Response = await fetch(
    `${CANVAS_URL}/api/v1/users/${accountId}/profile`, {
      headers: {Authorization: `Bearer ${accessToken}`},
    }
  );

  const data = await response.json();
  return new Map<string, string>(Object.entries({
    email: data["login_id"],
    name: data["name"],
  }));
}

export {getCodeUrl, requestAccessToken, getProfile, refreshAccessToken};
