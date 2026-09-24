import { useEffect, useState } from 'react'
import { getHealth, type HealthResponse } from './api/client'
import './App.css'

type HealthState =
  | { kind: 'loading' }
  | { kind: 'ok'; data: HealthResponse }
  | { kind: 'error'; message: string }

function App() {
  const [health, setHealth] = useState<HealthState>({ kind: 'loading' })

  useEffect(() => {
    getHealth()
      .then((data) => setHealth({ kind: 'ok', data }))
      .catch((err: Error) => setHealth({ kind: 'error', message: err.message }))
  }, [])

  return (
    <main>
      <h1>Credit Card Optimizer</h1>
      <section>
        <h2>API status</h2>
        {health.kind === 'loading' && <p>Checking backend…</p>}
        {health.kind === 'ok' && (
          <p>
            Backend is <strong>{health.data.status}</strong> as of {health.data.time}
          </p>
        )}
        {health.kind === 'error' && <p role="alert">Backend unreachable: {health.message}</p>}
      </section>
    </main>
  )
}

export default App
