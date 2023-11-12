/* eslint-disable @typescript-eslint/no-explicit-any */

import {DocumentData, DocumentSnapshot} from "firebase-admin/firestore";

/** Represents a Canvas course. */
class Course {
  uuid: string;
  id: number;
  name: string;
  code: string;
  term: Map<string, string>;
  roles: Map<string, string>;
  assessments: Array<Map<string, string>>;

  /**
   * @param uuid - The course UUID.
   * @param id - The course ID.
   * @param name - The course name.
   * @param code - The course code.
   * @param term - The term the course takes place over.
   * @param roles - The users in the course and their roles in the course.
   * @param assessments - The assessments for the course.
   */
  constructor(
    uuid: string,
    id: number,
    name: string,
    code: string,
    term: Map<string, string>,
    roles: Map<string, string>,
    assessments: Array<Map<string, string>>
  ) {
    this.uuid = uuid;
    this.id = id;
    this.name = name;
    this.code = code;
    this.term = term;
    this.roles = roles;
    this.assessments = assessments;
  }

  /**
   * Creates a Course object from data retrieved from the Canvas API.
   *
   * @param data - Data from the Canvas API.
   * @returns The resulting course object.
   */
  static fromAPI(data: any): Course {
    return new Course(
      data["uuid"] as string,
      data["id"] as number,
      data["name"] as string,
      data["course_code"] as string,
      data["term"] as Map<string, string>,
      data["roles"] as Map<string, string>,
      data["assessments"] as Array<Map<string, string>>
    );
  }

  /**
   * Creates a Course object from data retrieved from the database.
   *
   * @param snapshot - Data from the database.
   * @returns The resulting course object.
   */
  static fromDB(snapshot: DocumentSnapshot): Course {
    const data: DocumentData = snapshot.data()!;
    return new Course(
      snapshot.id,
      data["id"],
      data["name"],
      data["code"],
      data["term"],
      new Map<string, string>(Object.entries(data["roles"])),
      data["assessments"]
    );
  }

  /**
   * Converts the data in this course object to a plain object.
   *
   * @returns The course data in object form.
   */
  data(): object {
    return {
      uuid: this.uuid,
      id: this.id,
      name: this.name,
      code: this.code,
      term: this.term,
      roles: this.roles,
      assessments: this.assessments,
    };
  }
}

/** Represents a collection of Canvas courses. */
class Courses {
  contents: Array<Course>;

  /**
   * @param contents - An array of Canvas courses.
   */
  constructor(contents: Array<Course>) {
    this.contents = contents;
  }

  /**
   * Creates a Courses object from data retrieved from the Canvas API.
   *
   * @param data - Data from the Canvas API.
   * @returns The resulting courses object.
   */
  static fromAPI(data: any): Courses {
    const courses: Array<Course> = [];
    for (let i = 0; i < data.length; i++) {
      courses.push(Course.fromAPI(data[i]));
    }
    return new Courses(courses);
  }

  /**
   * Converts the data in this courses object to a plain object.
   *
   * @returns The courses data in object form.
   */
  data(): object[] {
    return this.contents.map(
      (course) => course.data()
    );
  }
}

export {Course, Courses};
