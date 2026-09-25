# Storyboard format

A storyboard is one JSON file that `scripts/record.mjs` plays back in Chromium. Every scene is one chapter of the video: the narration audio for the scene starts the moment the scene starts, the steps play out while the narrator talks, and the recorder holds the final frame until the narration finishes plus `holdAfter` milliseconds. Write narration and steps so they roughly line up: a scene with 25 seconds of narration and a single click will sit on one frame for 20 seconds, which is fine for a results screen but dull for a form.

```json
{
  "title": "Credit Card Optimizer walkthrough",
  "settings": { "voice": "Samantha", "speechRate": 180 },
  "vars": { "amount": "150" },
  "scenes": [
    {
      "id": "signup",
      "title": "Creating an account",
      "caption": "Just an email and a password. You stay signed in for seven days on this device.",
      "narration": "Two or three sentences spoken aloud while the steps run.",
      "minDuration": 4000,
      "steps": [
        { "goto": "/signup" },
        { "fill": { "target": { "label": "Email" }, "value": "{{email}}" } },
        { "fill": { "target": { "label": "Password" }, "value": "{{password}}" } },
        { "highlight": { "role": "button", "name": "Create account" }, "pause": 900 },
        { "click": { "role": "button", "name": "Create account" } },
        { "expectUrl": "/dashboard" }
      ]
    }
  ]
}
```

## Top level

| Key | Meaning |
|---|---|
| `title` | Heading of the transcript. |
| `settings` | Overrides for the defaults below. |
| `vars` | Values available as `{{name}}` inside any step string. `email` (unique per run) and `password` are always defined. |
| `scenes` | Ordered list of scenes. |

### Settings and their defaults

| Setting | Default | Notes |
|---|---|---|
| `baseUrl` | `http://localhost:5173` | Frontend. |
| `apiUrl` | `http://localhost:3000` | Backend, used by `api` steps. |
| `viewport` | `{ "width": 1280, "height": 800 }` | Also the video size. Keep both even numbers. |
| `voice` | `Samantha` | Any `say -v '?'` voice. Falls back to the system default if missing. |
| `speechRate` | `180` | Words per minute. |
| `pace` | `500` | Pause in ms after each step. A step's own `pause` overrides it. |
| `typingDelay` | `45` | Delay in ms between typed characters. |
| `holdAfter` | `1200` | Hold after narration ends before the next scene. |
| `minSceneDuration` | `3000` | Floor for scenes without narration. |
| `leadIn` | `800` | Silence before the first scene, absorbs recorder start-up latency. |
| `authTokenKey` | `auth_token` | localStorage key holding the bearer token for `api` steps. |

## Scene keys

| Key | Meaning |
|---|---|
| `id` | Short slug, used for file names and `--only`. |
| `title` | Shown bold in the caption bar and in the transcript. |
| `caption` | One line of on-screen text under the title. Keep it under about 140 characters so it fits on two lines. Use it for the one concrete product fact of the scene; the narration carries the reasoning. No endpoints or class names unless the audience is engineers. |
| `narration` | Spoken text. Also becomes the subtitle cues and the transcript. |
| `minDuration` | Optional floor in ms for this scene. |
| `steps` | Ordered actions. |

## Steps

Each step is an object with exactly one action key, plus an optional `pause` (ms to wait after the step, replacing `pace`).

| Step | Example | Behaviour |
|---|---|---|
| `goto` | `{ "goto": "/wallet" }` | Navigate relative to `baseUrl`, wait for load and a short network idle. |
| `click` | `{ "click": { "role": "button", "name": "Add cards" } }` | Glide the cursor to the element, then click. |
| `fill` | `{ "fill": { "target": { "label": "Amount" }, "value": "150" } }` | Click into the field and type character by character. Add `"instant": true` to paste instead. |
| `select` | `{ "select": { "target": { "label": "Category" }, "value": "dining" } }` | Pick an option by value or label. |
| `press` | `{ "press": "Escape" }` | Keyboard key. |
| `hover` | `{ "hover": { "text": "Best" } }` | Move the cursor onto the element. |
| `scroll` | `{ "scroll": { "target": { "role": "table" } } }` or `{ "scroll": { "y": 400 } }` | Scroll an element into view or by pixels. |
| `highlight` | `{ "highlight": { "role": "region", "name": "Why this card" } }` | Draw an amber ring around the element and dim the rest of the page. Stays until `unhighlight` or the end of the scene. |
| `unhighlight` | `{ "unhighlight": true }` | Remove the ring. |
| `card` | `{ "card": { "eyebrow": "Part 2", "title": "The wallet", "subtitle": "..." } }` | Full-screen title card over the page. Stays until `uncard` or the end of the scene; highlights are hidden while it shows. |
| `uncard` | `{ "uncard": true }` | Remove the title card. |
| `caption` | `{ "caption": "New text" }` | Change the caption text mid-scene. |
| `expectVisible` | `{ "expectVisible": { "text": "1 card in your wallet" } }` | Wait up to 10s for the element. Use it after clicks that load data so the narration is never ahead of the screen. |
| `expectHidden` | `{ "expectHidden": { "role": "dialog" } }` | Wait for the element to disappear. |
| `expectUrl` | `{ "expectUrl": "/dashboard" }` | Wait for the URL to end with or match the value. |
| `wait` | `{ "wait": 1500 }` | Plain pause. |
| `api` | `{ "api": { "method": "POST", "path": "/api/v1/wallet", "body": { "credit_card_id": "{{search.cards[0].id}}" } } }` | Call the backend with the signed-in user's token. `saveAs` stores the JSON response in `vars`. Use it for setup that should not be on camera. |

## Locators

Any target can be a CSS string or one of these objects, mirroring Playwright's accessible queries. Prefer roles and labels, they are what the e2e specs already use and they survive styling changes.

| Form | Example |
|---|---|
| Role and name | `{ "role": "button", "name": "Find the best card" }` |
| Label | `{ "label": "Search cards" }` |
| Text | `{ "text": "No cards yet", "exact": true }` |
| Placeholder | `{ "placeholder": "0.00" }` |
| Test id | `{ "testId": "wallet-tile" }` |
| CSS | `{ "selector": "tbody tr:first-child" }` or just `"tbody tr:first-child"` |

Add `"within": <locator>` to scope the search, and `"nth": 1` to pick a later match. Without `nth` the first match is used.

## Output of a run

```
walkthroughs/<stamp>/
  storyboard.json    what was recorded
  walkthrough.mp4    1280x800 H.264 with AAC narration
  walkthrough.srt    subtitles, one cue per narrated sentence
  transcript.md      timestamps, scene titles and narration
  report.json        scene timings, duration, any failures
  stills/            last frame of every scene, for review
  failures/          screenshot at the failing step, if any
  audio/, raw-video/ intermediates
```

Recorder flags: `--storyboard <file>`, `--out <dir>`, `--only signup,wallet` (record a subset while iterating), `--no-narration`, `--continue-on-error`, `--project-root <dir>`.
