import { tokenStorage } from '../auth/tokenStorage'
import type { ApiErrorBody } from './types'

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

export function isApiError(error: unknown): error is ApiError {
  return error instanceof ApiError
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

export function apiGet<T>(path: string, init: ApiRequestInit = {}): Promise<T> {
  return apiFetch<T>(path, { ...init, method: 'GET' })
}

export function apiPost<T>(path: string, body: unknown, init: ApiRequestInit = {}): Promise<T> {
  return apiFetch<T>(path, { ...init, method: 'POST', body: JSON.stringify(body) })
}

export function apiDelete<T = void>(path: string, init: ApiRequestInit = {}): Promise<T> {
  return apiFetch<T>(path, { ...init, method: 'DELETE' })
}

export function withQuery(path: string, params: Record<string, string | number | undefined>): string {
  const query = new URLSearchParams()
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== '') query.set(key, String(value))
  }
  const encoded = query.toString()
  if (!encoded) return path
  return `${path}${path.includes('?') ? '&' : '?'}${encoded}`
}

async function readErrors(response: Response): Promise<string[]> {
  try {
    const body: unknown = await response.json()
    if (isApiErrorBody(body)) {
      return body.errors.filter((error): error is string => typeof error === 'string')
    }
  } catch {}
  return []
}

function isApiErrorBody(body: unknown): body is ApiErrorBody {
  return typeof body === 'object' && body !== null && 'errors' in body && Array.isArray(body.errors)
}
