import { Link, Outlet } from 'react-router-dom'
import { Icon, Logo, type IconName } from '../ui'

const HIGHLIGHTS: ReadonlyArray<{ icon: IconName; title: string; body: string }> = [
  {
    icon: 'zap',
    title: 'Instant answers',
    body: 'Tell us what you are buying and get the best card in your wallet, every time.',
  },
  {
    icon: 'trending-up',
    title: 'Maximize rewards',
    body: 'Stop leaving points and cash back on the table across categories.',
  },
  {
    icon: 'shield',
    title: 'Private by design',
    body: 'We never ask for card numbers. Only the cards you carry and their reward rules.',
  },
]

function CardArt() {
  return (
    <div aria-hidden="true" className="relative mx-auto h-56 w-80">
      <div className="absolute inset-x-6 top-10 h-48 rotate-[-8deg] rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur-sm" />
      <div className="absolute inset-x-0 top-0 flex h-48 flex-col justify-between rounded-2xl bg-gradient-to-br from-white/25 to-white/5 p-5 shadow-float ring-1 ring-white/30 backdrop-blur">
        <div className="flex items-start justify-between">
          <span className="h-8 w-11 rounded-md bg-gradient-to-br from-amber-200 to-amber-400 shadow-inner" />
          <svg viewBox="0 0 24 24" className="size-6 text-white/80" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
            <path d="M8.5 15.5a5 5 0 0 1 0-7" />
            <path d="M5.5 18.5a9 9 0 0 1 0-13" />
            <path d="M11.5 12.5a1.5 1.5 0 0 1 0-1" />
          </svg>
        </div>
        <div className="font-mono text-lg tracking-[0.2em] text-white">•••• •••• •••• 4821</div>
        <div className="flex items-end justify-between text-white">
          <div>
            <div className="text-[10px] tracking-widest text-white/60 uppercase">Card holder</div>
            <div className="text-sm font-medium">Card Optimizer</div>
          </div>
          <div className="flex -space-x-2">
            <span className="size-7 rounded-full bg-red-400/90" />
            <span className="size-7 rounded-full bg-amber-300/90" />
          </div>
        </div>
      </div>
    </div>
  )
}

function BrandPanel() {
  return (
    <aside className="relative hidden overflow-hidden bg-gradient-to-br from-brand-700 via-brand-600 to-violet-600 text-white lg:flex lg:w-[46%] lg:flex-col lg:justify-between lg:p-12">
      <div className="pointer-events-none absolute -top-32 -right-32 size-96 rounded-full bg-white/10 blur-3xl" />
      <div className="pointer-events-none absolute -bottom-40 -left-24 size-96 rounded-full bg-violet-400/30 blur-3xl" />

      <Link to="/" className="relative w-fit rounded-md focus-visible:ring-2 focus-visible:ring-white focus-visible:outline-none">
        <Logo tone="inverse" />
      </Link>

      <div className="relative">
        <CardArt />
        <h2 className="mt-12 text-3xl font-semibold tracking-tight text-balance">
          The right card for every purchase.
        </h2>
        <ul className="mt-8 space-y-5">
          {HIGHLIGHTS.map(({ icon, title, body }) => (
            <li key={title} className="flex gap-3.5">
              <span className="flex size-9 shrink-0 items-center justify-center rounded-lg bg-white/15 ring-1 ring-white/20 ring-inset">
                <Icon name={icon} className="size-4.5" />
              </span>
              <div>
                <div className="font-medium">{title}</div>
                <div className="mt-0.5 text-sm text-white/75">{body}</div>
              </div>
            </li>
          ))}
        </ul>
      </div>

      <p className="relative text-xs text-white/60">© {new Date().getFullYear()} Card Optimizer</p>
    </aside>
  )
}

export function AuthLayout() {
  return (
    <div className="flex min-h-svh">
      <BrandPanel />
      <div className="flex min-h-svh flex-1 flex-col">
        <header className="px-4 py-5 sm:px-8 lg:hidden">
          <Link to="/" className="inline-block rounded-md focus-visible:ring-2 focus-visible:ring-brand-500 focus-visible:outline-none">
            <Logo />
          </Link>
        </header>
        <main className="mx-auto flex w-full max-w-md flex-1 flex-col justify-center px-4 py-8 sm:px-8 sm:py-12">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
