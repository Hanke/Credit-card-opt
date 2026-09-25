import { Button, Card, HeroCard, Icon, SectionHeading, TextLink, type IconName } from '../../components/ui'

const STEPS: ReadonlyArray<{ icon: IconName; title: string; body: string }> = [
  {
    icon: 'wallet',
    title: 'Build your wallet',
    body: 'Add the cards you already carry. No card numbers, just the reward rules.',
  },
  {
    icon: 'sparkles',
    title: 'Ask before you pay',
    body: 'Enter an amount and a category and we will name the card that earns the most.',
  },
  {
    icon: 'trending-up',
    title: 'See the math',
    body: 'Every card in your wallet is ranked side by side, with the reasoning for each.',
  },
]

interface OnboardingProps {
  onAddCard: () => void
}

export function Onboarding({ onAddCard }: OnboardingProps) {
  return (
    <>
      <HeroCard as="section" aria-label="Get started">
        <div className="flex flex-wrap items-center justify-between gap-6">
          <div className="max-w-lg">
            <p className="text-sm font-medium text-white/75">Get started</p>
            <h2 className="mt-1 text-2xl font-semibold tracking-tight text-balance">
              Add your first card and stop guessing at checkout.
            </h2>
            <p className="mt-2 text-sm text-white/80">It takes about a minute. You can always add more later.</p>
          </div>
          <Button variant="inverse" size="lg" onClick={onAddCard}>
            <Icon name="plus" className="size-4" />
            Add your first card
          </Button>
        </div>
      </HeroCard>

      <section className="mt-8">
        <SectionHeading className="mb-4">How it works</SectionHeading>
        <ol className="grid gap-4 sm:grid-cols-3">
          {STEPS.map(({ icon, title, body }, index) => (
            <li key={title}>
              <Card className="flex h-full flex-col">
                <div className="flex items-center justify-between">
                  <span className="flex size-10 items-center justify-center rounded-xl bg-brand-50 text-brand-600 ring-1 ring-brand-100 ring-inset">
                    <Icon name={icon} className="size-5" />
                  </span>
                  <span className="text-xs font-medium text-slate-400">Step {index + 1}</span>
                </div>
                <h3 className="mt-4 font-semibold text-slate-900">{title}</h3>
                <p className="mt-1 flex-1 text-sm leading-relaxed text-slate-500">{body}</p>
              </Card>
            </li>
          ))}
        </ol>
        <p className="mt-4 text-sm text-slate-500">
          Prefer to browse first?{' '}
          <TextLink to="/wallet">
            Open your wallet
          </TextLink>
        </p>
      </section>
    </>
  )
}
