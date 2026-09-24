import { useState, type FormEvent } from 'react'
import type { Credentials } from '../../api/client'
import { Button, Input } from '../../components/ui'
import { FormError } from './FormError'
import { toFormErrors, type FormErrors } from './formErrors'

interface AuthFormProps {
  submit: (credentials: Credentials) => Promise<unknown>
  submitLabel: string
  pendingLabel: string
  passwordAutoComplete: 'current-password' | 'new-password'
  passwordHint?: string
}

export function AuthForm({ submit, submitLabel, pendingLabel, passwordAutoComplete, passwordHint }: AuthFormProps) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [errors, setErrors] = useState<FormErrors>({})
  const [submitting, setSubmitting] = useState(false)

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setSubmitting(true)
    setErrors({})

    try {
      await submit({ email, password })
    } catch (error) {
      setErrors(toFormErrors(error))
      setSubmitting(false)
    }
  }

  return (
    <form className="flex flex-col gap-5" onSubmit={handleSubmit} noValidate>
      <FormError message={errors.form} />
      <Input
        label="Email"
        type="email"
        name="email"
        autoComplete="email"
        placeholder="you@example.com"
        value={email}
        onChange={(event) => setEmail(event.target.value)}
        error={errors.email}
        required
      />
      <div className="flex flex-col gap-1.5">
        <Input
          label="Password"
          type="password"
          name="password"
          autoComplete={passwordAutoComplete}
          placeholder="••••••••"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          error={errors.password}
          required
        />
        {passwordHint && !errors.password && <p className="text-xs text-slate-500">{passwordHint}</p>}
      </div>
      <Button type="submit" size="lg" loading={submitting} className="mt-1 w-full">
        {submitting ? pendingLabel : submitLabel}
      </Button>
    </form>
  )
}
