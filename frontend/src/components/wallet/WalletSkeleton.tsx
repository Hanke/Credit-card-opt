import { Card, Skeleton } from '../ui'
import { cn } from '../ui/cn'

interface WalletSkeletonProps {
  count?: number
  className?: string
}

export function WalletSkeleton({ count = 3, className }: WalletSkeletonProps) {
  return (
    <div className={cn('grid gap-4 sm:grid-cols-2 lg:grid-cols-3', className)}>
      {Array.from({ length: count }, (_, index) => (
        <Card key={index} className="p-5">
          <div className="flex items-start justify-between">
            <Skeleton className="size-10 rounded-xl" />
            <Skeleton className="h-5 w-24 rounded-full" />
          </div>
          <Skeleton className="mt-4 h-5 w-3/4" />
          <div className="mt-4 grid grid-cols-2 gap-4">
            <Skeleton className="h-9" />
            <Skeleton className="h-9" />
          </div>
          <Skeleton className="mt-5 h-8 w-24" />
        </Card>
      ))}
    </div>
  )
}
