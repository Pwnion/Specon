const BASE_ROLE_SUFFIX = "Enrollment";

function cleanseRole(role: string): string {
  if (role.includes(BASE_ROLE_SUFFIX)) {
    const enrollmentIndex: number = role.indexOf(BASE_ROLE_SUFFIX);
    return role.substring(0, enrollmentIndex);
  }
  return role;
}

export {cleanseRole};
