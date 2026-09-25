import { useAuth } from '../../hooks/useAuth'
import { useDocumentTitle } from '../../hooks/useDocumentTitle'
import { AuthCard } from './AuthCard'
import { AuthForm } from './AuthForm'

export function LoginPage() {
  useDocumentTitle('Log in')
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
