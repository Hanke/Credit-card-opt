import { PageHeader } from '../components/layout/PageHeader'
import { Card } from '../components/ui'

export function RecommendPage() {
  return (
    <>
      <PageHeader title="Recommend" description="Find the best card for a purchase." />
      <Card title="Coming soon" description="Recommendations will land in a later ticket.">
        <p className="text-sm text-slate-600 dark:text-slate-400">Pick a category to get a recommendation.</p>
      </Card>
    </>
  )
}
