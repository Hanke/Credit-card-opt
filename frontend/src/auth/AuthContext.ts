import { createContext } from 'react'
import type { Credentials, User } from '../api/client'

export interface AuthContextValue {
  user: User | null
  loading: boolean
  signup: (credentials: Credentials) => Promise<User>
  login: (credentials: Credentials) => Promise<User>
  logout: () => void
}

export const AuthContext = createContext<AuthContextValue | null>(null)
