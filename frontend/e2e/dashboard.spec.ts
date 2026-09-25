import { expect, test, type Page } from '@playwright/test'
import { addCardViaApi, collectConsoleErrors, logOut, signUp, uniqueEmail } from './helpers'

const COBALT = 'Amex Cobalt'
const FOUR_CARDS = [COBALT, 'TD Aeroplan Visa Infinite', 'RBC Avion Visa Infinite', 'Amex Gold Rewards Card']

function walletTiles(page: Page) {
  return page.getByRole('list', { name: 'Your cards' }).getByRole('article')
}

test.describe('dashboard', () => {
  test('a new user goes from empty dashboard to a recommendation without leaving the flow', async ({ page }) => {
    const consoleErrors = collectConsoleErrors(page)
    await signUp(page, uniqueEmail())

    await expect(page).toHaveTitle('Dashboard · Card Optimizer')
    await expect(page.getByRole('region', { name: 'Get started' })).toBeVisible()
    await expect(page.getByText('How it works')).toBeVisible()
    await expect(page.getByLabel('Amount')).toHaveCount(0)

    await page.getByRole('button', { name: 'Add your first card' }).click()
    await expect(page.getByRole('dialog', { name: 'Add cards' })).toBeVisible()
    await page.getByLabel('Search cards').fill(COBALT)
    await page.getByRole('button', { name: `Add ${COBALT}` }).click()
    await expect(page.getByRole('button', { name: `${COBALT} already in wallet` })).toBeDisabled()
    await page.keyboard.press('Escape')
    await expect(page.getByLabel('Search cards')).toHaveValue('')
    await page.keyboard.press('Escape')
    await expect(page.getByRole('dialog')).toHaveCount(0)
    await expect(page.getByRole('button', { name: 'Add cards' })).toBeFocused()

    await expect(page.getByRole('region', { name: 'Get started' })).toHaveCount(0)
    await expect(page.getByRole('heading', { name: 'Your wallet · 1 card' })).toBeVisible()
    await expect(walletTiles(page)).toHaveCount(1)
    await expect(walletTiles(page).first()).toContainText(COBALT)
    await expect(page.getByText('1 card in your wallet. Check a purchase to see which one to use.')).toBeVisible()

    await page.getByLabel('Amount').fill('150')
    await page.getByLabel('Category').selectOption('dining')
    await page.getByRole('button', { name: 'Find the best card' }).click()

    await expect(page).toHaveURL(/\/recommend\?amount=150&category=dining$/)
    await expect(page).toHaveTitle('Recommend · Card Optimizer')
    await expect(page.getByLabel('Amount')).toHaveValue('150.00')
    await expect(page.getByRole('article', { name: `Best card: ${COBALT}` })).toContainText('$7.50')

    expect(consoleErrors()).toEqual([])
  })

  test('shows the first three cards and links to the rest', async ({ page }) => {
    await signUp(page, uniqueEmail())
    for (const name of FOUR_CARDS) await addCardViaApi(page, name)
    await page.reload()

    await expect(page.getByRole('heading', { name: 'Your wallet · 4 cards' })).toBeVisible()
    await expect(walletTiles(page)).toHaveCount(3)
    await expect(walletTiles(page).nth(0)).toContainText(FOUR_CARDS[0])
    await expect(walletTiles(page).nth(2)).toContainText(FOUR_CARDS[2])

    await page.getByRole('link', { name: 'View all 4 cards' }).click()
    await expect(page).toHaveURL(/\/wallet$/)
    await expect(walletTiles(page)).toHaveCount(4)
  })

  test('a failed wallet load shows a banner whose retry recovers', async ({ page }) => {
    await signUp(page, uniqueEmail())
    await addCardViaApi(page, COBALT)

    let fail = true
    await page.route('**/api/v1/wallet', (route) =>
      fail && route.request().method() === 'GET'
        ? route.fulfill({ status: 500, contentType: 'application/json', body: '{}' })
        : route.continue(),
    )
    await page.reload()
    await expect(page.getByRole('alert')).toContainText('Could not load your wallet')
    await expect(page.getByLabel('Amount')).toHaveCount(0)
    await expect(page.getByRole('region', { name: 'Get started' })).toHaveCount(0)

    fail = false
    await page.getByRole('button', { name: 'Retry' }).click()
    await expect(page.getByRole('alert')).toHaveCount(0)
    await expect(walletTiles(page)).toHaveCount(1)
    await expect(page.getByLabel('Amount')).toBeVisible()
  })

  test('the quick check form can be completed with the keyboard alone', async ({ page }) => {
    await signUp(page, uniqueEmail())
    await addCardViaApi(page, COBALT)
    await page.reload()

    await page.getByLabel('Amount').focus()
    await page.keyboard.type('42.5')
    await page.keyboard.press('Tab')
    await expect(page.getByLabel('Category')).toBeFocused()
    await page.getByLabel('Category').selectOption('groceries')
    await page.keyboard.press('Tab')
    await expect(page.getByRole('button', { name: 'Find the best card' })).toBeFocused()
    await page.keyboard.press('Enter')

    await expect(page).toHaveURL(/\/recommend\?amount=42.5&category=groceries$/)
    await expect(page.getByRole('heading', { name: 'Best card for $42.50 on Groceries' })).toBeVisible()
  })
})

test.describe('page titles', () => {
  test('every route sets its own document title', async ({ page }) => {
    await page.goto('/login')
    await expect(page).toHaveTitle('Log in · Card Optimizer')
    await page.goto('/signup')
    await expect(page).toHaveTitle('Sign up · Card Optimizer')
    await page.goto('/some-typo')
    await expect(page).toHaveTitle('Page not found · Card Optimizer')

    await signUp(page, uniqueEmail())
    await expect(page).toHaveTitle('Dashboard · Card Optimizer')
    const nav = page.getByRole('navigation', { name: 'Primary' })
    await nav.getByRole('link', { name: 'Wallet' }).click()
    await expect(page).toHaveTitle('Wallet · Card Optimizer')
    await nav.getByRole('link', { name: 'Recommend' }).click()
    await expect(page).toHaveTitle('Recommend · Card Optimizer')
    await logOut(page)
    await expect(page).toHaveTitle('Log in · Card Optimizer')
  })
})
