import { cn } from './cn'

type Size = 'sm' | 'md' | 'lg'
type Tone = 'default' | 'inverse'

interface SpinnerProps {
  size?: Size
  tone?: Tone
  label?: string
  className?: string
}

const SIZE_CLASSES: Record<Size, string> = {
  sm: 'size-4 border-2',
  md: 'size-6 border-2',
  lg: 'size-10 border-[3px]',
}

const TONE_CLASSES: Record<Tone, string> = {
  default: 'border-brand-200 border-t-brand-600',
  inverse: 'border-white/30 border-t-white',
}

export function Spinner({ size = 'md', tone = 'default', label = 'Loading', className }: SpinnerProps) {
  return (
    <span
      role="status"
      aria-label={label}
      className={cn('inline-block animate-spin rounded-full', SIZE_CLASSES[size], TONE_CLASSES[tone], className)}
    />
  )
}
