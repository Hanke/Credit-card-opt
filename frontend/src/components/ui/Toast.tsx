import { Icon } from './Icon'
import { cn } from './cn'

type Tone = 'danger' | 'success'

interface ToastProps {
  message: string
  tone?: Tone
  onDismiss: () => void
}

const TONE_CLASSES: Record<Tone, string> = {
  danger: 'border-red-200 bg-red-50 text-red-800',
  success: 'border-emerald-200 bg-emerald-50 text-emerald-800',
}

export function Toast({ message, tone = 'danger', onDismiss }: ToastProps) {
  return (
    <div className="pointer-events-none fixed inset-x-4 bottom-4 z-40 flex justify-center sm:inset-x-6 sm:bottom-6">
      <div
        role="alert"
        className={cn(
          'pointer-events-auto flex w-full max-w-md items-start gap-3 rounded-xl border px-4 py-3 text-sm shadow-float',
          TONE_CLASSES[tone],
        )}
      >
        <Icon name={tone === 'danger' ? 'alert' : 'check'} className="mt-0.5 size-4 shrink-0" />
        <span className="flex-1">{message}</span>
        <button
          type="button"
          onClick={onDismiss}
          aria-label="Dismiss"
          className="-m-1 rounded-md p-1 opacity-70 transition-opacity hover:opacity-100 focus-visible:ring-2 focus-visible:ring-current focus-visible:outline-none"
        >
          <Icon name="x" className="size-4" />
        </button>
      </div>
    </div>
  )
}
