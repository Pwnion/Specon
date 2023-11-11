/* eslint-disable @typescript-eslint/no-explicit-any */

import {DocumentData, DocumentSnapshot} from "firebase-admin/firestore";

class Course {
  uuid: string;
  id: number;
  name: string;
  code: string;
  term: Map<string, string>;
  roles: Map<string, string>;
  assessments: Array<Map<string, string>>;

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

class Courses {
  contents: Array<Course>;

  constructor(contents: Array<Course>) {
    this.contents = contents;
  }

  static fromAPI(data: any): Courses {
    const courses: Array<Course> = [];
    for (let i = 0; i < data.length; i++) {
      courses.push(Course.fromAPI(data[i]));
    }
    return new Courses(courses);
  }

  data(): object[] {
    return this.contents.map(
      (course) => course.data()
    );
  }
}

export {Course, Courses};
