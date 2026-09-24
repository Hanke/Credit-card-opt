import { expect, test } from '@playwright/test'
import { PASSWORD, fillCredentials, logIn, logOut, setStoredToken, signUp, storedToken, uniqueEmail } from './helpers'

test.describe('sign up and session', () => {
  test('signing up lands on the dashboard and survives a reload', async ({ page }) => {
    const email = uniqueEmail()
    await signUp(page, email)
    expect(await storedToken(page)).toBeTruthy()

    await page.reload()
    await expect(page).toHaveURL(/\/dashboard$/)
    await expect(page.getByRole('banner').getByText(email)).toBeVisible()
  })

  test('logging out clears the token and returns to login', async ({ page }) => {
    await signUp(page, uniqueEmail())
    await logOut(page)
    expect(await storedToken(page)).toBeNull()
  })

  test('a logged-in user visiting an auth page is sent to the dashboard', async ({ page }) => {
    await signUp(page, uniqueEmail())
    await page.goto('/login')
    await expect(page).toHaveURL(/\/dashboard$/)
    await page.goto('/signup')
    await expect(page).toHaveURL(/\/dashboard$/)
  })
})

test.describe('protected routes', () => {
  test('a logged-out visit to /wallet redirects to login and returns after logging in', async ({ page }) => {
    const email = uniqueEmail()
    await signUp(page, email)
    await logOut(page)

    await page.goto('/wallet')
    await expect(page).toHaveURL(/\/login$/)
    await logIn(page, email)
    await expect(page).toHaveURL(/\/wallet$/)
  })

  test('an invalid stored token is cleared and login returns to the intended page', async ({ page }) => {
    const email = uniqueEmail()
    await signUp(page, email)
    await setStoredToken(page, 'garbage.token.value')

    await page.goto('/recommend')
    await expect(page).toHaveURL(/\/login$/)
    expect(await storedToken(page)).toBeNull()

    await logIn(page, email)
    await expect(page).toHaveURL(/\/recommend$/)
  })

  test('an empty-string token is treated as logged out', async ({ page }) => {
    await page.goto('/login')
    await setStoredToken(page, '')
    await page.goto('/wallet')
    await expect(page).toHaveURL(/\/login$/)
  })

  test('a 500 from /auth/me keeps the token so the session survives an outage', async ({ page }) => {
    await signUp(page, uniqueEmail())
    const token = await storedToken(page)

    await page.route('**/api/v1/auth/me', (route) =>
      route.fulfill({ status: 500, contentType: 'application/json', body: '{}' }),
    )
    await page.goto('/wallet')
    await expect(page).toHaveURL(/\/login$/)
    expect(await storedToken(page)).toBe(token)

    await page.unroute('**/api/v1/auth/me')
    await page.goto('/wallet')
    await expect(page).toHaveURL(/\/wallet$/)
    await expect(page.getByRole('button', { name: 'Log out' })).toBeVisible()
  })
})

test.describe('form errors', () => {
  test('a wrong password shows a form error and stays logged out', async ({ page }) => {
    const email = uniqueEmail()
    await signUp(page, email)
    await logOut(page)

    await logIn(page, email, 'wrong-password')
    await expect(page.getByRole('alert')).toHaveText('Invalid email or password')
    await expect(page).toHaveURL(/\/login$/)
    expect(await storedToken(page)).toBeNull()
  })

  test('a duplicate email shows an inline error on the email field', async ({ page }) => {
    const email = uniqueEmail()
    await signUp(page, email)
    await logOut(page)

    await page.goto('/signup')
    await fillCredentials(page, email, PASSWORD)
    await page.getByRole('button', { name: 'Create account' }).click()
    await expect(page.getByText('Email has already been taken')).toBeVisible()
    await expect(page.getByLabel('Email')).toHaveAttribute('aria-invalid', 'true')
  })

  test('a short password shows an inline error on the password field', async ({ page }) => {
    await page.goto('/signup')
    await fillCredentials(page, uniqueEmail(), 'short')
    await page.getByRole('button', { name: 'Create account' }).click()
    await expect(page.getByText(/^Password is too short/)).toBeVisible()
    await expect(page.getByLabel('Password')).toHaveAttribute('aria-invalid', 'true')
  })

  test('a 500 from login shows a generic message, not an internal one', async ({ page }) => {
    await page.route('**/api/v1/auth/login', (route) =>
      route.fulfill({ status: 500, contentType: 'text/html', body: '<h1>boom</h1>' }),
    )
    await page.goto('/login')
    await logIn(page, uniqueEmail())
    await expect(page.getByRole('alert')).toHaveText('Something went wrong. Please try again.')
  })
})

test.describe('not found', () => {
  test('a logged-out unknown URL shows the 404 page instead of redirecting', async ({ page }) => {
    await page.goto('/some-typo')
    await expect(page).toHaveURL(/\/some-typo$/)
    await expect(page.getByRole('heading', { name: 'Page not found' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Log out' })).toHaveCount(0)
  })

  test('a logged-in unknown URL shows the 404 page inside the app shell', async ({ page }) => {
    await signUp(page, uniqueEmail())
    await page.goto('/some-typo')
    await expect(page.getByRole('heading', { name: 'Page not found' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Log out' })).toBeVisible()
  })
})
