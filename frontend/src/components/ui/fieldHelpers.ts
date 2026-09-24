import { cn } from './cn'

/** Id of the error message element so controls can reference it via aria-describedby. */
export function errorId(id: string): string {
  return `${id}-error`
}

/** Class names shared by form controls (input, select). */
export function controlClasses(error: string | undefined, className?: string): string {
  return cn(
    'h-10 w-full rounded-md border bg-white px-3 text-sm text-slate-900',
    'placeholder:text-slate-400',
    'focus:ring-2 focus:ring-slate-400 focus:outline-none',
    'disabled:cursor-not-allowed disabled:bg-slate-50',
    'dark:bg-slate-900 dark:text-slate-100 dark:placeholder:text-slate-500',
    'dark:focus:ring-slate-500 dark:disabled:bg-slate-800',
    error ? 'border-red-500' : 'border-slate-300 dark:border-slate-700',
    className,
  )
}
