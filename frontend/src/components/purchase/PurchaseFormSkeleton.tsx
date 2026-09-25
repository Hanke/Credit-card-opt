import { Card, Skeleton } from '../ui'

export function PurchaseFormSkeleton() {
  return (
    <Card>
      <Skeleton className="h-6 w-48" />
      <Skeleton className="mt-2 h-4 w-64" />
      <div className="mt-6 grid gap-4 sm:grid-cols-[1fr_1fr_auto]">
        <Skeleton className="h-11" />
        <Skeleton className="h-11" />
        <Skeleton className="h-11 w-44" />
      </div>
    </Card>
  )
}
