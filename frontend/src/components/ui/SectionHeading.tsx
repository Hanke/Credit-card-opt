import type { HTMLAttributes } from 'react'
import { cn } from './cn'

export function SectionHeading({ className, ...props }: HTMLAttributes<HTMLHeadingElement>) {
  return <h2 className={cn('text-sm font-semibold tracking-wide text-slate-500 uppercase', className)} {...props} />
}
