/* eslint-disable @typescript-eslint/no-explicit-any */

/** Represents a Canvas assessment. */
class AssessmentOverride {
  id: number | null;
  assignmentId: number;
  studentAccountIds: Array<number>;
  dueDate: string;

  /**
   * @param id - The assessment override ID.
   * @param assignmentId - The assessment ID the override applies to.
   * @param studentAccountIds - The student account ids the override applies to.
   * @param dueDate - The new due date for the assessment.
   */
  constructor(
    id: number | null,
    assignmentId: number,
    studentAccountIds: Array<number>,
    dueDate: string,
  ) {
    this.id = id;
    this.assignmentId = assignmentId;
    this.studentAccountIds = studentAccountIds;
    this.dueDate = dueDate;
  }

  /**
   * Creates an AssessmentOverride object from data
   * retrieved from the Canvas API.
   *
   * @param data - Data from the Canvas API.
   * @returns The resulting assessment override object.
   */
  static fromAPI(data: any): AssessmentOverride {
    return new AssessmentOverride(
      data["id"] as number,
      data["assignment_id"] as number,
      data["student_ids"] as Array<number>,
      data["due_at"] as string
    );
  }

  /**
   * Converts the relevant data in this assessment
   * override object to a plain object.
   *
   * @returns The relevant assessment override data in object form.
   */
  data(): object {
    return {
      student_ids: this.studentAccountIds,
      due_at: this.dueDate,
    };
  }
}

/** Represents a collection of Canvas assessments. */
class AssessmentOverrides {
  contents: Array<AssessmentOverride>;

  /**
   * @param contents - An array of Canvas assessment overrides.
   */
  constructor(contents: Array<AssessmentOverride>) {
    this.contents = contents;
  }

  /**
   * Tries to find an assignment override with the given Canvas account ID.
   *
   * @param accountId - A Canvas account ID.
   * @returns The matching assignment override, or null if a match wasn't found.
   */
  findStudentOverride(accountId: number): AssessmentOverride | null {
    for (const assignmentOverride of this.contents) {
      if (assignmentOverride.studentAccountIds.includes(accountId)) {
        return assignmentOverride;
      }
    }
    return null;
  }

  /**
   * Creates an AssessmentOverrides object from data
   * retrieved from the Canvas API.
   *
   * @param data - Data from the Canvas API.
   * @returns The resulting assessment overrides object.
   */
  static fromAPI(data: any): AssessmentOverrides {
    const assessmentOverrides: Array<AssessmentOverride> = [];
    for (let i = 0; i < data.length; i++) {
      assessmentOverrides.push(AssessmentOverride.fromAPI(data[i]));
    }
    return new AssessmentOverrides(assessmentOverrides);
  }
}

export {AssessmentOverride, AssessmentOverrides};
