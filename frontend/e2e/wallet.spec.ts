import { expect, test, type Page } from '@playwright/test'
import { signUp, uniqueEmail } from './helpers'

const COBALT = 'Amex Cobalt'

async function openWallet(page: Page): Promise<void> {
  await signUp(page, uniqueEmail())
  await page.goto('/wallet')
  await expect(page.getByRole('heading', { name: 'Wallet' })).toBeVisible()
}

async function openSearch(page: Page): Promise<void> {
  await page.getByRole('button', { name: 'Add your first card' }).click()
  await expect(page.getByRole('dialog', { name: 'Add cards' })).toBeVisible()
}

async function addCard(page: Page, name: string): Promise<void> {
  await page.getByLabel('Search cards').fill(name)
  await page.getByRole('button', { name: `Add ${name}` }).click()
  await expect(page.getByRole('button', { name: `${name} already in wallet` })).toBeDisabled()
}

async function closeSearch(page: Page): Promise<void> {
  await page.getByRole('button', { name: 'Close' }).click()
  await expect(page.getByRole('dialog')).toHaveCount(0)
}

function walletTile(page: Page, name: string) {
  return page.getByRole('list', { name: 'Your cards' }).getByRole('article', { name })
}

test.describe('wallet', () => {
  test('starts empty and adding a card shows it immediately and after a reload', async ({ page }) => {
    await openWallet(page)
    await expect(page.getByText('No cards yet')).toBeVisible()

    await openSearch(page)
    await addCard(page, COBALT)
    await closeSearch(page)

    await expect(walletTile(page, COBALT)).toBeVisible()
    await expect(walletTile(page, COBALT).getByText('American Express')).toBeVisible()
    await expect(walletTile(page, COBALT).getByText('$191.88/yr')).toBeVisible()
    await expect(page.getByText('1 card in your wallet')).toBeVisible()

    await page.reload()
    await expect(walletTile(page, COBALT)).toBeVisible()
    await expect(page.getByText('1 card in your wallet')).toBeVisible()
  })

  test('removing a card asks for confirmation and then removes it', async ({ page }) => {
    await openWallet(page)
    await openSearch(page)
    await addCard(page, COBALT)
    await closeSearch(page)

    await page.getByRole('button', { name: `Remove ${COBALT}` }).click()
    await expect(page.getByText('Remove this card?')).toBeVisible()
    await page.getByRole('button', { name: 'Cancel' }).click()
    await expect(walletTile(page, COBALT)).toBeVisible()

    await page.getByRole('button', { name: `Remove ${COBALT}` }).click()
    await page.getByRole('button', { name: `Confirm remove ${COBALT}` }).click()
    await expect(walletTile(page, COBALT)).toHaveCount(0)
    await expect(page.getByText('No cards yet')).toBeVisible()

    await page.reload()
    await expect(page.getByText('No cards yet')).toBeVisible()
  })

  test('a failed removal rolls the card back and shows an error', async ({ page }) => {
    await openWallet(page)
    await openSearch(page)
    await addCard(page, COBALT)
    await closeSearch(page)

    await page.route('**/api/v1/wallet/*', (route) =>
      route.request().method() === 'DELETE'
        ? route.fulfill({ status: 500, contentType: 'application/json', body: '{}' })
        : route.continue(),
    )
    await page.getByRole('button', { name: `Remove ${COBALT}` }).click()
    await page.getByRole('button', { name: `Confirm remove ${COBALT}` }).click()

    await expect(page.getByRole('alert')).toContainText(`Could not remove ${COBALT}`)
    await expect(walletTile(page, COBALT)).toBeVisible()
  })

  test('a failed add is rolled back and reported inside the modal', async ({ page }) => {
    await openWallet(page)
    await page.route('**/api/v1/wallet', (route) =>
      route.request().method() === 'POST'
        ? route.fulfill({ status: 500, contentType: 'application/json', body: '{}' })
        : route.continue(),
    )

    await openSearch(page)
    await page.getByLabel('Search cards').fill(COBALT)
    await page.getByRole('button', { name: `Add ${COBALT}` }).click()

    await expect(page.getByRole('dialog').getByRole('alert')).toContainText(`Could not add ${COBALT}`)
    await expect(page.getByRole('button', { name: `Add ${COBALT}` })).toBeEnabled()
    await closeSearch(page)
    await expect(page.getByText('No cards yet')).toBeVisible()
  })

  test('search with no matches shows a clear message', async ({ page }) => {
    await openWallet(page)
    await openSearch(page)
    await page.getByLabel('Search cards').fill('zzzz-no-such-card')
    await expect(page.getByText('No cards found')).toBeVisible()
  })

  test('search waits for typing to settle before requesting', async ({ page }) => {
    await openWallet(page)
    await openSearch(page)
    await expect(page.getByRole('button', { name: `Add ${COBALT}` })).toBeVisible()

    const requests: string[] = []
    page.on('request', (request) => {
      if (request.url().includes('/api/v1/cards?')) requests.push(request.url())
    })
    await page.getByLabel('Search cards').pressSequentially('cobalt', { delay: 50 })
    await expect.poll(() => requests.at(-1)).toContain('q=cobalt')
    await expect(page.getByRole('button', { name: `Add ${COBALT}` })).toBeVisible()

    expect(requests.length).toBeLessThan('cobalt'.length)
  })

  test('a failed search shows a retry that recovers', async ({ page }) => {
    await openWallet(page)
    let fail = true
    await page.route('**/api/v1/cards**', (route) =>
      fail ? route.fulfill({ status: 500, contentType: 'application/json', body: '{}' }) : route.continue(),
    )
    await openSearch(page)
    await expect(page.getByRole('dialog').getByRole('alert')).toContainText('Could not load cards')

    fail = false
    await page.getByRole('button', { name: 'Retry' }).click()
    await expect(page.getByRole('button', { name: `Add ${COBALT}` })).toBeVisible()
  })

  test('Escape clears the query first, then closes and returns focus, and backdrop click closes', async ({ page }) => {
    await openWallet(page)
    await openSearch(page)
    await page.getByLabel('Search cards').fill('cobalt')
    await page.keyboard.press('Escape')
    await expect(page.getByLabel('Search cards')).toHaveValue('')
    await expect(page.getByRole('dialog')).toBeVisible()
    await page.keyboard.press('Escape')
    await expect(page.getByRole('dialog')).toHaveCount(0)
    await expect(page.getByRole('button', { name: 'Add your first card' })).toBeFocused()

    await page.getByRole('button', { name: 'Add cards' }).click()
    await expect(page.getByRole('dialog', { name: 'Add cards' })).toBeVisible()
    await page.mouse.click(5, 5)
    await expect(page.getByRole('dialog')).toHaveCount(0)
  })

  test('closing the dialog after adding the first card moves focus to the header button', async ({ page }) => {
    await openWallet(page)
    await openSearch(page)
    await addCard(page, COBALT)
    await page.keyboard.press('Escape')
    await expect(page.getByLabel('Search cards')).toHaveValue('')
    await page.keyboard.press('Escape')
    await expect(page.getByRole('dialog')).toHaveCount(0)
    await expect(page.getByRole('button', { name: 'Add cards' })).toBeFocused()
  })
})

test.describe('wallet on a phone', () => {
  test.use({ viewport: { width: 375, height: 700 } })

  test('add and remove work at mobile width without horizontal scroll', async ({ page }) => {
    await openWallet(page)
    await openSearch(page)
    await addCard(page, COBALT)
    await closeSearch(page)
    await expect(walletTile(page, COBALT)).toBeVisible()

    const overflows = await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth)
    expect(overflows).toBe(false)

    await page.getByRole('button', { name: `Remove ${COBALT}` }).click()
    await page.getByRole('button', { name: `Confirm remove ${COBALT}` }).click()
    await expect(walletTile(page, COBALT)).toHaveCount(0)
  })
})
