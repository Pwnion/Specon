/* eslint-disable @typescript-eslint/no-explicit-any */

/** Represents a Canvas assessment. */
class Assessment {
  id: number;
  name: string;
  dueDate: string;

  /**
   * @param id - The assessment ID.
   * @param name - The assessment name.
   * @param dueDate - The assessment due date.
   */
  constructor(
    id: number,
    name: string,
    dueDate: string,
  ) {
    this.id = id;
    this.name = name;
    this.dueDate = dueDate;
  }

  /**
   * Creates an Assessment object from data retrieved from the Canvas API.
   *
   * @param data - Data from the Canvas API.
   * @returns The resulting assessment object.
   */
  static fromAPI(data: any): Assessment {
    return new Assessment(
      data["id"] as number,
      data["name"] as string,
      data["due_at"] as string,
    );
  }

  /**
   * Converts the data in this assessment object to a plain object.
   *
   * @returns The assessment data in object form.
   */
  data(): object {
    return {
      id: this.id,
      name: this.name,
      due_date: this.dueDate,
    };
  }
}

/** Represents a collection of Canvas assessments. */
class Assessments {
  contents: Array<Assessment>;

  /**
   * @param contents - An array of Canvas assessments.
   */
  constructor(contents: Array<Assessment>) {
    this.contents = contents;
  }

  /**
   * Creates an Assessments object from data retrieved from the Canvas API.
   *
   * @param data - Data from the Canvas API.
   * @returns The resulting assessments object.
   */
  static fromAPI(data: any): Assessments {
    const assessments: Array<Assessment> = [];
    for (let i = 0; i < data.length; i++) {
      assessments.push(Assessment.fromAPI(data[i]));
    }
    return new Assessments(assessments);
  }

  /**
   * Converts the data in this assessments object to a plain object.
   *
   * @returns The assessments data in object form.
   */
  data(): object[] {
    return this.contents.map(
      (assessment) => assessment.data()
    );
  }
}

export {Assessment, Assessments};
