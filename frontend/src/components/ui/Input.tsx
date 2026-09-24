import { useId, type InputHTMLAttributes } from 'react'
import { Field } from './Field'
import { controlClasses, errorId } from './fieldHelpers'

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string
  error?: string
}

export function Input({ label, error, id, className, ...props }: InputProps) {
  const generatedId = useId()
  const inputId = id ?? generatedId

  return (
    <Field id={inputId} label={label} error={error}>
      <input
        id={inputId}
        aria-invalid={error ? true : undefined}
        aria-describedby={error ? errorId(inputId) : undefined}
        className={controlClasses(error, className)}
        {...props}
      />
    </Field>
  )
}
