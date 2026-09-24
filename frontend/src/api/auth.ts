import { apiDelete, apiGet, apiPost } from './client'
import type { Credentials, SessionResponse, User } from './types'

export function signup(credentials: Credentials): Promise<SessionResponse> {
  return apiPost<SessionResponse>('/api/v1/auth/signup', credentials, { skipUnauthorizedHandler: true })
}

export function login(credentials: Credentials): Promise<SessionResponse> {
  return apiPost<SessionResponse>('/api/v1/auth/login', credentials, { skipUnauthorizedHandler: true })
}

export function logout(): Promise<void> {
  return apiDelete('/api/v1/auth/logout', { skipUnauthorizedHandler: true })
}

export async function getMe(): Promise<User> {
  const { user } = await apiGet<{ user: User }>('/api/v1/auth/me')
  return user
}
