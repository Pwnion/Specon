// The suffix that is added by Canvas to roles
// that are built-in to Canvas.
const BASE_ROLE_SUFFIX = "Enrollment";

/**
 * Removes Canvas' built-in role suffix
 * from a role string.
 *
 * @param role - The name of a role.
 * @returns The role name without the suffix.
 */
function cleanseRole(role: string): string {
  if (role.includes(BASE_ROLE_SUFFIX)) {
    const enrollmentIndex: number = role.indexOf(BASE_ROLE_SUFFIX);
    return role.substring(0, enrollmentIndex);
  }
  return role;
}

export {cleanseRole};
