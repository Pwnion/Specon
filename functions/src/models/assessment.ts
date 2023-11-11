/* eslint-disable @typescript-eslint/no-explicit-any */

class Assessment {
  id: number;
  name: string;
  dueDate: string;
  constructor(
    id: number,
    name: string,
    dueDate: string,
  ) {
    this.id = id;
    this.name = name;
    this.dueDate = dueDate;
  }

  static fromAPI(data: any): Assessment {
    return new Assessment(
      data["id"] as number,
      data["name"] as string,
      data["due_at"] as string,
    );
  }

  data(): object {
    return {
      id: this.id,
      name: this.name,
      due_date: this.dueDate,
    };
  }
}

class Assessments {
  contents: Array<Assessment>;

  constructor(contents: Array<Assessment>) {
    this.contents = contents;
  }

  static fromAPI(data: any): Assessments {
    const assessments: Array<Assessment> = [];
    for (let i = 0; i < data.length; i++) {
      assessments.push(Assessment.fromAPI(data[i]));
    }
    return new Assessments(assessments);
  }

  data(): object[] {
    return this.contents.map(
      (assessment) => assessment.data()
    );
  }
}

export {Assessment, Assessments};
