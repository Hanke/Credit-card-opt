export function focusIfLost(element: HTMLElement | null): void {
  if (document.activeElement === document.body) element?.focus()
}
