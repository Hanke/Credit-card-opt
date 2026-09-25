#!/usr/bin/env node
import fs from 'node:fs'
import path from 'node:path'
import { createRequire } from 'node:module'
import { spawnSync } from 'node:child_process'

const args = parseArgs(process.argv.slice(2))
const scriptDir = path.dirname(new URL(import.meta.url).pathname)
const projectRoot = path.resolve(args['project-root'] ?? path.join(scriptDir, '../../../..'))
const storyboardPath = path.resolve(args.storyboard ?? 'storyboard.json')
const outDir = path.resolve(args.out ?? path.dirname(storyboardPath))
const narrationEnabled = !args['no-narration']
const continueOnError = Boolean(args['continue-on-error'])
const onlyScenes = args.only ? String(args.only).split(',') : null

const require = createRequire(path.join(projectRoot, 'frontend', 'package.json'))
const { chromium } = require('playwright')

const storyboard = JSON.parse(fs.readFileSync(storyboardPath, 'utf8'))
const settings = {
  baseUrl: 'http://localhost:5173',
  apiUrl: 'http://localhost:3000',
  viewport: { width: 1280, height: 800 },
  voice: 'Samantha',
  speechRate: 180,
  pace: 500,
  typingDelay: 45,
  holdAfter: 1200,
  minSceneDuration: 3000,
  leadIn: 800,
  authTokenKey: 'auth_token',
  ...storyboard.settings,
}
const runId = Date.now()
const vars = {
  email: `demo-${runId}@example.com`,
  password: 'correct-horse-battery',
  ...storyboard.vars,
}

const dirs = {
  audio: path.join(outDir, 'audio'),
  stills: path.join(outDir, 'stills'),
  failures: path.join(outDir, 'failures'),
  video: path.join(outDir, 'raw-video'),
}
for (const dir of Object.values(dirs)) fs.mkdirSync(dir, { recursive: true })

const scenes = storyboard.scenes.filter((scene) => !onlyScenes || onlyScenes.includes(scene.id))
if (scenes.length === 0) fail('No scenes to record')

const narration = narrationEnabled ? synthesizeNarration(scenes) : new Map()
const timeline = []
const failures = []

const browser = await chromium.launch()
const context = await browser.newContext({
  viewport: settings.viewport,
  deviceScaleFactor: 1,
  colorScheme: 'light',
  recordVideo: { dir: dirs.video, size: settings.viewport },
})
await context.addInitScript(overlayScript())
const page = await context.newPage()
if (process.env.WALK_DEBUG) {
  page.on('console', (m) => log(`    [console.${m.type()}] ${m.text()}`))
  page.on('pageerror', (e) => log(`    [pageerror] ${e.message}`))
  page.on('dialog', (d) => log(`    [dialog] ${d.message()}`))
}
const recordStart = Date.now()
const overlay = { step: '', title: '', text: '', highlight: null, card: null }

await sleep(settings.leadIn)

for (const [index, scene] of scenes.entries()) {
  const sceneStart = Date.now()
  const label = `${String(index + 1).padStart(2, '0')}-${scene.id}`
  overlay.step = `Scene ${index + 1} of ${scenes.length}`
  overlay.title = scene.title ?? ''
  overlay.text = scene.caption ?? ''
  overlay.highlight = null
  overlay.card = null
  await applyOverlay()
  log(`▶ ${label}: ${scene.title ?? ''}`)

  try {
    for (const [stepIndex, step] of (scene.steps ?? []).entries()) {
      if (process.env.WALK_DEBUG) log(`    step ${stepIndex + 1} start`)
      await runStep(scene, step, stepIndex)
      if (process.env.WALK_DEBUG) log(`    step ${stepIndex + 1} ${JSON.stringify(step).slice(0, 80)} → ${JSON.stringify(await page.evaluate(() => ({ dialog: document.querySelector('dialog')?.open ?? null, popover: document.getElementById('__walk')?.matches(':popover-open') ?? null, cursor: document.querySelector('[data-walk=cursor]')?.style.left })).catch((e) => e.message.split('\n')[0]))}`)
      await applyOverlay()
      await sleep(step.pause ?? settings.pace)
    }
  } catch (error) {
    const shot = path.join(dirs.failures, `${label}.png`)
    await page.screenshot({ path: shot, fullPage: false }).catch(() => {})
    failures.push({ scene: scene.id, message: error.message, screenshot: shot })
    log(`✖ ${label} failed: ${error.message.split('\n')[0]}`)
    if (!continueOnError) break
  }

  const audio = narration.get(scene.id)
  const target = Math.max(scene.minDuration ?? settings.minSceneDuration, (audio?.durationMs ?? 0) + settings.holdAfter)
  const elapsed = Date.now() - sceneStart
  if (elapsed < target) await sleep(target - elapsed)
  await page.screenshot({ path: path.join(dirs.stills, `${label}.png`) }).catch(() => {})
  timeline.push({
    id: scene.id,
    title: scene.title ?? '',
    narration: scene.narration ?? '',
    startMs: sceneStart - recordStart,
    endMs: Date.now() - recordStart,
    audioMs: audio?.durationMs ?? 0,
  })
}

