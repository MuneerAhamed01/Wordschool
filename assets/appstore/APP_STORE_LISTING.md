# WordSchool — App Store Listing & ASO Guide

Everything you need to submit WordSchool to the Apple App Store, with ASO-optimized naming, keywords, and marketing copy.

**Current app version:** 1.0.0 (build 4)  
**Bundle ID:** `com.wordschool.mat`  
**Contact:** [muneerahamed.dev@gmail.com](mailto:muneerahamed.dev@gmail.com)

---

## Quick copy-paste (recommended)

Use these as your primary listing unless you A/B test alternatives below.

| Field | Character limit | Recommended value |
| ----- | --------------- | ----------------- |
| **App Name** | 30 | `WordSchool: Word & Mystery` |
| **Subtitle** | 30 | `Daily Puzzles & Detective` |
| **Keywords** | 100 | `brain,vocabulary,spelling,5 letter,quiz,logic,mystery,detective,leaderboard,archive,share,free,case,noir` |
| **Privacy Policy URL** | — | `https://sites.google.com/view/wordschool/home` |
| **Support URL** | — | `https://sites.google.com/view/wordschool/home` |
| **Copyright** | — | `2026 Muneerahamed` (individual) — or `2026 Bosc Services` if submitting under that entity |
| **Promotional Text** | 170 | `Two daily challenges: a classic 5-letter word puzzle and a new detective mystery. Build streaks, climb weekly leaderboards, and replay past puzzles in the archive.` |
| **Primary Category** | — | Games → Word |
| **Secondary Category** | — | Games → Puzzle |
| **Age Rating** | — | 4+ (no restricted content) |
| **Price** | — | Free |

---

## ASO: App name options

Apple allows **30 characters** for the App Store name. Shorter names leave room for a keyword-rich subtitle. Pick one primary name and keep it consistent across App Store, in-app branding, and marketing.

### Tier 1 — Recommended

| App Name | Chars | Why it works |
| -------- | ----- | ------------ |
| **WordSchool: Word & Mystery** | 28 | Brand + dual hooks (word puzzle + detective mystery) |
| **WordSchool: Daily Word Puzzle** | 30 | Strong search intent for daily word games |
| **WordSchool: Puzzles & Cases** | 29 | Highlights both game modes clearly |

### Tier 2 — Brand-forward

| App Name | Chars | Why it works |
| -------- | ----- | ------------ |
| **WordSchool** | 10 | Clean brand; relies on subtitle/keywords for discovery |
| **WordSchool - Word Game** | 22 | Direct category signal |
| **WordSchool Detective** | 21 | Story mode as differentiator |

### Tier 3 — Discovery-forward (test carefully)

| App Name | Chars | Notes |
| -------- | ----- | ----- |
| **Daily Word Puzzle: WordSchool** | 30 | Keyword-first; weaker brand recall |
| **5-Letter Word Puzzle Game** | 26 | High search volume; no brand in name |

> **Note:** Production `CFBundleDisplayName` should be `WordSchool` (currently `Wordschool` in Xcode build settings). Update before submission so the home-screen name matches your listing.

---

## ASO: Subtitle options (30 characters max)

Subtitles appear under your app name in search results. Apple indexes them for search — do not repeat words already in your App Name.

| Subtitle | Chars | Best paired with |
| -------- | ----- | ---------------- |
| **Daily Puzzles & Detective** | 27 | `WordSchool: Word & Mystery` |
| **Guess, Streak & Solve Cases** | 29 | `WordSchool` |
| **Word Game + Mystery Cases** | 27 | `WordSchool` |
| **5-Letter Puzzles & Stories** | 28 | Brand-forward names |
| **Free Brain Training Game** | 26 | Retention-focused marketing |

---

## ASO: Keyword sets (100 characters max)

Rules:

- Comma-separated, **no spaces** after commas (saves characters)
- Do **not** repeat words from App Name or Subtitle (Apple ignores duplicates)
- No competitor trademarks in visible metadata (see legal note below)
- Max **100 characters** including commas

### Set A — Recommended (balanced)

```
brain,vocabulary,spelling,5 letter,quiz,logic,mystery,detective,leaderboard,archive,share,free,case,noir
```

**99 characters**

### Set B — Detective / story focus

```
mystery,detective,noir,investigate,clue,solve,story,narrative,crime,case,score,rank,weekly,points,share
```

**98 characters**

### Set C — Daily habit / retention focus

```
habit,morning,challenge,practice,win,stats,calendar,replay,notification,reminder,offline,quick,fun,teaser
```

**99 characters**

### Set D — Brain training focus

```
brain,trainer,teaser,vocab,spell,grid,keyboard,letter,logic,puzzle,casual,practice,skill,memory,thinking
```

**99 characters**

