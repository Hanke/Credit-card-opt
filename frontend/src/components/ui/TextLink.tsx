import { Link, type LinkProps } from 'react-router-dom'
import { cn } from './cn'
import { FOCUS_RING } from './focusRing'

export function TextLink({ className, ...props }: LinkProps) {
  return (
    <Link
      className={cn(
        'inline-flex items-center gap-1.5 rounded-sm text-sm font-medium text-brand-600 transition-colors hover:text-brand-700',
        FOCUS_RING,
        className,
      )}
      {...props}
    />
  )
}
