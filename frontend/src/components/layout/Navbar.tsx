import { NavLink, useNavigate } from 'react-router-dom'
import { useAuth } from '../../hooks/useAuth'
import { Button, Icon, Logo, type IconName } from '../ui'
import { cn } from '../ui/cn'

const NAV_LINKS: ReadonlyArray<{ to: string; label: string; icon: IconName }> = [
  { to: '/dashboard', label: 'Dashboard', icon: 'dashboard' },
  { to: '/wallet', label: 'Wallet', icon: 'wallet' },
  { to: '/recommend', label: 'Recommend', icon: 'sparkles' },
]

export function Navbar() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  function handleLogout() {
    logout()
    navigate('/login', { replace: true })
  }

  return (
    <header className="sticky top-0 z-20 border-b border-slate-200/80 bg-white/85 backdrop-blur supports-[backdrop-filter]:bg-white/70">
      <div className="mx-auto flex h-16 max-w-6xl items-center gap-3 px-4 sm:gap-8 sm:px-6">
        <NavLink to="/dashboard" className="shrink-0 rounded-md focus-visible:ring-2 focus-visible:ring-brand-500 focus-visible:outline-none">
          <Logo />
        </NavLink>

        <nav aria-label="Primary" className="flex items-center gap-0.5 sm:gap-1">
          {NAV_LINKS.map(({ to, label, icon }) => (
            <NavLink
              key={to}
              to={to}
              aria-label={label}
              title={label}
              className={({ isActive }) =>
                cn(
                  'inline-flex items-center gap-2 rounded-lg px-2.5 py-2 text-sm font-medium whitespace-nowrap transition-colors sm:px-3',
                  'focus-visible:ring-2 focus-visible:ring-brand-500 focus-visible:outline-none',
                  isActive
                    ? 'bg-brand-50 text-brand-700'
                    : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900',
                )
              }
            >
              <Icon name={icon} className="size-4.5 sm:size-4" />
              <span className="hidden sm:inline">{label}</span>
            </NavLink>
          ))}
        </nav>

        <div className="ml-auto flex shrink-0 items-center gap-2 sm:gap-3">
          <span className="hidden items-center gap-2.5 sm:flex">
            <span
              aria-hidden="true"
              className="flex size-8 items-center justify-center rounded-full bg-gradient-to-br from-brand-500 to-violet-500 text-xs font-semibold text-white uppercase"
            >
              {user?.email.charAt(0)}
            </span>
            <span className="max-w-48 truncate text-sm text-slate-600" title={user?.email}>
              {user?.email}
            </span>
          </span>
          <Button variant="ghost" size="sm" onClick={handleLogout} aria-label="Log out" title="Log out">
            <Icon name="log-out" className="size-4" />
            <span className="hidden sm:inline">Log out</span>
          </Button>
        </div>
      </div>
    </header>
  )
}
