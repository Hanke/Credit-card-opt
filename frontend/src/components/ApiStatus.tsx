import { useEffect, useState } from 'react'
import { getHealth, type HealthResponse } from '../api'
import { Badge, Spinner } from './ui'

type Status =
  | { kind: 'loading' }
  | { kind: 'ok'; data: HealthResponse }
  | { kind: 'error'; message: string }

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
      <span className="inline-flex items-center gap-2 text-sm text-slate-500">
        <Spinner size="sm" /> Connecting…
      </span>
    )
  }

  if (status.kind === 'error') {
    return (
      <Badge tone="danger" role="alert" title={status.message}>
        <span className="size-1.5 rounded-full bg-red-500" />
        Offline
        <span className="sr-only">: {status.message}</span>
      </Badge>
    )
  }

  const checkedAt = new Date(status.data.time).toLocaleTimeString()

  return (
    <Badge tone="success" role="status" aria-live="polite" title={`Checked at ${checkedAt}`}>
      <span className="size-1.5 rounded-full bg-emerald-500" />
      Connected
      <span className="sr-only">, checked at {checkedAt}</span>
    </Badge>
  )
}
