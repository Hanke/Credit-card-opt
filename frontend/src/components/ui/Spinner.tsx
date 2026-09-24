import { cn } from './cn'

type Size = 'sm' | 'md' | 'lg'

interface SpinnerProps {
  size?: Size
  label?: string
  className?: string
}

const SIZE_CLASSES: Record<Size, string> = {
  sm: 'size-4 border-2',
  md: 'size-6 border-2',
  lg: 'size-10 border-4',
}

export function Spinner({ size = 'md', label = 'Loading', className }: SpinnerProps) {
  return (
    <span
      role="status"
      aria-label={label}
      className={cn(
        'inline-block animate-spin rounded-full border-slate-300 border-t-slate-900',
        'dark:border-slate-700 dark:border-t-slate-100',
        SIZE_CLASSES[size],
        className,
      )}
    />
  )
}
