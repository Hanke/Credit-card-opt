import { PageHeader } from '../components/layout/PageHeader'
import { Button, Card } from '../components/ui'

export function WalletPage() {
  return (
    <>
      <PageHeader
        title="Wallet"
        description="The cards you carry."
        actions={<Button>Add card</Button>}
      />
      <Card title="Coming soon" description="Wallet management will land in a later ticket.">
        <p className="text-sm text-slate-600 dark:text-slate-400">No cards yet.</p>
      </Card>
    </>
  )
}
