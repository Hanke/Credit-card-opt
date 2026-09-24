const STORAGE_KEY = 'auth_token'

let cached: string | null | undefined

function readStored(): string | null {
  try {
    return localStorage.getItem(STORAGE_KEY) || null
  } catch {
    return null
  }
}

export const tokenStorage = {
  get(): string | null {
    if (cached === undefined) cached = readStored()
    return cached
  },

  set(token: string): void {
    cached = token
    try {
      localStorage.setItem(STORAGE_KEY, token)
    } catch {}
  },

  clear(): void {
    cached = null
    try {
      localStorage.removeItem(STORAGE_KEY)
    } catch {}
  },
}
