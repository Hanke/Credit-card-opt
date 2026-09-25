import { expect, test, type Page } from '@playwright/test'
import { signUp, storedToken, uniqueEmail } from './helpers'

const COBALT = 'Amex Cobalt'
const RECOMMENDATIONS = '**/api/v1/recommendations'

async function addCardViaApi(page: Page, name: string): Promise<void> {
  const headers = { Authorization: `Bearer ${await storedToken(page)}` }
  const search = await page.request.get(`/api/v1/cards?q=${encodeURIComponent(name)}`, { headers })
  const { cards } = (await search.json()) as { cards: Array<{ id: number }> }
  const added = await page.request.post('/api/v1/wallet', { headers, data: { credit_card_id: cards[0].id } })
  expect(added.ok()).toBe(true)
}

async function openRecommend(page: Page, path = '/recommend'): Promise<void> {
  await page.goto(path)
  await expect(page.getByRole('heading', { name: 'Recommend' })).toBeVisible()
}

async function openWithCard(page: Page, path = '/recommend'): Promise<void> {
  await signUp(page, uniqueEmail())
  await addCardViaApi(page, COBALT)
  await openRecommend(page, path)
}

function countRecommendationRequests(page: Page): () => number {
  let count = 0
  page.on('request', (request) => {
    if (request.method() === 'POST' && request.url().includes('/api/v1/recommendations')) count += 1
  })
  return () => count
}

function submitButton(page: Page) {
  return page.getByRole('button', { name: 'Find the best card' })
}

function fulfill422(errors: string[]) {
  return { status: 422, contentType: 'application/json', body: JSON.stringify({ errors }) }
}

test.describe('recommend', () => {
  test('an empty wallet shows a link to the wallet instead of the form', async ({ page }) => {
    await signUp(page, uniqueEmail())
    await openRecommend(page)

    await expect(page.getByText('Which card should you use?')).toBeVisible()
    await expect(page.getByLabel('Amount')).toHaveCount(0)

    await page.getByRole('link', { name: 'Set up your wallet' }).click()
    await expect(page).toHaveURL(/\/wallet$/)
  })

  test('submitting $150 on dining calls the API once, shows the result, and survives a reload', async ({ page }) => {
    await openWithCard(page)
    const requests = countRecommendationRequests(page)

    await expect(submitButton(page)).toBeDisabled()
    await page.getByLabel('Amount').fill('150')
    await expect(submitButton(page)).toBeDisabled()
    await page.getByLabel('Category').selectOption('dining')
    await expect(submitButton(page)).toBeEnabled()
    await submitButton(page).click()

    const results = page.getByRole('region', { name: 'Recommendation' })
    await expect(results.getByRole('heading', { name: 'Best card for $150 on Dining' })).toBeVisible()
    await expect(results.getByText(`Use ${COBALT}`)).toBeVisible()
    await expect(page).toHaveURL(/\/recommend\?amount=150&category=dining$/)
    expect(requests()).toBe(1)

    await page.reload()
    await expect(page.getByLabel('Amount')).toHaveValue('150.00')
    await expect(page.getByLabel('Category')).toHaveValue('dining')
    await expect(results.getByText(`Use ${COBALT}`)).toBeVisible()
  })

  test('a shared link with amount and category loads its recommendation', async ({ page }) => {
    await openWithCard(page, '/recommend?amount=42.5&category=groceries')

    await expect(page.getByLabel('Amount')).toHaveValue('42.50')
    await expect(page.getByLabel('Category')).toHaveValue('groceries')
    await expect(page.getByRole('heading', { name: 'Best card for $42.50 on Groceries' })).toBeVisible()
    await expect(page.getByText(`Use ${COBALT}`)).toBeVisible()
  })

  test('the amount is masked to currency with two decimals', async ({ page }) => {
    await openWithCard(page)
    const amount = page.getByLabel('Amount')

    await amount.pressSequentially('1500.555')
    await expect(amount).toHaveValue('1,500.55')
    await amount.fill('abc')
    await expect(amount).toHaveValue('')
    await amount.fill('7')
    await amount.blur()
    await expect(amount).toHaveValue('7.00')
  })

  test('invalid input shows inline errors and never hits the API', async ({ page }) => {
    await openWithCard(page)
    const requests = countRecommendationRequests(page)
    const amount = page.getByLabel('Amount')

    await page.getByLabel('Category').selectOption('dining')
    await amount.fill('0')
    await amount.blur()
    await expect(page.getByText('Enter an amount greater than $0.')).toBeVisible()
    await expect(submitButton(page)).toBeDisabled()

    await amount.fill('1000001')
    await expect(page.getByText('Enter an amount of $1,000,000.00 or less.')).toBeVisible()
    await expect(submitButton(page)).toBeDisabled()

    await amount.press('Enter')
    await expect(page.getByRole('region', { name: 'Recommendation' })).toHaveCount(0)
    expect(requests()).toBe(0)
  })

  test('API validation errors show inline next to the field', async ({ page }) => {
    await openWithCard(page)
    await page.route(RECOMMENDATIONS, (route) =>
      route.fulfill(fulfill422(['Amount must be less than or equal to 1000000', 'Category is not a supported purchase category'])),
    )

    await page.getByLabel('Amount').fill('150')
    await page.getByLabel('Category').selectOption('dining')
    await submitButton(page).click()

    await expect(page.getByText('Amount must be less than or equal to 1000000')).toBeVisible()
    await expect(page.getByText('Category is not a supported purchase category')).toBeVisible()
    await expect(page.getByLabel('Amount')).toHaveAttribute('aria-invalid', 'true')
    await expect(page.getByRole('region', { name: 'Recommendation' })).toHaveCount(0)
  })

  test('API errors that belong to no field show as a form alert', async ({ page }) => {
    await openWithCard(page)
    await page.route(RECOMMENDATIONS, (route) => route.fulfill(fulfill422(['Add a card to your wallet first'])))

    await page.getByLabel('Amount').fill('150')
    await page.getByLabel('Category').selectOption('dining')
    await submitButton(page).click()

    await expect(page.getByRole('alert')).toContainText('Add a card to your wallet first')
    await expect(submitButton(page)).toBeEnabled()
  })
})
