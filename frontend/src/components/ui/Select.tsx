import { useId, type SelectHTMLAttributes } from 'react'
import { Field } from './Field'
import { controlClasses, errorId } from './fieldHelpers'

export interface SelectOption {
  value: string
  label: string
}

interface SelectProps extends Omit<SelectHTMLAttributes<HTMLSelectElement>, 'children'> {
  label?: string
  error?: string
  options: SelectOption[]
  placeholder?: string
}

export function Select({
  label,
  error,
  options,
  placeholder,
  id,
  className,
  value,
  defaultValue,
  ...props
}: SelectProps) {
  const generatedId = useId()
  const selectId = id ?? generatedId
  const startsOnPlaceholder = value === undefined && defaultValue === undefined && Boolean(placeholder)

  return (
    <Field id={selectId} label={label} error={error}>
      <select
        id={selectId}
        aria-invalid={error ? true : undefined}
        aria-describedby={error ? errorId(selectId) : undefined}
        className={controlClasses(error, className)}
        value={value}
        defaultValue={startsOnPlaceholder ? '' : defaultValue}
        {...props}
      >
        {placeholder && (
          <option value="" disabled>
            {placeholder}
          </option>
        )}
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    </Field>
  )
}
