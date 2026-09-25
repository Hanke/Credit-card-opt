import type { ComponentProps } from 'react'
import { buttonClasses, type ButtonSize, type ButtonVariant } from './buttonStyles'
import { Spinner } from './Spinner'

interface ButtonProps extends ComponentProps<'button'> {
  variant?: ButtonVariant
  size?: ButtonSize
  loading?: boolean
}

export function Button({
  variant = 'primary',
  size = 'md',
  type = 'button',
  loading = false,
  disabled,
  className,
  children,
  ...props
}: ButtonProps) {
  return (
    <button
      type={type}
      disabled={disabled || loading}
      aria-busy={loading || undefined}
      className={buttonClasses(variant, size, className)}
      {...props}
    >
      {loading && (
        <Spinner size="sm" tone={variant === 'primary' || variant === 'danger' ? 'inverse' : 'default'} />
      )}
      {children}
    </button>
  )
}
