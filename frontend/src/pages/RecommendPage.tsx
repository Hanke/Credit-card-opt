import { PageHeader } from '../components/layout/PageHeader'
import { Card, EmptyState, Icon, LinkButton } from '../components/ui'

export function RecommendPage() {
  return (
    <>
      <PageHeader title="Recommend" description="Find the best card for a purchase." />
      <Card>
        <EmptyState
          icon="sparkles"
          title="Which card should you use?"
          description="Once your wallet has cards, tell us what you are buying and we will pick the card with the best rewards."
          action={
            <LinkButton to="/wallet" variant="secondary">
              <Icon name="wallet" className="size-4" />
              Set up your wallet
            </LinkButton>
          }
        />
      </Card>
    </>
  )
}
