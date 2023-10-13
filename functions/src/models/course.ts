class Course {
  uuid: string;
  id: number;
  name: string;
  code: string;
  users: Map<string, string>;

  constructor(
    uuid: string,
    id: number,
    name: string,
    code: string,
    users: Map<string, string>
  ) {
    this.uuid = uuid;
    this.id = id;
    this.name = name;
    this.code = code;
    this.users = users;
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  static fromAPI(data: any): Course {
    return new Course(
      data["uuid"] as string,
      data["id"] as number,
      data["name"] as string,
      data["course_code"] as string,
      data["users"] as Map<string, string>
    );
  }

  data(): object {
    return {
      uuid: this.uuid,
      id: this.id,
      name: this.name,
      code: this.code,
      users: this.users,
    };
  }
}

class Courses {
  contents: Array<Course>;

  constructor(contents: Array<Course>) {
    this.contents = contents;
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  static fromAPI(data: any): Courses {
    const courses: Array<Course> = [];
    for (let i = 0; i < data.length; i++) {
      courses.push(Course.fromAPI(data));
    }
    return new Courses(courses);
  }

  data(): object {
    return {
      courses: this.contents.map(
        (course) => course.data()
      ),
    };
  }
}

export {Course, Courses};
