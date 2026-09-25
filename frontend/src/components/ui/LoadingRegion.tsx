import type { ReactNode } from 'react'

interface LoadingRegionProps {
  label: string
  children: ReactNode
}

export function LoadingRegion({ label, children }: LoadingRegionProps) {
  return (
    <div role="status" aria-label={label}>
      {children}
    </div>
  )
}
