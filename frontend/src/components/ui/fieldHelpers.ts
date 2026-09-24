import { cn } from './cn'

export function errorId(id: string): string {
  return `${id}-error`
}

export function controlClasses(error: string | undefined, className?: string): string {
  return cn(
    'h-11 w-full rounded-lg border bg-white px-3.5 text-[15px] text-slate-900 shadow-xs transition-shadow',
    'placeholder:text-slate-400',
    'focus:ring-4 focus:outline-none',
    'disabled:cursor-not-allowed disabled:bg-slate-50 disabled:text-slate-500',
    error
      ? 'border-red-400 focus:border-red-500 focus:ring-red-500/15'
      : 'border-slate-200 hover:border-slate-300 focus:border-brand-500 focus:ring-brand-500/15',
    className,
  )
}
