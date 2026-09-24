import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '../hooks/useAuth'
import { redirectAfterAuth } from '../auth/redirectAfterAuth'
import { SessionCheck } from './SessionCheck'

export function GuestRoute() {
  const { user, loading } = useAuth()
  const location = useLocation()

  if (loading) return <SessionCheck />

  if (user) return <Navigate to={redirectAfterAuth(location.state)} replace />

  return <Outlet />
}
