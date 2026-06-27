# Story Mode — Manual Testing Scenarios

Execute these tests after deploying configuration from `manual-configuration-setup.md`.

---

## Prerequisites

- [ ] Signed-in test user (anonymous or Google)
- [ ] `story_mode_enabled=true` in Remote Config
- [ ] Today's `detectiveCases/{YYYY-MM-DD}` document exists
- [ ] Firebase Analytics DebugView open (optional)

---

## Phase 6 — Leaderboards

### TC-6.1 Weekly points on case complete

1. Complete today's detective case (all 3 clues).
2. Open **Leaderboard → Detective** tab.
3. Verify your entry shows with correct total points.
4. Return to **Dashboard** — verify **Detective progress** panel shows weekly points and rank.

**Expected:** Points match case score; rank appears if on leaderboard.

### TC-6.2 Top entries ordering

1. With two test accounts, complete cases with different scores.
2. Open Detective leaderboard.

**Expected:** Higher `totalPoints` ranks above lower.

### TC-6.3 Story streak

1. Complete case on day 1.
2. Complete case on day 2 (next calendar day, UTC).
3. Skip a day, then complete again.

**Expected:** Streak increments on consecutive days; resets after missed day.

### TC-6.4 Week rollover (optional)

1. Complete a case on Sunday UTC.
2. Complete another on Monday UTC (new ISO week).

**Expected:** Weekly points reset in leaderboard; total lifetime points accumulate.

---

## Phase 7 — Atmosphere

### TC-7.1 Noir theme isolation

1. Open **Detective Case** (`/story`).
2. Note dark palette and typewriter/serif narrative font.
3. Return to dashboard and open **Play Today's Puzzle**.

**Expected:** Story screens look distinct; daily Wordle unchanged.

### TC-7.2 Typewriter effect

1. Open case intro or resolution narrative.
2. Tap text while revealing.

**Expected:** Characters animate in; tap skips to full text.

### TC-7.3 Reduced motion

1. Enable system **Reduce motion** (iOS/Android accessibility).
2. Open story intro.

**Expected:** Full text appears immediately (no typewriter).

### TC-7.4 Audio (if assets added)

1. Enter story flow with audio files in `assets/audio/`.
2. Exit to dashboard.

**Expected:** Rain plays in story; stops on exit.

---

## Phase 8 — Sharing

### TC-8.1 Share sheet

1. Complete a case and reach **Case Resolution**.
2. Tap **Share results**.

**Expected:** Native share sheet opens (iOS/Android).

### TC-8.2 Share content

1. Share to Notes or Messages.
2. Inspect text.

**Expected:** Contains score, outcome label, 3 clue emoji grids; no plain-text answer words.

### TC-8.3 WhatsApp (optional)

1. Share via WhatsApp if installed.

**Expected:** Formatted multi-line text preserved.

---

## Phase 9 — Monetization

### TC-9.1 Banner ad (debug)

1. With test AdMob IDs, open **Detective Case** home.
2. Scroll to banner area.

**Expected:** Test banner appears (or empty if ad fails to load).

### TC-9.2 Interstitial after resolution

1. Complete case; view resolution screen.

**Expected:** Test interstitial may show once (unless Remove Ads / Pro).

### TC-9.3 Remove ads entitlement

1. Manually set `hasRemoveAds: true` on user doc (or purchase in sandbox).
2. Repeat TC-9.1 and TC-9.2.

**Expected:** No banner or interstitial.

### TC-9.4 Hint pack consumption

1. Set `hintPackBalance: 3` on user doc.
2. Use hint flow (when wired in hint UI).
3. Verify balance decrements in Firestore.

**Expected:** Balance decreases by 1 per hint.

### TC-9.5 Restore purchases

1. Open **Settings → Restore purchases**.

**Expected:** No crash; snackbar confirmation; entitlements restored from store.

---

## Phase 10 — Analytics & Polish

### TC-10.1 Analytics events

Complete one full case and verify in DebugView:

| Event | When |
| ----- | ---- |
| `story_case_started` | After intro Continue |
| `story_clue_started` | Each clue Wordle opens |
| `story_clue_solved` or `story_clue_failed` | Each clue ends |
| `story_case_completed` | Resolution shown |
| `story_share_tapped` | Share tapped |

### TC-10.2 No case today

1. Remove or use a date without `detectiveCases` doc.

**Expected:** Friendly message: "Today's detective case isn't ready yet."

### TC-10.3 Offline behavior

1. Enable airplane mode.
2. Open story mode.

**Expected:** Error with retry; app does not crash.

### TC-10.4 Resume mid-case

1. Start case, complete clue 1.
2. Kill app.
3. Reopen → Detective Case → Continue.

**Expected:** Resumes at correct clue.

### TC-10.5 Completed case lock

1. Finish today's case.
2. Attempt to re-play for score.

**Expected:** Read-only review; no re-scoring.

### TC-10.6 Feature flag off

1. Set `story_mode_enabled=false` in Remote Config; fetch.
2. Restart app.

**Expected:** No Detective Case tile; no detective stats panel.

### TC-10.7 Rollout percentage

1. Set `story_mode_enabled=true`, `story_mode_rollout_percent=0`.

**Expected:** Story hidden for all users.

2. Set rollout to `100`.

**Expected:** Story visible for all users.

### TC-10.8 Daily Wordle regression

1. Play daily Wordle.
2. Complete or review result.

**Expected:** No story-mode regressions.

### TC-10.9 Firestore cheat prevention

1. Attempt to write answer directly to `detectiveCases` from client.

**Expected:** Permission denied.

---

## QA sign-off checklist (Phase 10)

- [ ] New user: full case flow 0 → resolution
- [ ] Resume mid-clue after app kill
- [ ] Resume mid-case between clues
- [ ] All 4 outcomes display correctly
- [ ] Max score 300 achievable
- [ ] Completed case cannot replay same day
- [ ] Midnight UTC rollover documented and tested
- [ ] Feature flag off hides all story entry points
- [ ] No regression on daily Wordle or archive modes
- [ ] Firestore rules block cheating

---

## Test data tips

- **Seed case:** `cd functions && npm run seed -- --date $(date -u +%Y-%m-%d)`
- **Emulator:** `firebase emulators:start` + point app to emulator
- **Two users:** Use separate auth accounts for leaderboard ordering tests
