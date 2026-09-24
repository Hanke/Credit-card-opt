import type { ReactNode } from 'react'
import { NavLink } from 'react-router-dom'
import { cn } from '../ui/cn'

const NAV_LINKS = [
  { to: '/dashboard', label: 'Dashboard' },
  { to: '/wallet', label: 'Wallet' },
  { to: '/recommend', label: 'Recommend' },
] as const

interface NavbarProps {
  /** Right-hand slot, intended for a logout button once auth exists. */
  actions?: ReactNode
}

export function Navbar({ actions }: NavbarProps) {
  return (
    <header className="sticky top-0 z-10 border-b border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900">
      <div className="mx-auto flex max-w-5xl flex-wrap items-center gap-x-6 gap-y-2 px-4 py-3 sm:px-6">
        <NavLink to="/dashboard" className="text-base font-semibold text-slate-900 dark:text-slate-100">
          Card Optimizer
        </NavLink>

        <nav aria-label="Primary" className="flex items-center gap-1 overflow-x-auto">
          {NAV_LINKS.map(({ to, label }) => (
            <NavLink
              key={to}
              to={to}
              className={({ isActive }) =>
                cn(
                  'rounded-md px-3 py-1.5 text-sm font-medium whitespace-nowrap transition-colors',
                  isActive
                    ? 'bg-slate-100 text-slate-900 dark:bg-slate-800 dark:text-slate-100'
                    : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900 dark:text-slate-400 dark:hover:bg-slate-800 dark:hover:text-slate-100',
                )
              }
            >
              {label}
            </NavLink>
          ))}
        </nav>

        <div className="ml-auto flex items-center gap-2">
          {actions ?? (
            <NavLink
              to="/login"
              className="text-sm font-medium text-slate-600 hover:text-slate-900 dark:text-slate-400 dark:hover:text-slate-100"
            >
              Log in
            </NavLink>
          )}
        </div>
      </div>
    </header>
  )
}
