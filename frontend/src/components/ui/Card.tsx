import type { HTMLAttributes, ReactNode } from 'react'
import { cn } from './cn'

interface CardProps extends Omit<HTMLAttributes<HTMLDivElement>, 'title'> {
  title?: ReactNode
  description?: ReactNode
}

export function Card({ title, description, className, children, ...props }: CardProps) {
  return (
    <div
      className={cn('rounded-2xl border border-slate-200/80 bg-white p-5 shadow-card sm:p-6', className)}
      {...props}
    >
      {(title || description) && (
        <div className="mb-5">
          {title && <h2 className="text-lg font-semibold tracking-tight text-slate-900">{title}</h2>}
          {description && <p className="mt-1 text-sm text-slate-500">{description}</p>}
        </div>
      )}
      {children}
    </div>
  )
}
