import { useState, type ChangeEvent, type FormEvent } from 'react'
import type { PurchaseCategory } from '../../api'
import { Alert, Button, Icon, Input, Select } from '../../components/ui'
import { formatAmount, maskAmount, validateAmount } from '../../lib/amountInput'
import { PURCHASE_CATEGORY_OPTIONS } from '../../lib/purchaseCategories'
import type { PurchaseErrors } from './purchaseErrors'
import type { PurchaseInput } from './purchaseSearchParams'

interface PurchaseFormProps {
  initial: PurchaseInput | null
  submitting: boolean
  errors: PurchaseErrors
  onSubmit: (input: PurchaseInput) => void
}

export function PurchaseForm({ initial, submitting, errors, onSubmit }: PurchaseFormProps) {
  const [amount, setAmount] = useState(initial ? formatAmount(initial.amount) : '')
  const [amountTouched, setAmountTouched] = useState(false)
  const [category, setCategory] = useState<PurchaseCategory | ''>(initial?.category ?? '')
  const amountValidation = validateAmount(amount)
  const valid = amountValidation.amount !== null && category !== ''
  const amountError = errors.amount ?? (amountTouched ? amountValidation.error : null) ?? undefined

  function handleAmountChange(event: ChangeEvent<HTMLInputElement>) {
    setAmount(maskAmount(event.target.value))
  }

  function handleAmountBlur() {
    setAmountTouched(true)
    if (amountValidation.amount !== null) setAmount(formatAmount(amountValidation.amount))
  }

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (amountValidation.amount === null || category === '') return
    onSubmit({ amount: amountValidation.amount, category })
  }

  return (
    <form className="flex flex-col gap-5" onSubmit={handleSubmit} noValidate>
      {errors.form && <Alert message={errors.form} />}
      <div className="grid gap-4 sm:grid-cols-[1fr_1fr_auto] sm:items-start">
        <Input
          label="Amount"
          name="amount"
          inputMode="decimal"
          autoComplete="off"
          placeholder="0.00"
          prefix="$"
          value={amount}
          onChange={handleAmountChange}
          onBlur={handleAmountBlur}
          error={amountError}
          required
        />
        <Select
          label="Category"
          name="category"
          placeholder="Choose a category"
          options={PURCHASE_CATEGORY_OPTIONS}
          value={category}
          onChange={(event) => setCategory(event.target.value as PurchaseCategory)}
          error={errors.category}
          required
        />
        <Button type="submit" size="lg" disabled={!valid} loading={submitting} className="sm:mt-[26px]">
          {!submitting && <Icon name="sparkles" className="size-4" />}
          {submitting ? 'Finding your card' : 'Find the best card'}
        </Button>
      </div>
    </form>
  )
}
