import { useEffect, useState } from 'react'
import { getHealth, type HealthResponse } from '../api/client'
import { Badge, Spinner } from './ui'

type Status =
  | { kind: 'loading' }
  | { kind: 'ok'; data: HealthResponse }
  | { kind: 'error'; message: string }

/** Small indicator showing whether the Rails API is reachable. */
export function ApiStatus() {
  const [status, setStatus] = useState<Status>({ kind: 'loading' })

  useEffect(() => {
    let cancelled = false
    getHealth()
      .then((data) => {
        if (!cancelled) setStatus({ kind: 'ok', data })
      })
      .catch((err: Error) => {
        if (!cancelled) setStatus({ kind: 'error', message: err.message })
      })
    return () => {
      cancelled = true
    }
  }, [])

  if (status.kind === 'loading') {
    return (
      <span className="inline-flex items-center gap-2 text-sm text-slate-500 dark:text-slate-400">
        <Spinner size="sm" /> Checking API…
      </span>
    )
  }

  if (status.kind === 'error') {
    return (
      <span role="alert" className="inline-flex items-center gap-2 text-sm text-slate-600 dark:text-slate-400">
        <Badge tone="danger">API offline</Badge>
        <span className="text-slate-500 dark:text-slate-400">{status.message}</span>
      </span>
    )
  }

  return (
    <span
      role="status"
      aria-live="polite"
      className="inline-flex items-center gap-2 text-sm text-slate-600 dark:text-slate-400"
    >
      <Badge tone="success">API {status.data.status}</Badge>
      <span className="text-slate-500 dark:text-slate-400">
        as of {new Date(status.data.time).toLocaleTimeString()}
      </span>
    </span>
  )
}