await page.close()
const rawVideo = await page.video().path()
await context.close()
await browser.close()

const outputVideo = path.join(outDir, 'walkthrough.mp4')
muxVideo(rawVideo, outputVideo)
writeSubtitles(path.join(outDir, 'walkthrough.srt'))
writeTranscript(path.join(outDir, 'transcript.md'))
const report = {
  video: outputVideo,
  subtitles: path.join(outDir, 'walkthrough.srt'),
  transcript: path.join(outDir, 'transcript.md'),
  durationSeconds: probeDuration(outputVideo),
  scenes: timeline,
  failures,
}
fs.writeFileSync(path.join(outDir, 'report.json'), JSON.stringify(report, null, 2))
printSummary(report)
process.exit(failures.length ? 1 : 0)

async function runStep(scene, step, stepIndex) {
  const resolved = substitute(step)
  const kind = Object.keys(resolved).find((key) => key !== 'pause')
  const value = resolved[kind]
  switch (kind) {
    case 'goto':
      await page.goto(settings.baseUrl + value, { waitUntil: 'load' })
      await page.waitForLoadState('networkidle', { timeout: 4000 }).catch(() => {})
      return
    case 'click': {
      const target = locate(value)
      await glideTo(target)
      await target.click()
      return
    }
    case 'fill': {
      const target = locate(value.target ?? value)
      await glideTo(target)
      await target.click()
      if (value.instant) await target.fill(value.value)
      else {
        await target.fill('')
        await target.pressSequentially(String(value.value), { delay: settings.typingDelay })
      }
      return
    }
    case 'select': {
      const target = locate(value.target)
      await glideTo(target)
      await target.selectOption(value.value)
      return
    }
    case 'press':
      await page.keyboard.press(value)
      return
    case 'hover': {
      const target = locate(value)
      await glideTo(target)
      await target.hover()
      return
    }
    case 'scroll': {
      if (value.target) await locate(value.target).scrollIntoViewIfNeeded()
      else await page.mouse.wheel(0, value.y ?? 400)
      return
    }
    case 'highlight':
      await locate(value).scrollIntoViewIfNeeded().catch(() => {})
      await sleep(300)
      overlay.highlight = value
      return
    case 'unhighlight':
      overlay.highlight = null
      return
    case 'card':
      overlay.card = value
      return
    case 'uncard':
      overlay.card = null
      return
    case 'caption':
      overlay.text = value
      return
    case 'expectVisible':
      await locate(value).waitFor({ state: 'visible', timeout: 10000 })
      return
    case 'expectHidden':
      await locate(value).waitFor({ state: 'hidden', timeout: 10000 })
      return
    case 'expectUrl':
      await page.waitForURL((url) => url.pathname + url.search === value || url.href.endsWith(value) || new RegExp(value).test(url.href), { timeout: 10000 })
      return
    case 'wait':
      await sleep(value)
      return
    case 'api':
      await callApi(value)
      return
    default:
      throw new Error(`Scene "${scene.id}" step ${stepIndex + 1}: unknown step "${kind}"`)
  }
}

function locate(spec) {
  const options = {}
  if (spec.exact !== undefined) options.exact = spec.exact
  let locator
  if (typeof spec === 'string') locator = page.locator(spec)
  else if (spec.role) locator = page.getByRole(spec.role, { name: spec.name, ...options })
  else if (spec.label) locator = page.getByLabel(spec.label, options)
  else if (spec.text) locator = page.getByText(spec.text, options)
  else if (spec.placeholder) locator = page.getByPlaceholder(spec.placeholder, options)
  else if (spec.testId) locator = page.getByTestId(spec.testId)
  else if (spec.selector) locator = page.locator(spec.selector)
  else throw new Error(`Cannot resolve locator ${JSON.stringify(spec)}`)
  if (spec.within) locator = locate(spec.within).locator(locator)
  return spec.nth !== undefined ? locator.nth(spec.nth) : locator.first()
}

