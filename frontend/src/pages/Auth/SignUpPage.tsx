import { useAuth } from '../../hooks/useAuth'
import { AuthCard } from './AuthCard'
import { AuthForm } from './AuthForm'

export function SignUpPage() {
  const { signup } = useAuth()

  return (
    <AuthCard
      title="Create your account"
      description="Add the cards you carry and never guess which one to use again."
      footerText="Already have an account?"
      footerLinkLabel="Log in"
      footerLinkTo="/login"
    >
      <AuthForm
        submit={signup}
        submitLabel="Create account"
        pendingLabel="Creating account…"
        passwordAutoComplete="new-password"
        passwordHint="At least 8 characters."
      />
    </AuthCard>
  )
}
