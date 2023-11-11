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

// HTTP headers to dictate a JSON content type.
const JSON_HEADERS = {"Content-Type": "application/json"};

/**
 * Creates a URL that requests authority from a Canvas user to
 * make Canvas API calls on their behalf.
 *
 * @param canvasUid - A Canvas UUID.
 * @param selectedCourseCode - The course code the Specon link was clicked in.
 * @returns The URL.
 */
function getCodeUrl(canvasUid: string, selectedCourseCode: string): string {
  return [
    `${CANVAS_URL}/login/oauth2/auth?`,
    `client_id=${API_CLIENT_ID}&`,
    `response_type=code&state=${canvasUid}:${selectedCourseCode}&`,
    `redirect_uri=${API_REDIRECT_URL}`,
  ].join("");
}

/**
 * Create HTTP headers that contain an access token to make
 * authenticated calls to the Canvas API.
 *
 * @param accessToken - A Canvas access token.
 * @returns The headers.
 */
function getAuthJsonHeaders(accessToken: string): HeadersInit {
  const headers: HeadersInit = new Headers(JSON_HEADERS);
  headers.set("Authorization", `Bearer ${accessToken}`);
  return headers;
}

/**
 * Make an authenticated HTTP GET request to a Canvas API endpoint.
 *
 * @param endpointUrl - The Canvas endpoint (excluding the domain).
 * @param accessToken - The Canvas access token to authenticate the request.
 * @returns The Canvas instance's JSON response.
 */
async function getEndpoint(
  endpointUrl: string,
  accessToken: string
): Promise<any> {
  const response: Response = await fetch(
    `${CANVAS_URL}/api/v1/${endpointUrl}`, {
      headers: getAuthJsonHeaders(accessToken),
    }
  );
  return await response.json();
}

/**
 * Make a HTTP POST request to a Canvas endpoint.
 *
 * @param endpointUrl - The URL to make the request to.
 * @param params - The body of the POST request.
 * @param accessToken - The access token to authenticate the request (optional).
 * @returns The Canvas instance's JSON response.
 */
async function postEndpoint(
  endpointUrl: string,
  params: object,
  accessToken: string | null
): Promise<any> {
  const headers = accessToken == null ?
    JSON_HEADERS : getAuthJsonHeaders(accessToken);

  const response: Response = await fetch(
    endpointUrl, {
      method: "POST",
      headers: headers,
      body: JSON.stringify(params),
    }
  );

  return await response.json();
}

/**
 * Request an access token from the Canvas instance to
 * perform Canvas API calls on behalf of a user.
 *
 * @param code - A prerequisite code acquired from the Canvas instance.
 * @returns Canvas user information, which includes an access token with a
 * TTL of 1 hour, a refresh token to generate a new access token, and the
 * Canvas user's auto incrementing account ID.
 */
async function requestAccessToken(code: string): Promise<Map<string, string>> {
  const tokenData = await postEndpoint(
    ACCESS_TOKEN_ENDPOINT,
    {
      grant_type: "authorization_code",
      client_id: API_CLIENT_ID,
      client_secret: process.env.API_KEY!,
      redirect_uri: API_REDIRECT_URL,
      code: code,
    },
    null
  );

  return new Map<string, string>(Object.entries({
    accountId: tokenData["user"]["id"].toString(),
    accessToken: tokenData["access_token"],
    refreshToken: tokenData["refresh_token"],
  }));
}

/**
 * Generate a new Canvas access token.
 *
 * @param refreshToken - The Canvas refresh token.
 * @returns The newly generated Canvas access token.
 */
async function refreshAccessToken(refreshToken: string): Promise<string> {
  const response: Response = await fetch(ACCESS_TOKEN_ENDPOINT, {
    method: "POST",
    headers: JSON_HEADERS,
    body: JSON.stringify({
      grant_type: "refresh_token",
      client_id: API_CLIENT_ID,
      client_secret: process.env.API_KEY!,
      refresh_token: refreshToken,
    }),
  });

  const data = await response.json();
  return data["access_token"];
}

/**
 * Get Canvas user profile information.
 *
 * @param userId - A Canvas account ID.
 * @param accessToken - A Canvas access token.
 * @returns Canvas profile information, including the email address or
 * username used by the user to login, and their full name.
 */
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

/**
 * Get the account IDs of all users in a Canvas course.
 *
 * @param courseId - The ID of the Canvas course.
 * @param accessToken - A Canvas access token.
 * @returns The list of Canvas user account IDs.
 */
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

/**
 * Get a user's role in a Canvas course.
 *
 * @param userId - The user's Canvas account ID.
 * @param courseId - The Canvas course ID.
 * @param accessToken - A Canvas access token.
 * @returns The role. Roles are configured by the course admin,
 * but examples of roles would be 'Student', 'Tutor', etc.
 */
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

/**
 * Get all the assessments in a Canvas course.
 *
 * @param courseId - The Canvas course ID.
 * @param accessToken - A Canvas access token.
 * @returns The assessments.
 */
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

/**
 * Lookup a term associated with a Canvas account.
 *
 * @param accountId - The Canvas account ID.
 * @param termId - The Canvas term ID.
 * @param accessToken - A Canvas access token.
 * @returns A term, or null if it couldn't be found.
 */
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

/**
 * Inject role, term and assessment data into a collection of Canvas courses.
 *
 * @param courseData - The course data to inject information into.
 * @param userId - The user's Canvas account ID.
 * @param accessToken - A Canvas access token.
 */
async function injectDataIntoCourses(
  courseData: any,
  userId: string,
  accessToken: string
): Promise<void> {
  for (const data of courseData) {
    // Get the account ID of the owner of the Canvas course.
    const rootAccountId = data["root_account_id"];

    // Try to get the term information for the course if the
    // user is privileged enough.
    let term: Term | null = null;
    if (userId == "1" || userId == rootAccountId.toString()) {
      term = await getTermForAccount(
        rootAccountId,
        data["enrollment_term_id"],
        accessToken
      );
    }

    // Get all the users and their roles in the course.
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

    // Get all the assessments in the course.
    const assessments: Assessments = await getAssessmentsInCourse(
      courseId,
      accessToken
    );

    // Inject the information into the course objects.
    data.assessments = assessments.data();
    data.roles = Object.fromEntries(roles);
    data.term = term != null ? term.data() : null;
  }
}

/**
 * Get all the Canvas course information for a Canvas user.
 *
 * @param userId - The Canvas user's account ID.
 * @param accessToken - A Canvas access token.
 * @returns The Canvas courses.
 */
async function getCourses(
  userId: string,
  accessToken: string
): Promise<Courses> {
  const data = await getEndpoint("courses", accessToken);
  await injectDataIntoCourses(data, userId, accessToken);
  return Courses.fromAPI(data);
}

/**
 * Override the default assignment due date for a Canvas user.
 *
 * @param accountId - The Canvas user's account ID.
 * @param courseId - The ID of the Canvas course the assignment is in.
 * @param assignmentId - The ID of the Canvas assignment.
 * @param newDate - The new due date.
 * @param accessToken - A Canvas access token.
 * @returns The Canvas instance's JSON response.
 */
async function createAssignmentOverride(
  accountId: number,
  courseId: number,
  assignmentId: number,
  newDate: string,
  accessToken: string
): Promise<any> {
  return await postEndpoint(
    [
      `${CANVAS_URL}/api/v1/courses/${courseId}/`,
      `assignments/${assignmentId}/overrides`,
    ].join(""),
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
