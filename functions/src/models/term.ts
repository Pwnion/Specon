/* eslint-disable @typescript-eslint/no-explicit-any */

/** Represents a Canvas term. */
class Term {
  name: string;
  year: string;

  /**
   * @param name - The term name.
   * @param year - The term year.
   */
  constructor(name: string, year: string) {
    this.name = name;
    this.year = year;
  }

  /**
   * Creates a Term object from data retrieved from the Canvas API.
   *
   * @param data - Data from the Canvas API.
   * @returns The resulting term object.
   */
  static fromAPI(data: any): Term {
    return new Term(
      data["name"],
      data["start_at"].substring(0, 4)
    );
  }

  /**
   * Converts the data in this term object to a plain object.
   *
   * @returns The term data in object form.
   */
  data(): object {
    return {
      name: this.name,
      year: this.year,
    };
  }
}

export {Term};
