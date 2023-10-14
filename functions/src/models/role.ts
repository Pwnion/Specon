enum Role {
  STUDENT = "student",
  TEACHER = "teacher",
  OTHER = "other",
  UNKNOWN = "unknown",
}

function roleFromString(roleString: string): Role {
  switch (roleString) {
  case Role.STUDENT: {
    return Role.STUDENT;
  }
  case Role.TEACHER: {
    return Role.TEACHER;
  }
  default: {
    return Role.OTHER;
  }
  }
}

export {Role, roleFromString};
