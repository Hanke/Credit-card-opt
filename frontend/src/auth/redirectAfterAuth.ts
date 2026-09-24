import { isAuthPath } from './authPaths'

const DEFAULT_AFTER_AUTH = '/dashboard'

export function redirectAfterAuth(state: unknown): string {
  if (!state || typeof state !== 'object' || !('from' in state)) return DEFAULT_AFTER_AUTH

  const from = state.from
  if (typeof from !== 'string' || !from.startsWith('/') || from.startsWith('//')) {
    return DEFAULT_AFTER_AUTH
  }

  const [pathname] = from.split('?', 1)
  if (isAuthPath(pathname)) return DEFAULT_AFTER_AUTH

  return from
}
