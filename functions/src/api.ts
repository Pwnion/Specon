/* eslint-disable @typescript-eslint/no-explicit-any */

import {
  CANVAS_URL,
  API_REDIRECT_URL,
  ACCESS_TOKEN_ENDPOINT,
  API_CLIENT_ID,
} from "./constants";
import {Assessments} from "./models/assessment";
import {Courses} from "./models/course";
import {Term} from "./models/term";
import {cleanseRole} from "./role";

const JSON_HEADERS = {"Content-Type": "application/json"};

function getCodeUrl(canvasUid: string): string {
  return [
    `${CANVAS_URL}/login/oauth2/auth?`,
    `client_id=${API_CLIENT_ID}&`,
    `response_type=code&state=${canvasUid}&`,
    `redirect_uri=${API_REDIRECT_URL}`,
  ].join("");
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

function getAuthJsonHeaders(accessToken: string): HeadersInit {
  const headers: HeadersInit = new Headers(JSON_HEADERS);
  headers.set("Authorization", `Bearer ${accessToken}`);
  return headers;
}

async function postEndpoint(
  endpointUrl: string,
  params: object,
  accessToken: string | null
): Promise<Response> {
  const headers = accessToken == null ?
    JSON_HEADERS : getAuthJsonHeaders(accessToken);

  return await fetch(`${CANVAS_URL}/api/v1/${endpointUrl}`, {
    method: "POST",
    headers: headers,
    body: JSON.stringify(params),
  });
}

async function requestAccessToken(code: string): Promise<Map<string, string>> {
  const tokenResponse: Response = await postEndpoint(
    ACCESS_TOKEN_ENDPOINT.substring(CANVAS_URL.length),
    {
      grant_type: "authorization_code",
      client_id: API_CLIENT_ID,
      client_secret: process.env.API_KEY,
      redirect_uri: API_REDIRECT_URL,
      code: code,
    },
    null
  );

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
): Promise<string> {
  const data = await getEndpoint(`users/${userId}/courses`, accessToken);
  for (let i = 0; i < data.length; i++) {
    const courseData: any = data[i];
    if (courseData["id"] == courseId) {
      return courseData["enrollments"][0]["role"];
    }
  }
  return "Unknown";
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

async function getTermForAccount(
  accountId: number,
  termId: number,
  accessToken: string
): Promise<Term | null> {
  const data = await getEndpoint(
    `accounts/${accountId}/terms`,
    accessToken
  );
  for (const termData of data["enrollment_terms"]) {
    if (termData["id"] == termId) {
      return Term.fromAPI(termData);
    }
  }
  return null;
}

async function injectDataIntoCourses(
  courseData: any,
  userId: string,
  accessToken: string
): Promise<void> {
  for (const data of courseData) {
    const rootAccountId = data["root_account_id"];
    let term: Term | null = null;
    if (userId == "1" || userId == rootAccountId.toString()) {
      term = await getTermForAccount(
        rootAccountId,
        data["enrollment_term_id"],
        accessToken
      );
    }

    const roles: Map<string, string> = new Map<string, string>();
    const courseId = data["id"];
    const courseUserIds = await getUserIdsInCourse(courseId, accessToken);
    for (const userId of courseUserIds) {
      const role: string = await getUserRoleInCourse(
        userId,
        courseId,
        accessToken
      );
      roles.set(
        userId.toString(),
        cleanseRole(role)
      );
    }
    const assessments: Assessments = await getAssessmentsInCourse(
      courseId,
      accessToken
    );
    data.assessments = assessments.data();
    data.roles = Object.fromEntries(roles);
    data.term = term != null ? term.data() : null;
  }
}

async function getCourses(
  userId: string,
  accessToken: string
): Promise<Courses> {
  const data = await getEndpoint("courses", accessToken);
  await injectDataIntoCourses(data, userId, accessToken);
  return Courses.fromAPI(data);
}

async function createAssignmentOverride(
  accountId: number,
  courseId: number,
  assignmentId: number,
  newDate: string,
  accessToken: string
): Promise<Response> {
  return await postEndpoint(
    `courses/${courseId}/assignments/${assignmentId}/overrides`,
    {
      assignment_override: {
        student_ids: [accountId],
        due_at: newDate,
      },
    },
    accessToken
  );
}

export {
  getCodeUrl,
  requestAccessToken,
  refreshAccessToken,
  getProfile,
  getUserIdsInCourse,
  getUserRoleInCourse,
  getCourses,
  createAssignmentOverride,
};