### Words to avoid in keywords (already in recommended name/subtitle)

`wordschool`, `word`, `mystery`, `daily`, `puzzle`, `detective` — if you use the recommended name + subtitle, prioritize the other high-value terms in your keyword field.

### Legal note on competitor terms

Many word games rank for terms like "wordle." Apple may reject obvious trademark use in **name/subtitle**, and competitors may complain. Using related generic terms (`5 letter`, `daily puzzle`, `guess the word`) is safer and still captures intent.

---

## Promotional text (170 characters)

Can be updated anytime without a new app review. Use for seasonal hooks, feature launches, or limited messaging.

### Default

```
Two daily challenges: a classic 5-letter word puzzle and a new detective mystery. Build streaks, climb weekly leaderboards, and replay past puzzles in the archive.
```

**159 characters**

### Alternates

```
New mystery case every day. Solve three word puzzles to uncover the location, weapon, and suspect. Can you close the case?
```

**122 characters**

```
Your daily brain workout is here — guess the word, then crack the detective case. Track streaks, share results, and compete on weekly leaderboards.
```

**145 characters**

```
One word puzzle. One detective case. Every day. Play free, build your streak, and see how you rank against detectives worldwide.
```

**127 characters**

---

## App description (4,000 characters max)

Paste into **Description** in App Store Connect.

```
WordSchool gives you two fresh brain challenges every day: a classic 5-letter word puzzle and an immersive detective mystery — all in one beautifully designed app.

Whether you have two minutes or twenty, WordSchool fits into your routine. Guess words, solve cases, protect your streak, and come back tomorrow for something new.

DAILY WORD PUZZLE
• Guess the hidden 5-letter word in up to 6 tries
• Green = correct letter, correct spot
• Orange = correct letter, wrong spot
• One new puzzle every day — same word for everyone
• Track your streak, wins, and personal best

DETECTIVE STORY MODE
• A brand-new mystery case drops every day
• Follow a noir-style narrative as you investigate
• Solve 3 word puzzles to uncover key clues:
  — Crime location
  — Murder weapon
  — Main suspect
• Earn detective points based on how efficiently you solve each clue
• Outcomes range from Case Closed to Cold Case — how sharp is your deduction?
• Immersive atmosphere with typewriter text and ambient rain audio

COMPETE & SHARE
• Weekly detective leaderboard — climb the ranks and beat your best
• Share your word puzzle results and case outcomes with friends
• Compare scores and detective outcomes on social media

BUILD YOUR STREAK
Play every day to grow your streak in both modes. Miss a day and the counter resets — so make it count. Your dashboard shows streaks, wins, detective points, and weekly rank at a glance.

REPLAY PAST PUZZLES
Missed yesterday? Want more practice? Open the archive and replay previous daily word puzzles on a calendar. Perfect for sharpening your skills without waiting for tomorrow.

STAY IN THE LOOP
Optional reminders nudge you when a new puzzle or detective case is ready, or when your streak is at risk. You control notifications in Settings.

PLAY YOUR WAY
• Sign in with Google or Apple to sync progress across devices
• Or jump in instantly with guest play
• Clean dark interface designed for focused play
• Polished animations and satisfying feedback on every guess

WHY WORDSCHOOL?
• Free to play — core gameplay always available
• Two distinct daily modes keep things fresh
• Story-driven detective cases powered by fresh daily content
• Archive mode for extra practice on your schedule
• Built for word lovers, mystery fans, and anyone who enjoys a daily brain teaser

Download WordSchool and make word puzzles part of your daily routine. Guess the word. Close the case. See you tomorrow.
```

**~2,350 characters** — room to add localized paragraphs or feature updates later.

---

## What's New (version 1.0.0)

Use for the **What's New in This Version** field.

```
Welcome to WordSchool!

• Play today's daily 5-letter word puzzle
• Solve Detective Story Mode — a new mystery case every day
• Build streaks in both word puzzle and detective modes
• Compete on the weekly detective leaderboard
• Replay past puzzles in the archive calendar
• Share your results with friends
• Sign in with Google, Apple, or play as a guest
• Optional daily reminders for puzzles, cases, and streaks
• Noir atmosphere with ambient audio in story mode

Thanks for playing — see you tomorrow!
```

---

## App Store Connect checklist

### 1. App information

| Item | Status | Value / action |
| ---- | ------ | -------------- |
| App Name | ☐ | `WordSchool: Word & Mystery` |
| Subtitle | ☐ | `Daily Puzzles & Detective` |
| Bundle ID | ☐ | `com.wordschool.mat` |
| SKU | ☐ | e.g. `wordschool-ios-001` (your internal ID, immutable) |
| Primary Language | ☐ | English (U.S.) |
| Primary Category | ☐ | Games → **Word** |
| Secondary Category | ☐ | Games → **Puzzle** |
| Content Rights | ☐ | Confirm you own or have rights to all content |
| Age Rating | ☐ | Complete questionnaire → expect **4+** |
| Copyright | ☐ | `2026 Muneerahamed` — or `2026 Bosc Services` if submitting under that entity |