async function glideTo(locator) {
  await locator.waitFor({ state: 'visible', timeout: 10000 })
  await locator.scrollIntoViewIfNeeded()
  const box = await locator.boundingBox()
  if (!box) return
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2, { steps: 24 })
}

async function callApi(request) {
  const token = await page.evaluate((key) => localStorage.getItem(key), settings.authTokenKey)
  const response = await page.request.fetch(settings.apiUrl + request.path, {
    method: request.method ?? 'GET',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    data: request.body,
  })
  if (!response.ok()) throw new Error(`API ${request.method ?? 'GET'} ${request.path} returned ${response.status()}`)
  if (request.saveAs) vars[request.saveAs] = await response.json().catch(() => null)
}

async function applyOverlay() {
  const highlight = overlay.highlight ? await locate(overlay.highlight).boundingBox().catch(() => null) : null
  const state = { ...overlay, highlight }
  for (let attempt = 0; attempt < 3; attempt += 1) {
    try {
      await page.evaluate((s) => window.__walk?.apply(s), state)
      return
    } catch {
      await page.waitForLoadState('load').catch(() => {})
      await sleep(150)
    }
  }
}

function substitute(value) {
  if (typeof value === 'string') return value.replace(/\{\{\s*([\w.\[\]]+)\s*\}\}/g, (_, key) => String(lookup(key) ?? ''))
  if (Array.isArray(value)) return value.map(substitute)
  if (value && typeof value === 'object') return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, substitute(v)]))
  return value
}

function lookup(dotted) {
  return dotted.replace(/\[(\d+)\]/g, '.$1').split('.').reduce((acc, key) => (acc == null ? undefined : acc[key]), vars)
}

function synthesizeNarration(list) {
  const result = new Map()
  const hasSay = spawnSync('which', ['say']).status === 0
  if (!hasSay) {
    log('⚠ macOS "say" not found; recording without narration (captions and subtitles still included)')
    return result
  }
  for (const [index, scene] of list.entries()) {
    if (!scene.narration) continue
    const base = path.join(dirs.audio, `${String(index + 1).padStart(2, '0')}-${scene.id}`)
    fs.writeFileSync(`${base}.txt`, scene.narration)
    let say = spawnSync('say', ['-v', settings.voice, '-r', String(settings.speechRate), '-f', `${base}.txt`, '-o', `${base}.aiff`])
    if (say.status !== 0) say = spawnSync('say', ['-r', String(settings.speechRate), '-f', `${base}.txt`, '-o', `${base}.aiff`])
    if (say.status !== 0) fail(`say failed for scene ${scene.id}: ${say.stderr}`)
    run('ffmpeg', ['-y', '-loglevel', 'error', '-i', `${base}.aiff`, '-ar', '44100', '-ac', '2', `${base}.wav`])
    result.set(scene.id, { file: `${base}.wav`, durationMs: Math.round(probeDuration(`${base}.wav`) * 1000) })
  }
  log(`♪ narrated ${result.size} scene(s) with voice "${settings.voice}"`)
  return result
}

function muxVideo(input, output) {
  const clips = timeline.filter((entry) => narration.get(entry.id)).map((entry) => ({ ...narration.get(entry.id), at: entry.startMs }))
  const inputs = ['-i', input]
  const filters = []
  clips.forEach((clip, i) => {
    inputs.push('-i', clip.file)
    filters.push(`[${i + 1}]adelay=${clip.at}|${clip.at}[a${i}]`)
  })
  let audioMap = []
  if (clips.length === 1) {
    filters.push('[a0]apad[mix]')
    audioMap = ['-map', '[mix]']
  } else if (clips.length > 1) {
    filters.push(`${clips.map((_, i) => `[a${i}]`).join('')}amix=inputs=${clips.length}:normalize=0:duration=longest,apad[mix]`)
    audioMap = ['-map', '[mix]']
  }
  const filterArgs = filters.length ? ['-filter_complex', filters.join(';')] : []
  run('ffmpeg', [
    '-y', '-loglevel', 'error', ...inputs, ...filterArgs,
    '-map', '0:v', ...audioMap,
    '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-pix_fmt', 'yuv420p', '-r', '30',
    ...(clips.length ? ['-c:a', 'aac', '-b:a', '160k', '-shortest'] : []),
    '-movflags', '+faststart', output,
  ])
}

