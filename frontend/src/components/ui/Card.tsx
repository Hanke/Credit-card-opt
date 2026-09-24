import type { HTMLAttributes, ReactNode } from 'react'
import { cn } from './cn'

interface CardProps extends Omit<HTMLAttributes<HTMLDivElement>, 'title'> {
  title?: ReactNode
  description?: ReactNode
}

export function Card({ title, description, className, children, ...props }: CardProps) {
  return (
    <div
      className={cn(
        'rounded-lg border border-slate-200 bg-white p-4 shadow-sm sm:p-6',
        'dark:border-slate-800 dark:bg-slate-900',
        className,
      )}
      {...props}
    >
      {(title || description) && (
        <div className="mb-4">
          {title && (
            <h2 className="text-lg font-semibold text-slate-900 dark:text-slate-100">{title}</h2>
          )}
          {description && (
            <p className="mt-1 text-sm text-slate-500 dark:text-slate-400">{description}</p>
          )}
        </div>
      )}
      {children}
    </div>
  )
}
