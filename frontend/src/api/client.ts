import { tokenStorage } from '../auth/tokenStorage'

const BASE_URL = import.meta.env.VITE_API_URL ?? ''

export class ApiError extends Error {
  readonly status: number
  readonly errors: string[]

  constructor(status: number, errors: string[], fallbackMessage: string) {
    super(errors[0] ?? fallbackMessage)
    this.name = 'ApiError'
    this.status = status
    this.errors = errors
  }
}

type UnauthorizedHandler = (failedToken: string | null) => void

let unauthorizedHandler: UnauthorizedHandler | null = null

export function setUnauthorizedHandler(handler: UnauthorizedHandler | null): void {
  unauthorizedHandler = handler
}

function handleUnauthorized(failedToken: string | null): void {
  unauthorizedHandler?.(failedToken)
}

export interface ApiRequestInit extends RequestInit {
  skipUnauthorizedHandler?: boolean
}

export async function apiFetch<T>(path: string, init: ApiRequestInit = {}): Promise<T> {
  const { skipUnauthorizedHandler = false, headers, ...rest } = init

  const requestHeaders = new Headers(headers)
  if (!requestHeaders.has('Content-Type')) {
    requestHeaders.set('Content-Type', 'application/json')
  }
  const token = tokenStorage.get()
  if (token) {
    requestHeaders.set('Authorization', `Bearer ${token}`)
  }

  const response = await fetch(`${BASE_URL}${path}`, { ...rest, headers: requestHeaders })

  if (response.status === 401 && !skipUnauthorizedHandler) {
    handleUnauthorized(token)
  }

  if (!response.ok) {
    throw new ApiError(
      response.status,
      await readErrors(response),
      `Request to ${path} failed with ${response.status}`,
    )
  }

  if (response.status === 204) {
    return undefined as T
  }

  return (await response.json()) as T
}

async function readErrors(response: Response): Promise<string[]> {
  try {
    const body: unknown = await response.json()
    if (body && typeof body === 'object' && 'errors' in body && Array.isArray(body.errors)) {
      return body.errors.filter((error): error is string => typeof error === 'string')
    }
  } catch {}
  return []
}

export interface HealthResponse {
  status: string
  time: string
}

export function getHealth(): Promise<HealthResponse> {
  return apiFetch<HealthResponse>('/api/v1/health')
}

export interface User {
  id: number
  email: string
  created_at: string
}

export interface Credentials {
  email: string
  password: string
}

export interface SessionResponse {
  token: string
  user: User
}

export function signup(credentials: Credentials): Promise<SessionResponse> {
  return apiFetch<SessionResponse>('/api/v1/auth/signup', {
    method: 'POST',
    body: JSON.stringify(credentials),
    skipUnauthorizedHandler: true,
  })
}

export function login(credentials: Credentials): Promise<SessionResponse> {
  return apiFetch<SessionResponse>('/api/v1/auth/login', {
    method: 'POST',
    body: JSON.stringify(credentials),
    skipUnauthorizedHandler: true,
  })
}

export function logout(): Promise<void> {
  return apiFetch<void>('/api/v1/auth/logout', {
    method: 'DELETE',
    skipUnauthorizedHandler: true,
  })
}

export function getMe(): Promise<{ user: User }> {
  return apiFetch<{ user: User }>('/api/v1/auth/me')
}