function writeSubtitles(file) {
  const cues = []
  for (const entry of timeline) {
    const sentences = splitSentences(entry.narration)
    if (sentences.length === 0) continue
    const span = entry.audioMs || entry.endMs - entry.startMs
    const totalChars = sentences.reduce((sum, s) => sum + s.length, 0)
    let cursor = entry.startMs
    for (const sentence of sentences) {
      const length = Math.max(800, Math.round((sentence.length / totalChars) * span))
      cues.push({ start: cursor, end: Math.min(cursor + length, entry.endMs), text: sentence })
      cursor += length
    }
  }
  const body = cues.map((cue, i) => `${i + 1}\n${srtTime(cue.start)} --> ${srtTime(cue.end)}\n${cue.text}\n`).join('\n')
  fs.writeFileSync(file, body)
}

function writeTranscript(file) {
  const lines = [`# ${storyboard.title ?? 'Walkthrough'}`, '']
  for (const entry of timeline) {
    lines.push(`## ${clock(entry.startMs)} – ${clock(entry.endMs)}  ${entry.title}`, '', entry.narration, '')
  }
  fs.writeFileSync(file, lines.join('\n'))
}

function printSummary(report) {
  log('')
  log(`✔ ${report.video} (${report.durationSeconds.toFixed(1)}s, ${report.scenes.length} scenes)`)
  for (const entry of report.scenes) log(`  ${clock(entry.startMs)}  ${entry.title}`)
  if (report.failures.length) {
    log('')
    for (const failure of report.failures) log(`✖ scene "${failure.scene}": ${failure.message.split('\n')[0]} → ${failure.screenshot}`)
  }
}