### 2. Pricing & availability

| Item | Status | Value / action |
| ---- | ------ | -------------- |
| Price | ☐ | Free |
| Availability | ☐ | All territories (or select target markets) |
| Pre-orders | ☐ | Optional — off for v1 launch |

### 3. URLs (required)

| Item | Status | Value / action |
| ---- | ------ | -------------- |
| **Privacy Policy URL** | ☐ **Required** | `https://sites.google.com/view/wordschool/home` |
| **Support URL** | ☐ **Required** | `https://sites.google.com/view/wordschool/home` |
| Marketing URL | ☐ Optional | App website or landing page |

#### Copyright (App Store Connect → App Information)

Apple expects **year + legal owner name**. Do **not** include the © symbol — Apple displays it automatically.

| Entity | Copyright field value |
| ------ | --------------------- |
| Individual developer | `2026 Muneerahamed` |
| Business (Google Sites privacy lists this) | `2026 Bosc Services` |

Optional — same string in `ios/Runner/Info.plist`:

```xml
<key>NSHumanReadableCopyright</key>
<string>2026 Muneerahamed</string>
```

### 4. App Privacy (nutrition labels)

Based on current codebase (Firebase Auth, Firestore, Firebase Analytics, FCM):

| Data type | Collected? | Linked to user? | Used for tracking? |
| --------- | ---------- | --------------- | ------------------ |
| User ID | Yes | Yes | No |
| Email (if Google/Apple sign-in) | Yes | Yes | No |
| Display name | Yes | Yes | No |
| Gameplay content (guesses, progress) | Yes | Yes | No |
| Product interaction (analytics) | Yes | No | No |
| Crash data | If enabled | No | No |
| Coarse location (country) | Via Analytics | No | No |
| Device token (push notifications) | Yes | Yes | No |

Declare in App Store Connect:

- **Data linked to you:** Identifiers, gameplay, contact info (email)
- **Data not linked to you:** Analytics / usage data
- **Tracking:** No (unless AdMob monetization is enabled — update labels if ads go live)
- **Third-party SDKs:** Firebase (Google)

### 5. Screenshots & previews

#### iPhone (required — 6.7" display)

Minimum **3** screenshots, up to **10**. Recommended sizes:

| Device | Size (px) | Required? |
| ------ | --------- | ----------- |
| iPhone 6.7" (15 Pro Max) | 1290 × 2796 | ✅ Primary set |
| iPhone 6.5" (11 Pro Max) | 1242 × 2688 | Optional (scaled) |
| iPhone 5.5" | 1242 × 2208 | Optional |

#### Suggested screenshot order (storytelling)

1. **Dashboard** — "Two challenges. Every day." + streak/stats
2. **Word gameplay** — active grid + keyboard mid-guess
3. **Detective intro** — noir case introduction screen
4. **Story Wordle** — clue puzzle in detective mode
5. **Victory / Case Closed** — win screen with score
6. **Leaderboard** — weekly detective rankings
7. **Archive** — calendar of past puzzles

You already have Play Store assets at `assets/playstore/` (1080×1920). Resize/reframe to **1290×2796** for iPhone 6.7", or capture fresh on a simulator.

#### App Preview video (optional)

- 15–30 seconds
- Show: open app → daily word guess → open detective case → solve clue → case closed → leaderboard
- Same resolution as screenshot set for each device class

### 6. App icon

- **1024 × 1024** PNG, no transparency, no rounded corners (Apple applies mask)
- Source: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 7. Build & submission

| Item | Status | Action |
| ---- | ------ | ------ |
| Apple Developer account | ☐ | Enrolled ($99/year) |
| Certificates & profiles | ☐ | Distribution cert + App Store profile for `com.wordschool.mat` |
| App Store Connect app record | ☐ | Create app linked to bundle ID |
| Archive in Xcode | ☐ | `flutter build ipa` or Xcode → Product → Archive |
| Upload build | ☐ | Xcode Organizer or Transporter |
| Select build in Connect | ☐ | Attach build to version 1.0.0 |
| Export compliance | ☐ | Typically "No" for HTTPS-only apps |
| Advertising Identifier (IDFA) | ☐ | **No** at launch (monetization off by default) |
| Review notes | ☐ | See below |
| Demo account | ☐ | Provide test Google account if login required for review |

#### Suggested review notes

