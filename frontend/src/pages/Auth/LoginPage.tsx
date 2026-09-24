import { useAuth } from '../../hooks/useAuth'
import { AuthCard } from './AuthCard'
import { AuthForm } from './AuthForm'

export function LoginPage() {
  const { login } = useAuth()

  return (
    <AuthCard
      title="Welcome back"
      description="Log in to see which card to use next."
      footerText="New here?"
      footerLinkLabel="Create an account"
      footerLinkTo="/signup"
    >
      <AuthForm
        submit={login}
        submitLabel="Log in"
        pendingLabel="Logging in…"
        passwordAutoComplete="current-password"
      />
    </AuthCard>
  )
}