function splitSentences(text) {
  return (text.match(/[^.!?]+[.!?]+["')\]]*\s*|[^.!?]+$/g) ?? []).map((s) => s.trim()).filter(Boolean)
}

function srtTime(ms) {
  const h = Math.floor(ms / 3600000)
  const m = Math.floor((ms % 3600000) / 60000)
  const s = Math.floor((ms % 60000) / 1000)
  return `${pad(h)}:${pad(m)}:${pad(s)},${String(ms % 1000).padStart(3, '0')}`
}

function clock(ms) {
  return `${pad(Math.floor(ms / 60000))}:${pad(Math.floor((ms % 60000) / 1000))}`
}

function pad(n) {
  return String(n).padStart(2, '0')
}

function probeDuration(file) {
  const out = run('ffprobe', ['-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', file])
  return Number.parseFloat(out) || 0
}

function run(command, commandArgs) {
  const result = spawnSync(command, commandArgs, { encoding: 'utf8' })
  if (result.status !== 0) fail(`${command} ${commandArgs.join(' ')}\n${result.stderr}`)
  return result.stdout
}

function parseArgs(list) {
  const parsed = {}
  for (let i = 0; i < list.length; i += 1) {
    if (!list[i].startsWith('--')) continue
    const key = list[i].slice(2)
    const next = list[i + 1]
    if (next && !next.startsWith('--')) {
      parsed[key] = next
      i += 1
    } else parsed[key] = true
  }
  return parsed
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

function log(message) {
  process.stderr.write(`${message}\n`)
}

function fail(message) {
  log(`✖ ${message}`)
  process.exit(1)
}

function overlayScript() {
  return `(() => {
    if (window.__walk) return
    const Z = 2147483000
    let root
    const parts = {}
    function ensure() {
      if (!document.documentElement) return false
      if (root && document.documentElement.contains(root)) return true
      root = document.createElement('div')
      root.id = '__walk'
      root.setAttribute('popover', 'manual')
      root.style.cssText = 'position:fixed;inset:0;width:100%;height:100%;margin:0;padding:0;border:0;background:transparent;overflow:visible;color:inherit;pointer-events:none;z-index:' + Z + ';font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Inter,sans-serif;'
      root.innerHTML = \`
        <div data-walk="highlight" style="position:fixed;display:none;border:3px solid #f59e0b;border-radius:10px;box-shadow:0 0 0 4px rgba(245,158,11,.25),0 0 0 9999px rgba(15,23,42,.30);transition:left .35s ease,top .35s ease,width .35s ease,height .35s ease;"></div>
        <div data-walk="card" style="position:fixed;inset:0;display:none;align-items:center;justify-content:center;flex-direction:column;background:linear-gradient(135deg,#0f172a 0%,#1e3a8a 100%);color:#fff;text-align:center;padding:48px;">
          <div data-walk="card-eyebrow" style="font-size:13px;font-weight:600;letter-spacing:.14em;text-transform:uppercase;color:#fbbf24;margin-bottom:18px;"></div>
          <div data-walk="card-title" style="font-size:46px;font-weight:800;letter-spacing:-.02em;line-height:1.1;max-width:900px;"></div>
          <div data-walk="card-subtitle" style="font-size:20px;margin-top:18px;color:#cbd5e1;max-width:760px;line-height:1.5;"></div>
        </div>
        <div data-walk="caption" style="position:fixed;left:50%;bottom:28px;transform:translateX(-50%);max-width:900px;width:calc(100% - 64px);display:none;background:rgba(15,23,42,.93);color:#fff;border-radius:14px;padding:14px 20px;box-shadow:0 10px 40px rgba(0,0,0,.35);">
          <div style="display:flex;align-items:baseline;gap:12px;margin-bottom:4px;">
            <span data-walk="step" style="font-size:11px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#fbbf24;white-space:nowrap;"></span>
            <span data-walk="title" style="font-size:16px;font-weight:700;"></span>
          </div>
          <div data-walk="text" style="font-size:14px;line-height:1.45;color:#e2e8f0;"></div>
        </div>
        <div data-walk="ring" style="position:fixed;left:-100px;top:-100px;width:22px;height:22px;border-radius:50%;border:3px solid #f59e0b;opacity:0;transform:translate(-50%,-50%);"></div>
        <div data-walk="cursor" style="position:fixed;left:-100px;top:-100px;width:18px;height:18px;border-radius:50%;background:rgba(245,158,11,.95);border:2px solid #fff;box-shadow:0 2px 8px rgba(0,0,0,.45);transform:translate(-50%,-50%);"></div>
      \`
      document.documentElement.appendChild(root)
      for (const el of root.querySelectorAll('[data-walk]')) parts[el.dataset.walk] = el
      return true
    }
    function raise() {
      if (!root.showPopover) return
      const shown = root.matches(':popover-open')
      const covered = !!document.querySelector('dialog[open]')
      if (shown && !covered) return
      try {
        if (shown) root.hidePopover()
        root.showPopover()
      } catch {}
    }
    window.addEventListener('mousemove', (e) => {
      if (!ensure()) return
      parts.cursor.style.left = e.clientX + 'px'
      parts.cursor.style.top = e.clientY + 'px'
      parts.ring.style.left = e.clientX + 'px'
      parts.ring.style.top = e.clientY + 'px'
    }, true)
    window.addEventListener('mousedown', () => {
      if (!ensure()) return
      parts.ring.animate(
        [{ opacity: 1, transform: 'translate(-50%,-50%) scale(1)' }, { opacity: 0, transform: 'translate(-50%,-50%) scale(3)' }],
        { duration: 450, easing: 'ease-out' },
      )
    }, true)
    window.__walk = {
      apply(state) {
        if (!ensure()) return
        raise()
        parts.step.textContent = state.step || ''
        parts.title.textContent = state.title || ''
        parts.text.textContent = state.text || ''
        parts.caption.style.display = state.title || state.text ? 'block' : 'none'
        if (state.card) {
          parts['card-eyebrow'].textContent = state.card.eyebrow || ''
          parts['card-title'].textContent = state.card.title || ''
          parts['card-subtitle'].textContent = state.card.subtitle || ''
          parts.card.style.display = 'flex'
        } else parts.card.style.display = 'none'
        const r = state.highlight
        if (r && !state.card) {
          const pad = 8
          parts.highlight.style.left = (r.x - pad) + 'px'
          parts.highlight.style.top = (r.y - pad) + 'px'
          parts.highlight.style.width = (r.width + pad * 2) + 'px'
          parts.highlight.style.height = (r.height + pad * 2) + 'px'
          parts.highlight.style.display = 'block'
        } else parts.highlight.style.display = 'none'
      },
    }
  })()`
}
