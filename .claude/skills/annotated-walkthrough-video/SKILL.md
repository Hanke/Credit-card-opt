---
name: annotated-walkthrough-video
description: Record a narrated, annotated walkthrough video of the Credit Card Optimizer app. Drives the real app in Chromium screen by screen, overlays captions, highlights and a visible cursor, speaks the reasoning behind every screen (why it exists, how it is built, which service backs it), and produces an mp4 with subtitles and a transcript. Use this whenever the user asks for a video, screen recording, demo, tour, walkthrough, explainer, "loom", or narrated run-through of the app, or wants to "show" the app to someone, even if they don't say the word video. Also use it when the user wants to explain or annotate the whole app end to end.
---

# Annotated walkthrough video

You produce a video that walks through the app the way a thoughtful engineer would demo it to a new teammate: every screen in the order a user meets it, with spoken reasoning about why the screen is the way it is and how the code behind it works. The mechanics are already solved by the bundled recorder. Your job is the thinking: an accurate, current, well-argued storyboard.

The recorder (`scripts/record.mjs`) plays a JSON storyboard in headless Chromium, draws captions, highlight rings and a cursor over the live app, narrates each scene with the macOS voice, and muxes it all with ffmpeg. Read `references/storyboard-format.md` for the step vocabulary and `references/narration-guide.md` for how to write narration that explains rather than describes.

## Workflow

### 1. Get the servers up

```bash
.claude/skills/annotated-walkthrough-video/scripts/preflight.sh
```

It checks ffmpeg, Playwright's Chromium and the `say` voice, starts the Rails backend on 3000 and Vite on 5173 in the development environment if they are not already running, and seeds the card catalogue if it is empty. Read its output; fix anything marked ✖ before continuing. The recording uses the development database, so it creates a real demo user each run (`demo-<timestamp>@example.com`).

### 2. Re-learn the app before writing a word

The narration is only worth watching if it is true of the code today. Even if you think you know the app, read these before writing the storyboard, because the last commit may have changed them:

- `frontend/src/routes/AppRoutes.tsx` for the pages and their guards
- the page components under `frontend/src/pages/` for exact headings, labels, button names, empty states and ARIA names (the recorder locates elements by role and label, the same way `frontend/e2e/*.spec.ts` does, so those specs are a reliable source of working locators)
- `backend/config/routes.rb` and `backend/app/services/**` for what each screen calls and why the logic lives where it does
- `README.md` and `CLAUDE.md` for the architecture rules the codebase claims, so the narration can point at them being honoured
- `git log --oneline -15` for what changed recently; if the user asked for the video because of a feature, that feature deserves its own scene

### 3. Write the storyboard

Start from `assets/storyboard.example.json`. It covers the full app as of when it was written: intro card, sign up, empty dashboard, adding three cards, the dashboard with a wallet, the quick check, the result, the comparison table, the explanations, the shareable URL, wallet management, sign out and an outro card. Copy it into the output directory and then edit it to match what you just read:

- update any label, heading or button name that has changed
- add a scene for anything new, remove scenes for anything gone
- rewrite narration wherever the reasoning no longer matches the code
- if the user asked for a focus (one feature, a shorter cut, a different audience), reshape the scene list around that rather than recording everything

Keep each scene's narration to about 40 to 70 words and the whole video under six minutes. The recorder holds each scene until the narration finishes, so a scene with long narration and no steps is fine for a results screen but feels frozen on a form. Put a `highlight` in every scene so the viewer's eye is led to what the narrator is talking about.

Save the storyboard to `walkthroughs/<YYYY-MM-DD-HHMM>/storyboard.json` at the repo root. The `walkthroughs/` directory is git-ignored.

### 4. Record

```bash
node .claude/skills/annotated-walkthrough-video/scripts/record.mjs \
  --storyboard walkthroughs/<stamp>/storyboard.json
```

Output lands next to the storyboard: `walkthrough.mp4`, `walkthrough.srt`, `transcript.md`, `report.json`, and a `stills/` folder with the last frame of every scene. A full run takes roughly the length of the video plus a minute for narration synthesis and encoding.

If a step fails, the recorder writes `failures/<scene>.png`, reports which scene and step broke, and stops so you can fix the storyboard. Use `--only <scene-id,...>` to re-record just the scenes you are iterating on, then run the whole thing once more at the end. Use `--continue-on-error` only to survey many problems at once, never for the final cut.

### 5. Check the result before handing it over

The user will watch this, so look at it first:

- open three or four of the `stills/` images (the result scene, a highlighted scene, a title card) and confirm the caption is readable, the highlight ring sits on the right element, and nothing is clipped
- read `transcript.md` end to end as if hearing it: no identifiers being spelled out, no sentence contradicting the code, timestamps rising sensibly
- confirm `report.json` has no failures and the duration is what you expect

Fix the storyboard and re-record if anything is off. A wrong claim in the narration is a bug, not a nit.

### 6. Report

Tell the user where the mp4 is, its length, and list the scenes with their start times from the report. Mention the transcript and subtitles exist. If you left out a screen or a feature on purpose, say which and why.

## Things that go wrong

- **"Seeded card not found" or an add button never appears**: the development database has no catalogue. Run `cd backend && bin/rails db:seed`.
- **Locator times out**: the label or role changed. Open the page component (or the matching e2e spec) and copy the exact accessible name. Roles come from the element: `<section aria-label>` is a `region`, `<ul aria-label>` is a `list`, a card with `aria-label` is usually an `article`.
- **Narration runs ahead of the screen**: add an `expectVisible` after the click that loads data, so the scene waits for the screen to settle before the clock runs.
- **Highlight ring on the wrong spot after a scroll**: the ring is recomputed after every step; add a `{ "wait": 300 }` after the scroll so the layout finishes first.
- **No `say` on this machine**: pass `--no-narration`. The captions, subtitles and transcript still carry the reasoning.
- **A step fails and the screenshot does not explain it**: re-run with `WALK_DEBUG=1` in the environment. The recorder then prints every step with the page's dialog, overlay and cursor state, plus browser console errors.
- **Video is silent but audio files exist**: check `report.json` timings; ffmpeg was called with one `adelay` per scene, and a failed mux prints its stderr.
