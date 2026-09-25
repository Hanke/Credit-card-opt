import { expect, type Page } from '@playwright/test'

export const PASSWORD = 'correct-horse-battery'

export function uniqueEmail(): string {
  return `e2e-${Date.now()}-${Math.random().toString(36).slice(2, 8)}@example.com`
}

export async function fillCredentials(page: Page, email: string, password: string): Promise<void> {
  await page.getByLabel('Email').fill(email)
  await page.getByLabel('Password').fill(password)
}

export async function signUp(page: Page, email: string, password = PASSWORD): Promise<void> {
  await page.goto('/signup')
  await fillCredentials(page, email, password)
  await page.getByRole('button', { name: 'Create account' }).click()
  await expect(page).toHaveURL(/\/dashboard$/)
}

export async function logIn(page: Page, email: string, password = PASSWORD): Promise<void> {
  await fillCredentials(page, email, password)
  await page.getByRole('button', { name: 'Log in' }).click()
}

export async function logOut(page: Page): Promise<void> {
  await page.getByRole('button', { name: 'Log out' }).click()
  await expect(page).toHaveURL(/\/login$/)
}

export function storedToken(page: Page): Promise<string | null> {
  return page.evaluate(() => localStorage.getItem('auth_token'))
}

export function setStoredToken(page: Page, value: string): Promise<void> {
  return page.evaluate((token) => localStorage.setItem('auth_token', token), value)
}

export async function addCardViaApi(page: Page, name: string): Promise<void> {
  const headers = { Authorization: `Bearer ${await storedToken(page)}` }
  const search = await page.request.get(`/api/v1/cards?q=${encodeURIComponent(name)}`, { headers })
  const { cards } = (await search.json()) as { cards: Array<{ id: number; name: string }> }
  const card = cards.find((candidate) => candidate.name === name)
  if (!card) throw new Error(`Seeded card "${name}" not found`)
  const added = await page.request.post('/api/v1/wallet', { headers, data: { credit_card_id: card.id } })
  expect(added.ok()).toBe(true)
}

export function collectConsoleErrors(page: Page): () => string[] {
  const errors: string[] = []
  page.on('console', (message) => {
    if (message.type() === 'error') errors.push(message.text())
  })
  page.on('pageerror', (error) => errors.push(error.message))
  return () => errors
}
