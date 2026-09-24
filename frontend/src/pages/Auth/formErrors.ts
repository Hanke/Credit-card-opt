import { ApiError } from '../../api/client'

export interface FormErrors {
  email?: string
  password?: string
  form?: string
}

const GENERIC_ERROR = 'Something went wrong. Please try again.'

function append(existing: string | undefined, message: string): string {
  return existing ? `${existing} ${message}` : message
}

export function toFormErrors(error: unknown): FormErrors {
  if (!(error instanceof ApiError) || error.errors.length === 0) {
    return { form: GENERIC_ERROR }
  }

  const result: FormErrors = {}

  for (const message of error.errors) {
    if (/^email\b/i.test(message)) {
      result.email = append(result.email, message)
    } else if (/^password\b/i.test(message)) {
      result.password = append(result.password, message)
    } else {
      result.form = append(result.form, message)
    }
  }

  return result
}
