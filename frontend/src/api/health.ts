import { apiGet } from './client'
import type { HealthResponse } from './types'

export function getHealth(): Promise<HealthResponse> {
  return apiGet<HealthResponse>('/api/v1/health')
}
