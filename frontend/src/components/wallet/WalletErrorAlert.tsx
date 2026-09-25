import { Alert, Button } from '../ui'

interface WalletErrorAlertProps {
  onRetry: () => Promise<void>
}

export function WalletErrorAlert({ onRetry }: WalletErrorAlertProps) {
  return (
    <Alert
      message="Could not load your wallet."
      className="mb-6 items-center"
      action={
        <Button variant="secondary" size="sm" onClick={() => void onRetry()} className="-my-1.5">
          Retry
        </Button>
      }
    />
  )
}
