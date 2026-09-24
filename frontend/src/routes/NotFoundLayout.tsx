import { AppShell } from '../components/layout/AppShell'
import { AuthLayout } from '../components/layout/AuthLayout'
import { useAuth } from '../hooks/useAuth'
import { SessionCheck } from './SessionCheck'

export function NotFoundLayout() {
  const { user, loading } = useAuth()

  if (loading) return <SessionCheck />

  return user ? <AppShell /> : <AuthLayout />
}
