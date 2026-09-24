import { Outlet } from 'react-router-dom'
import { Navbar } from './Navbar'

/**
 * Page frame shared by every authenticated route: sticky navbar on top,
 * then a max-width, padded container that the current page renders into.
 */
export function AppShell() {
  return (
    <div className="flex min-h-svh flex-col">
      <Navbar />
      <main className="mx-auto w-full max-w-5xl flex-1 px-4 py-6 sm:px-6 sm:py-8">
        <Outlet />
      </main>
    </div>
  )
}
