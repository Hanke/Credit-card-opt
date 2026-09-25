import { isApiError } from '../api'

export type FieldErrors<Field extends string> = { [key in Field | 'form']?: string }

const GENERIC_ERROR = 'Something went wrong. Please try again.'

function startsWithWord(message: string, word: string): boolean {
  if (!message.toLowerCase().startsWith(word.toLowerCase())) return false
  return !/\w/.test(message.charAt(word.length))
}

export function toFieldErrors<Field extends string>(error: unknown, fields: readonly Field[]): FieldErrors<Field> {
  const result: FieldErrors<Field> = {}

  if (!isApiError(error) || error.errors.length === 0) {
    result.form = GENERIC_ERROR
    return result
  }

  for (const message of error.errors) {
    const field = fields.find((name) => startsWithWord(message, name)) ?? 'form'
    result[field] = result[field] ? `${result[field]} ${message}` : message
  }

  return result
}
