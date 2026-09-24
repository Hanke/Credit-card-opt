import { Link } from 'react-router-dom'
import { Button, Card, Input } from '../components/ui'

export function SignupPage() {
  return (
    <Card title="Sign up" description="Create an account to start optimizing.">
      <form className="flex flex-col gap-4" onSubmit={(event) => event.preventDefault()}>
        <Input label="Email" type="email" autoComplete="email" placeholder="you@example.com" />
        <Input label="Password" type="password" autoComplete="new-password" />
        <Button type="submit">Create account</Button>
      </form>
      <p className="mt-4 text-sm text-slate-500 dark:text-slate-400">
        Already have an account?{' '}
        <Link to="/login" className="font-medium text-slate-900 underline dark:text-slate-100">
          Log in
        </Link>
      </p>
    </Card>
  )
}
