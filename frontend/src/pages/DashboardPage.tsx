import { Link } from 'react-router-dom'
import { ApiStatus } from '../components/ApiStatus'
import { PageHeader } from '../components/layout/PageHeader'
import { Badge, Card, Icon, LinkButton, type IconName } from '../components/ui'
import { useAuth } from '../hooks/useAuth'

const STEPS: ReadonlyArray<{ icon: IconName; title: string; body: string; to?: string; cta: string }> = [
  {
    icon: 'wallet',
    title: 'Build your wallet',
    body: 'Add the cards you already carry. No card numbers, just the reward rules.',
    to: '/wallet',
    cta: 'Add cards',
  },
  {
    icon: 'sparkles',
    title: 'Ask before you pay',
    body: 'Pick a spending category and we will name the card that earns the most.',
    to: '/recommend',
    cta: 'Get a recommendation',
  },
  {
    icon: 'trending-up',
    title: 'Watch rewards add up',
    body: 'Track how much you are earning by using the right card every time.',
    cta: 'Coming soon',
  },
]

export function DashboardPage() {
  const { user } = useAuth()

  return (
    <>
      <PageHeader
        eyebrow={user ? `Signed in as ${user.email}` : undefined}
        title="Dashboard"
        description="Overview of your cards and rewards."
        actions={<ApiStatus />}
      />

      <Card className="relative overflow-hidden border-transparent bg-gradient-to-br from-brand-600 to-violet-600 text-white">
        <div className="pointer-events-none absolute -top-24 -right-16 size-72 rounded-full bg-white/10 blur-3xl" />
        <div className="relative flex flex-wrap items-center justify-between gap-6">
          <div className="max-w-lg">
            <p className="text-sm font-medium text-white/75">Get started</p>
            <h2 className="mt-1 text-2xl font-semibold tracking-tight text-balance">
              Add your first card and stop guessing at checkout.
            </h2>
            <p className="mt-2 text-sm text-white/80">
              It takes about a minute. You can always add more later.
            </p>
          </div>
          <LinkButton to="/wallet" variant="inverse" size="lg">
            Add a card
            <Icon name="arrow-right" className="size-4" />
          </LinkButton>
        </div>
      </Card>

      <section className="mt-8">
        <h2 className="mb-4 text-sm font-semibold tracking-wide text-slate-500 uppercase">How it works</h2>
        <div className="grid gap-4 sm:grid-cols-3">
          {STEPS.map(({ icon, title, body, to, cta }, index) => (
            <Card key={title} className="flex flex-col">
              <div className="flex items-center justify-between">
                <span className="flex size-10 items-center justify-center rounded-xl bg-brand-50 text-brand-600 ring-1 ring-brand-100 ring-inset">
                  <Icon name={icon} className="size-5" />
                </span>
                <span className="text-xs font-medium text-slate-400">Step {index + 1}</span>
              </div>
              <h3 className="mt-4 font-semibold text-slate-900">{title}</h3>
              <p className="mt-1 flex-1 text-sm leading-relaxed text-slate-500">{body}</p>
              {to ? (
                <Link
                  to={to}
                  className="mt-4 inline-flex items-center gap-1.5 text-sm font-medium text-brand-600 hover:text-brand-700"
                >
                  {cta}
                  <Icon name="arrow-right" className="size-4" />
                </Link>
              ) : (
                <span className="mt-4">
                  <Badge tone="neutral">{cta}</Badge>
                </span>
              )}
            </Card>
          ))}
        </div>
      </section>
    </>
  )
}
