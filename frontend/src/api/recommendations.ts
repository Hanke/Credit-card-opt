import { apiPost } from './client'
import type { RecommendationRequest, RecommendationResponse } from './types'

export function recommend(request: RecommendationRequest): Promise<RecommendationResponse> {
  return apiPost<RecommendationResponse>('/api/v1/recommendations', request)
}
