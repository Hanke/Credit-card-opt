import { Icon, LinkButton } from '../components/ui'

export function NotFoundPage() {
  return (
    <div className="text-center">
      <p className="text-sm font-semibold text-brand-600">404</p>
      <h1 className="mt-2 text-3xl font-semibold tracking-tight text-slate-900">Page not found</h1>
      <p className="mt-3 text-[15px] text-slate-500">
        We could not find that page. It may have moved, or the link may be wrong.
      </p>
      <LinkButton to="/dashboard" size="lg" className="mt-8">
        Back to dashboard
        <Icon name="arrow-right" className="size-4" />
      </LinkButton>
    </div>
  )
}
