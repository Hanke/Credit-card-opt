const AUTH_PATHS = ['/login', '/signup']

export function isAuthPath(pathname: string): boolean {
  return AUTH_PATHS.includes(pathname)
}
