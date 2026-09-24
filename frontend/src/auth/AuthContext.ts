import { createContext } from 'react'
import type { Credentials, User } from '../api/client'

export interface AuthContextValue {
  user: User | null
  token: string | null
  loading: boolean
  signup: (credentials: Credentials) => Promise<User>
  login: (credentials: Credentials) => Promise<User>
  logout: () => Promise<void>
}

export const AuthContext = createContext<AuthContextValue | null>(null)
