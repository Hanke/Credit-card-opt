import { useCallback, useState } from 'react'

export interface Disclosure {
  open: boolean
  show: () => void
  hide: () => void
}

export function useDisclosure(initialOpen = false): Disclosure {
  const [open, setOpen] = useState(initialOpen)
  const show = useCallback(() => setOpen(true), [])
  const hide = useCallback(() => setOpen(false), [])
  return { open, show, hide }
}
