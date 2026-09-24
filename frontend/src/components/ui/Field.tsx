import type { ReactNode } from 'react'
import { errorId } from './fieldHelpers'

interface FieldProps {
  id: string
  label?: string
  error?: string
  children: ReactNode
}

/** Shared label + error wrapper used by Input and Select. */
export function Field({ id, label, error, children }: FieldProps) {
  return (
    <div className="flex flex-col gap-1">
      {label && (
        <label htmlFor={id} className="text-sm font-medium text-slate-700 dark:text-slate-300">
          {label}
        </label>
      )}
      {children}
      {error && (
        <p id={errorId(id)} className="text-sm text-red-600 dark:text-red-400">
          {error}
        </p>
      )}
    </div>
  )
}
