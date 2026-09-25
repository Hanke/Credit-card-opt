import { useCallback, useRef, useState } from 'react'
import { recommend as requestRecommendation } from '../api'
import type { RecommendationRequest, RecommendationResponse } from '../api'
import { toError } from '../lib/errors'

export interface UseRecommendationResult {
  data: RecommendationResponse | null
  loading: boolean
  error: Error | null
  lastInput: RecommendationRequest | null
  recommend: (input: RecommendationRequest) => Promise<void>
}

interface InFlightRequest {
  key: string
  promise: Promise<void>
}

function requestKey(input: RecommendationRequest): string {
  return JSON.stringify([input.amount, input.category, input.credit_card_ids ?? null])
}

export function useRecommendation(): UseRecommendationResult {
  const [data, setData] = useState<RecommendationResponse | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<Error | null>(null)
  const [lastInput, setLastInput] = useState<RecommendationRequest | null>(null)
  const inFlight = useRef<InFlightRequest | null>(null)

  const recommend = useCallback((input: RecommendationRequest) => {
    const key = requestKey(input)
    if (inFlight.current?.key === key) return inFlight.current.promise

    setLastInput(input)
    setLoading(true)
    setError(null)

    const request: InFlightRequest = {
      key,
      promise: requestRecommendation(input)
        .then(
          (response) => {
            if (inFlight.current !== request) return
            setData(response)
          },
          (caught: unknown) => {
            if (inFlight.current !== request) return
            setData(null)
            setError(toError(caught))
          },
        )
        .finally(() => {
          if (inFlight.current !== request) return
          inFlight.current = null
          setLoading(false)
        }),
    }
    inFlight.current = request
    return request.promise
  }, [])

  return { data, loading, error, lastInput, recommend }
}
