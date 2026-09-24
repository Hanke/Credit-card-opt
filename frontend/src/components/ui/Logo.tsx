import { cn } from './cn'

interface LogoProps {
  tone?: 'default' | 'inverse'
  className?: string
}

export function Logo({ tone = 'default', className }: LogoProps) {
  return (
    <span className={cn('inline-flex items-center gap-2.5', className)}>
      <span
        className={cn(
          'flex size-8 shrink-0 items-center justify-center rounded-lg shadow-sm',
          tone === 'inverse'
            ? 'bg-white/15 ring-1 ring-white/30 ring-inset'
            : 'bg-gradient-to-br from-brand-500 to-violet-500',
        )}
      >
        <svg viewBox="0 0 24 24" className="size-5" aria-hidden="true">
          <rect x="3" y="6" width="18" height="12" rx="2.5" fill="#fff" fillOpacity="0.95" />
          <rect x="3" y="9" width="18" height="2.5" fill="#4f46e5" />
          <rect x="6" y="13.5" width="5" height="2" rx="1" fill="#a5b4fc" />
        </svg>
      </span>
      <span
        className={cn(
          'text-[15px] font-semibold tracking-tight',
          tone === 'inverse' ? 'text-white' : 'text-slate-900',
        )}
      >
        Card Optimizer
      </span>
    </span>
  )
}
