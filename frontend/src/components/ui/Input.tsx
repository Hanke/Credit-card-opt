import { useId, type InputHTMLAttributes } from 'react'
import { Field } from './Field'
import { cn } from './cn'
import { controlClasses, errorId } from './fieldHelpers'

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string
  error?: string
  prefix?: string
}

export function Input({ label, error, prefix, id, className, ...props }: InputProps) {
  const generatedId = useId()
  const inputId = id ?? generatedId

  const control = (
    <input
      id={inputId}
      aria-invalid={error ? true : undefined}
      aria-describedby={error ? errorId(inputId) : undefined}
      className={controlClasses(error, cn(prefix && 'pl-8', className))}
      {...props}
    />
  )

  return (
    <Field id={inputId} label={label} error={error}>
      {prefix ? (
        <div className="relative">
          <span aria-hidden="true" className="pointer-events-none absolute inset-y-0 left-3.5 flex items-center text-slate-500">
            {prefix}
          </span>
          {control}
        </div>
      ) : (
        control
      )}
    </Field>
  )
}
