import { useCallback, useEffect, useState } from 'react'

export interface ToastMessage {
  message: string
  tone: 'danger' | 'success'
}

const AUTO_DISMISS_MS = 6000

export function useToast() {
  const [toast, setToast] = useState<ToastMessage | null>(null)

  useEffect(() => {
    if (!toast) return
    const timer = setTimeout(() => setToast(null), AUTO_DISMISS_MS)
    return () => clearTimeout(timer)
  }, [toast])

  const dismiss = useCallback(() => setToast(null), [])
  const showError = useCallback((message: string) => setToast({ message, tone: 'danger' }), [])
  const showSuccess = useCallback((message: string) => setToast({ message, tone: 'success' }), [])

  return { toast, dismiss, showError, showSuccess }
}
