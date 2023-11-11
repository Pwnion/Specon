/* eslint-disable max-len */

import {User} from "./models/user";
import {Course} from "./models/course";
import {countOpenRequests, getCourses, getUsers, sendEmail} from "./db";

async function getStaffRequestCounts(
  users: Array<User>,
  courses: Array<Course>
): Promise<Map<User, Map<Course, number>>> {
  const data: Map<User, Map<Course, number>> = new Map<User, Map<Course, number>>();
  for (const user of users) {
    data.set(user, new Map<Course, number>());
    for (const course of courses) {
      const roles: Map<string, string> = course.roles;
      const role: string | undefined = roles.get(user.id);
      if (role == null || role == "student") continue;
      const requestCount: number = await countOpenRequests(course.uuid);
      data.get(user)!.set(course, requestCount);
    }
  }
  return data;
}

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

async function sendStaffEmails(): Promise<void> {
  const users: Array<User> = await getUsers();
  const courses: Array<Course> = await getCourses();
  const staffRequestCounts: Map<User, Map<Course, number>> =
    await getStaffRequestCounts(users, courses);

  for (const [user, courseRequestCounts] of staffRequestCounts) {
    await sendEmail(
      user.email,
      "Specon Summary",
      [
        "<body><h2>Specon Summary</h2><br><br>",
        `${generateStaffSummary(courseRequestCounts)}<br><br>`,
        "https://special-consideration.web.app/<body>",
      ].join("")
    );
  }
}

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
