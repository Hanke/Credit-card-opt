import type { ReactNode } from 'react'
import { Link, useLocation } from 'react-router-dom'

interface AuthCardProps {
  title: string
  description: string
  footerText: string
  footerLinkLabel: string
  footerLinkTo: string
  children: ReactNode
}

export function AuthCard({ title, description, footerText, footerLinkLabel, footerLinkTo, children }: AuthCardProps) {
  const location = useLocation()

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-semibold tracking-tight text-slate-900">{title}</h1>
        <p className="mt-2 text-[15px] text-slate-500">{description}</p>
      </div>
      {children}
      <p className="mt-8 text-center text-sm text-slate-500">
        {footerText}{' '}
        <Link
          to={footerLinkTo}
          state={location.state}
          className="font-medium text-brand-600 hover:text-brand-700 hover:underline"
        >
          {footerLinkLabel}
        </Link>
      </p>
    </div>
  )
}
