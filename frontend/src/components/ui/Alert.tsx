import type { ReactNode } from 'react'
import { Icon } from './Icon'
import { cn } from './cn'

interface AlertProps {
  message: string
  action?: ReactNode
  className?: string
}

export function Alert({ message, action, className }: AlertProps) {
  return (
    <div
      role="alert"
      className={cn(
        'flex items-start gap-2.5 rounded-lg border border-red-200 bg-red-50 px-3.5 py-3 text-sm text-red-700',
        className,
      )}
    >
      <Icon name="alert" className="mt-0.5 size-4 shrink-0" />
      <span className="flex-1">{message}</span>
      {action}
    </div>
  )
}
