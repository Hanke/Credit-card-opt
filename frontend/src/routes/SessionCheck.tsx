import { Logo, Spinner } from '../components/ui'

export function SessionCheck() {
  return (
    <div className="flex min-h-svh flex-col items-center justify-center gap-6">
      <Logo />
      <Spinner size="lg" label="Checking your session" />
    </div>
  )
}
