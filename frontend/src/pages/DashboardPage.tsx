import { ApiStatus } from '../components/ApiStatus'
import { PageHeader } from '../components/layout/PageHeader'
import { Card } from '../components/ui'

export function DashboardPage() {
  return (
    <>
      <PageHeader
        title="Dashboard"
        description="Overview of your cards and rewards."
        actions={<ApiStatus />}
      />
      <Card title="Coming soon" description="Dashboard content will land in a later ticket.">
        <p className="text-sm text-slate-600 dark:text-slate-400">Nothing to show yet.</p>
      </Card>
    </>
  )
}
