import { Link } from 'react-router-dom'
import { Card } from '../components/ui'

export function NotFoundPage() {
  return (
    <Card title="Page not found" description="That route does not exist.">
      <Link to="/dashboard" className="text-sm font-medium text-slate-900 underline dark:text-slate-100">
        Back to dashboard
      </Link>
    </Card>
  )
}
