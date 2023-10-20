/* eslint-disable @typescript-eslint/no-explicit-any */

import {
  CANVAS_URL,
  API_REDIRECT_URL,
  ACCESS_TOKEN_ENDPOINT,
  API_CLIENT_ID,
} from "./constants";
import {Assessments} from "./models/assessment";
import {Courses} from "./models/course";
import {Role, roleFromString} from "./models/role";

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
    accountId: tokenData["user"]["id"].toString(),
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

async function getEndpoint(
  endpointUrl: string,
  accessToken: string
): Promise<any> {
  const response: Response = await fetch(
    `${CANVAS_URL}/api/v1/${endpointUrl}`, {
      headers: {Authorization: `Bearer ${accessToken}`},
    }
  );

  return await response.json();
}

async function getProfile(
  userId: string,
  accessToken: string
): Promise<Map<string, string>> {
  const data = await getEndpoint(`users/${userId}/profile`, accessToken);
  return new Map<string, string>(Object.entries({
    email: data["login_id"],
    name: data["name"],
  }));
}

async function getUserIdsInCourse(
  courseId: number,
  accessToken: string
): Promise<Array<number>> {
  const userIds: Array<number> = [];
  const data = await getEndpoint(`courses/${courseId}/users`, accessToken);
  for (let i = 0; i < data.length; i++) {
    userIds.push(data[i]["id"]);
  }
  return userIds;
}

async function getUserRoleInCourse(
  userId: number,
  courseId: number,
  accessToken: string
): Promise<Role> {
  const data = await getEndpoint(`users/${userId}/courses`, accessToken);
  for (let i = 0; i < data.length; i++) {
    const courseData: any = data[i];
    if (courseData["id"] == courseId) {
      return roleFromString(courseData["enrollments"][0]["type"]);
    }
  }
  return Role.UNKNOWN;
}

async function getAssessmentsInCourse(
  courseId: number,
  accessToken: string
): Promise<Assessments> {
  const data = await getEndpoint(
    `courses/${courseId}/assignments`,
    accessToken
  );
  return Assessments.fromAPI(data);
}

async function injectDataIntoCourses(
  courseData: any,
  accessToken: string
): Promise<void> {
  for (const data of courseData) {
    const roles: Map<string, string> = new Map<string, string>();
    const courseId = data["id"];
    const courseUserIds = await getUserIdsInCourse(courseId, accessToken);
    for (const userId of courseUserIds) {
      const role: Role = await getUserRoleInCourse(
        userId,
        courseId,
        accessToken
      );
      roles.set(
        userId.toString(),
        role.toString()
      );
    }
    const assessments: Assessments = await getAssessmentsInCourse(
      courseId,
      accessToken
    );
    data.assessments = assessments.data();
    data.roles = Object.fromEntries(roles);
  }
}

async function getCourses(accessToken: string): Promise<Courses> {
  const data = await getEndpoint("courses", accessToken);
  await injectDataIntoCourses(data, accessToken);
  return Courses.fromAPI(data);
}

export {
  getCodeUrl,
  requestAccessToken,
  refreshAccessToken,
  getProfile,
  getUserIdsInCourse,
  getUserRoleInCourse,
  getCourses,
};
