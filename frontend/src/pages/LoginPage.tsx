import { Link } from 'react-router-dom'
import { Button, Card, Input } from '../components/ui'

export function LoginPage() {
  return (
    <Card title="Log in" description="Welcome back.">
      <form className="flex flex-col gap-4" onSubmit={(event) => event.preventDefault()}>
        <Input label="Email" type="email" autoComplete="email" placeholder="you@example.com" />
        <Input label="Password" type="password" autoComplete="current-password" />
        <Button type="submit">Log in</Button>
      </form>
      <p className="mt-4 text-sm text-slate-500 dark:text-slate-400">
        No account?{' '}
        <Link to="/signup" className="font-medium text-slate-900 underline dark:text-slate-100">
          Sign up
        </Link>
      </p>
    </Card>
  )
}
