/* eslint-disable @typescript-eslint/no-explicit-any */

class Course {
  uuid: string;
  id: number;
  name: string;
  code: string;
  roles: Map<string, string>;
  assessments: Array<Map<string, string>>;

  constructor(
    uuid: string,
    id: number,
    name: string,
    code: string,
    roles: Map<string, string>,
    assessments: Array<Map<string, string>>
  ) {
    this.uuid = uuid;
    this.id = id;
    this.name = name;
    this.code = code;
    this.roles = roles;
    this.assessments = assessments;
  }

  static fromAPI(data: any): Course {
    return new Course(
      data["uuid"] as string,
      data["id"] as number,
      data["name"] as string,
      data["course_code"] as string,
      data["roles"] as Map<string, string>,
      data["assessments"] as Array<Map<string, string>>
    );
  }

  data(): object {
    return {
      uuid: this.uuid,
      id: this.id,
      name: this.name,
      code: this.code,
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
