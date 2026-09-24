import { Link, Outlet } from 'react-router-dom'

/**
 * Minimal frame for unauthenticated pages (login, signup): brand mark on top,
 * a narrow centered column, and no app navigation.
 */
export function AuthLayout() {
  return (
    <div className="flex min-h-svh flex-col">
      <header className="px-4 py-4 sm:px-6">
        <Link to="/" className="text-base font-semibold text-slate-900 dark:text-slate-100">
          Card Optimizer
        </Link>
      </header>
      <main className="mx-auto w-full max-w-md flex-1 px-4 py-6 sm:px-6 sm:py-10">
        <Outlet />
      </main>
    </div>
  )
}