```
WordSchool is a free daily word puzzle and detective mystery game. Reviewers can:
1. Tap "Continue as Guest" on the login screen to play immediately without signing in.
2. Play today's word puzzle from the dashboard (tap the daily puzzle card).
3. Play today's detective case from the dashboard (tap the Detective Case card).
4. Open "Previous Games" to access the archive.
5. View the weekly leaderboard from the detective section.

No special hardware or region is required. In-app purchases and ads are disabled in this build.
```

### 8. Age rating questionnaire (expected answers)

| Question area | Expected answer |
| ------------- | --------------- |
| Cartoon / fantasy violence | None |
| Realistic violence | None (detective theme is narrative, not graphic) |
| Sexual content | None |
| Profanity | None |
| Drugs / alcohol / tobacco | None |
| Gambling | None |
| Horror | None / Infrequent/Mild (noir mystery theme only) |
| Mature themes | None |
| Unrestricted web access | No |
| User-generated content | No |

**Expected rating: 4+**

### 9. In-app purchases & subscriptions

| Item | Value |
| ---- | ----- |
| IAP (when enabled) | Remove Ads, Hint Pack (5), Detective Pro (monthly) |
| At launch | Disabled via `IS_MONIT_PURCH=false` — declare "None" unless enabled before submission |

### 10. Sign in with Apple

Google Sign-In is offered — **Sign in with Apple** is implemented and required alongside it.

| Item | Status |
| ---- | ------ |
| Sign in with Apple | ✅ Implemented |

### 11. Localization (optional, recommended later)

| Priority | Locale | Notes |
| -------- | ------ | ----- |
| P1 | English (U.S.) | Launch |
| P2 | English (U.K.) | Same copy, minor spelling |
| P3 | Spanish, French, German | Larger word-game markets |

---

## Marketing positioning

### One-line pitch

**WordSchool — guess the word, solve the case, one puzzle at a time.**

### Elevator pitch (30 seconds)

WordSchool is the daily brain game for people who want more than a single word puzzle. Every day you get a classic 5-letter challenge plus a full detective mystery told through three word puzzles. Build streaks, climb weekly leaderboards, replay past games, and share your results — all in a polished noir-inspired app.

### Target audience

- Daily puzzle players (Wordle-style habit)
- Mystery and detective story fans
- Casual gamers who want short, satisfying sessions
- Vocabulary and brain-training enthusiasts
- Commuters and morning-routine players

### Differentiators (use in social posts & screenshot captions)

1. **Two daily modes** — word puzzle + detective story in one app
2. **Fresh daily content** — new word and new case every day
3. **Detective leaderboard** — weekly competition with scored outcomes
4. **Archive** — replay past word puzzles (many daily games lack this)
5. **Noir atmosphere** — rain audio, typewriter narrative, immersive UI
6. **Low friction** — guest, Google, or Apple sign-in
7. **Shareable results** — word grids and case outcomes

### Screenshot caption ideas (overlay text)

| Screen | Caption |
| ------ | ------- |
| Dashboard | Two challenges. Every day. |
| Word gameplay | Six guesses. One word. |
| Detective intro | A new case awaits. |
| Story clue | Investigate. Deduce. Solve. |
| Case Closed | Mystery solved. Streak saved. |
| Leaderboard | Rank among the best detectives |
| Archive | Missed a day? Replay it. |
| Stats | Track streaks, wins & detective points |

### Social media hooks

- "Can you close today's case in 3 clues?"
- "Word puzzle ✓ Detective case ✓ Streak protected ✓"
- "300 detective points. One perfect day. Can you do it?"
- "Cold Case again? Tomorrow's mystery is a fresh start."

---

## Pre-submission code fixes

| Item | File | Current | Should be |
| ---- | ---- | ------- | --------- |
| Home screen name | Xcode build settings | `Wordschool` | `WordSchool` |
| Privacy policy | `assets/legal/privacy.md` | Says no ads | Update if enabling AdMob before launch |

---

## Post-launch ASO tips

1. **Ask for ratings** after a win or case closed — not mid-game.
2. **Update promotional text** monthly with streak challenges or new case themes.
3. **A/B test** subtitle and screenshot #1 in App Store Connect (iOS 15+).
4. **Localize** keywords for top territories once you have download data.
5. **Ship major features** (IAP, new story themes) as a "What's New" moment to bump discovery.

---

## File reference in this repo

| Asset | Path |
| ----- | ---- |
| Privacy policy (source) | `assets/legal/privacy.md` |
| Terms (source) | `assets/legal/terms.md` |
| Play Store listing copy | `assets/playstore/PLAY_STORE_LISTING.md` |
| Play Store screenshots | `assets/playstore/` |
| App icon | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` |
| Version | `pubspec.yaml` → `1.0.0+4` |

---

*Last updated: July 5, 2026*
