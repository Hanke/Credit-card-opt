import { Card, type CardProps } from './Card'
import { cn } from './cn'

type HeroCardProps = Omit<CardProps, 'title' | 'description'>

export function HeroCard({ className, children, ...props }: HeroCardProps) {
  return (
    <Card
      className={cn(
        'relative overflow-hidden border-transparent bg-gradient-to-br from-brand-600 to-violet-600 text-white',
        className,
      )}
      {...props}
    >
      <div aria-hidden="true" className="pointer-events-none absolute -top-24 -right-16 size-72 rounded-full bg-white/10 blur-3xl" />
      <div className="relative">{children}</div>
    </Card>
  )
}
