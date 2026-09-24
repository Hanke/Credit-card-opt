import { useCallback, useEffect, useMemo, useState, type ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import * as api from '../api/client'
import type { Credentials, SessionResponse, User } from '../api/client'
import { AuthContext, type AuthContextValue } from './AuthContext'
import { isAuthPath } from './authPaths'
import { tokenStorage } from './tokenStorage'

interface AuthProviderProps {
  children: ReactNode
}

export function AuthProvider({ children }: AuthProviderProps) {
  const navigate = useNavigate()
  const [token, setToken] = useState<string | null>(() => tokenStorage.get())
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState<boolean>(() => tokenStorage.get() !== null)

  const clearSession = useCallback(() => {
    tokenStorage.clear()
    setToken(null)
    setUser(null)
    setLoading(false)
  }, [])

  const applySession = useCallback((session: SessionResponse) => {
    tokenStorage.set(session.token)
    setToken(session.token)
    setUser(session.user)
    setLoading(false)
  }, [])

  useEffect(() => {
    api.setUnauthorizedHandler((failedToken) => {
      if (failedToken !== tokenStorage.get()) return
      clearSession()
      const { pathname, search } = window.location
      if (isAuthPath(pathname)) return
      navigate('/login', { replace: true, state: { from: `${pathname}${search}` } })
    })
    return () => api.setUnauthorizedHandler(null)
  }, [clearSession, navigate])

  useEffect(() => {
    const storedToken = tokenStorage.get()
    if (storedToken === null) return

    let cancelled = false
    const isCurrent = () => !cancelled && tokenStorage.get() === storedToken

    api
      .getMe()
      .then(({ user: currentUser }) => {
        if (isCurrent()) setUser(currentUser)
      })
      .catch(() => {})
      .finally(() => {
        if (isCurrent()) setLoading(false)
      })

    return () => {
      cancelled = true
    }
  }, [])

  const signup = useCallback(
    async (credentials: Credentials) => {
      const session = await api.signup(credentials)
      applySession(session)
      return session.user
    },
    [applySession],
  )

  const login = useCallback(
    async (credentials: Credentials) => {
      const session = await api.login(credentials)
      applySession(session)
      return session.user
    },
    [applySession],
  )

  const logout = useCallback(async () => {
    try {
      await api.logout()
    } catch {}
    clearSession()
  }, [clearSession])

  const value = useMemo<AuthContextValue>(
    () => ({ user, token, loading, signup, login, logout }),
    [user, token, loading, signup, login, logout],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
