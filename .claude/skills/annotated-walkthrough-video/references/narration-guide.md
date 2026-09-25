# Writing the narration

The point of the video is the reasoning, not the clicking. Anyone can watch someone fill in a form; what a viewer cannot get from the screen is why the product works this way and how the code behind it is shaped. Every scene should answer three questions, in this order, in plain spoken English:

1. **What is on screen.** One sentence. Name the page and what the user is doing.
2. **Why it exists.** The product reason. What problem this screen solves for someone standing at a checkout, why the empty state says what it says, why a result is shown before the table.
3. **How it is built.** The engineering reason. Which service object does the work, which endpoint is called, why the logic lives there and not in the controller or the component, what trade-off was chosen.

Aim for 40 to 70 spoken words per scene, about 15 to 25 seconds at the default rate. Title cards get 15 to 30 words. Keep the whole video under about six minutes; longer than that and the recording flakes and nobody watches to the end.

## Sound like a person

The narration is spoken by text-to-speech, so write for the ear:

- Short sentences. One idea each. The subtitle cues split on sentence boundaries, so long sentences make long cues.
- Say "the API" and "the recommendation engine", not `POST /api/v1/recommendations` and `Recommendations::Calculate`. Put the exact route or class name in the caption instead, where it can be read.
- Spell out numbers and money the way you would say them: "one hundred and fifty dollars", "five times points". Digits are fine in captions.
- No bullet lists, no headings, no markdown in narration. It is read aloud verbatim.
- Avoid words that text-to-speech mangles: acronyms without vowels, camelCase identifiers, file paths. "JWT" reads as letters and is fine; `has_secure_password` is not.

## Reasoning, not description

Weak: "Here is the wallet page. You can add and remove cards."

Strong: "This is the wallet, the list of cards the user actually carries. The whole app is only as good as this list, so adding a card is one search and one click, and removing one asks for confirmation because an accidental removal would silently change every recommendation. On the backend the wallet is its own set of services, add, remove and list, so the recommendation engine can ask for the wallet without knowing how it is stored."

The second version tells the viewer what decision was made and what would go wrong without it. Look for those decisions in the code before writing: a validation limit, an empty state, an ordering rule, a confirmation step, a place where logic was pulled into a service. Each one is a sentence of narration.

## Ground it in the current code

Read before you write. The narration must match what the code does today, not what you remember. In particular check:

- the routes file, for which endpoints exist and what they are called
- the services directory, for the name and shape of each operation
- the ranking and valuation math in the engine, and the tie-break order
- the frontend pages, for exact labels, empty states and where state lives (URL, localStorage, memory)
- the README and CLAUDE.md, for the architecture rules the codebase claims to follow, so the narration can point at them being honoured

If something in the code contradicts what you planned to say, change the narration, never the claim.

## Captions

The caption bar sits under the scene title and stays on screen for the whole scene. Use it for the one concrete fact the narration alludes to, in product terms: the rule, the limit, the reason. Under 140 characters. Keep endpoints, service class names and file paths out of captions unless the user says the audience is engineers who want to see the code behind each screen; a demo for anyone else reads better without them, and the narration already carries the reasoning.

| Narration says | Caption shows |
|---|---|
| "signing up returns a token the browser keeps for a week" | `Just an email and a password. You stay signed in for seven days on this device.` |
| "the engine values every card in the wallet" | `Points = amount × the card's rate for this category. Value = points × what one point is worth.` |
| "an empty wallet sends you to set one up" | `Nothing works without a wallet, so the first screen has one job: get your first card added.` |

## Structure of the whole video

1. Title card: what the app is and who it is for, in one breath.
2. One scene per screen in the order a new user meets them.
3. When a screen has a result worth reading, give the result its own scene so the narrator can explain the numbers while the frame holds.
4. A short closing card: the architecture in one sentence and where to look in the repo.
