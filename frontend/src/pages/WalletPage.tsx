import { PageHeader } from '../components/layout/PageHeader'
import { Button, Card, EmptyState, Icon } from '../components/ui'

export function WalletPage() {
  return (
    <>
      <PageHeader
        title="Wallet"
        description="The cards you carry."
        actions={
          <Button>
            <Icon name="plus" className="size-4" />
            Add card
          </Button>
        }
      />
      <Card>
        <EmptyState
          icon="credit-card"
          title="No cards yet"
          description="Add the cards you carry and we will figure out which one to use for every purchase."
          action={
            <Button>
              <Icon name="plus" className="size-4" />
              Add your first card
            </Button>
          }
        />
      </Card>
    </>
  )
}
