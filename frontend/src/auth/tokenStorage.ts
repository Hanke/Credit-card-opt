const STORAGE_KEY = 'auth_token'

export const tokenStorage = {
  get(): string | null {
    try {
      return localStorage.getItem(STORAGE_KEY) || null
    } catch {
      return null
    }
  },

  set(token: string): void {
    try {
      localStorage.setItem(STORAGE_KEY, token)
    } catch {}
  },

  clear(): void {
    try {
      localStorage.removeItem(STORAGE_KEY)
    } catch {}
  },
}
