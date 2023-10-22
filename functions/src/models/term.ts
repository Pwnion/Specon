/* eslint-disable @typescript-eslint/no-explicit-any */

class Term {
  name: string;
  year: string;

  constructor(name: string, year: string) {
    this.name = name;
    this.year = year;
  }

  static fromAPI(data: any): Term {
    const startAt: string = data["start_at"];
    return new Term(
      data["name"],
      startAt.substring(0, 4)
    );
  }

  data(): object {
    return {
      name: this.name,
      year: this.year,
    };
  }
}

export {Term};
