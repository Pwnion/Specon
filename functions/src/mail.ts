import {User} from "./models/user";
import {Course} from "./models/course";
import {countOpenRequests, getCourses, getUsers, sendEmail} from "./db";

/**
 * Maps staff users to the number of open requests they have for each course.
 *
 * @param users - An array of users.
 * @param courses - An array of courses.
 * @returns A mapping of users to courses and their open request counts.
 */
async function getStaffRequestCounts(
  users: Array<User>,
  courses: Array<Course>
): Promise<Map<User, Map<Course, number>>> {
  const data: Map<User, Map<Course, number>> =
    new Map<User, Map<Course, number>>();

  for (const user of users) {
    for (const course of courses) {
      const roles: Map<string, string> = course.roles;
      const role: string | undefined = roles.get(user.id);
      if (role == null || role == "student") continue;
      const requestCount: number = await countOpenRequests(course.uuid);
      if (requestCount == 0) continue;
      if (!data.has(user)) data.set(user, new Map<Course, number>());
      data.get(user)!.set(course, requestCount);
    }
  }
  return data;
}

/**
 * Generates a HTML summary of the number of open requests
 * per course there are.
 *
 * @param courseRequestCounts - A mapping of courses to open request counts.
 * @returns The HTML summary.
 */
function generateStaffSummary(
  courseRequestCounts: Map<Course, number>
): string {
  return Array.from(
    courseRequestCounts,
    ([course, requestCount]) => {
      return [
        `<strong>${course.name}</strong>`,
        `Requests Open: ${requestCount}`,
      ].join("<br>");
    }
  ).join("<br><br>");
}

/**
 * Send summaries of open requests for each course
 * to every staff member.
 */
async function sendStaffEmails(): Promise<void> {
  const users: Array<User> = await getUsers();
  const courses: Array<Course> = await getCourses();
  const staffRequestCounts: Map<User, Map<Course, number>> =
    await getStaffRequestCounts(users, courses);

  for (const [user, courseRequestCounts] of staffRequestCounts) {
    await sendEmail(
      user.email,
      "Specon Summary",
      "<body><h2>Specon Summary</h2><br>" +
      [
        `${generateStaffSummary(courseRequestCounts)}`,
        "Visit https://special-consideration.web.app/ to review your open requests.</body>",
      ].join("<br><br>")
    );
  }
}

/**
 * Send an email to a student to notify them that
 * one of their requests has been considered.
 *
 * @param to - The email address of the student.
 */
async function sendStudentEmail(to: string): Promise<void> {
  await sendEmail(
    to,
    "Specon: Request Considered",
    [
      "<body>One of your requests has considered.",
      "See the result at https://special-consideration.web.app/</body>",
    ].join(" ")
  );
}

export {sendStaffEmails, sendStudentEmail};
