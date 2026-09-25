import { createSearchParams, useNavigate } from 'react-router-dom'
import { PurchaseForm } from '../../components/purchase/PurchaseForm'
import { writePurchase, type PurchaseInput } from '../../components/purchase/purchaseSearchParams'
import { Card } from '../../components/ui'

export function QuickCheck() {
  const navigate = useNavigate()

  function handleSubmit(input: PurchaseInput) {
    navigate({ pathname: '/recommend', search: createSearchParams(writePurchase(input)).toString() })
  }

  return (
    <Card
      as="section"
      aria-label="Check a purchase"
      title="Check a purchase"
      description="Enter the amount and category and we will name the card in your wallet that earns the most."
    >
      <PurchaseForm onSubmit={handleSubmit} />
    </Card>
  )
}
